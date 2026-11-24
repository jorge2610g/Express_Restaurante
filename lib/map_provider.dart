import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// Proveedor de mapas reducido para Express Restaurante: búsqueda de direcciones, dirección de un
// punto y ruta. Mismas reglas que la app principal (Photon / Nominatim / OSRM), sin Mapbox ni
// caché de teselas.

class ExpressMapRoute {
  final List<LatLng> points;
  final double? distanceMeters;
  final double? durationSeconds;
  final String provider;

  const ExpressMapRoute({
    required this.points,
    required this.provider,
    this.distanceMeters,
    this.durationSeconds,
  });
}

class ExpressMapProvider {
  /// Cliente HTTP. Solo las pruebas lo sustituyen.
  @visibleForTesting
  static http.Client routeHttpClient = http.Client();

  static Future<List<({String label, double latitude, double longitude})>>
  searchAddress({
    required String query,
    required String countryCode,
    required LatLng proximity,
    String city = '',
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 3 || countryCode.trim().length != 2) {
      return const [];
    }
    return _searchAddressWithPhoton(
      query: cleanQuery,
      city: city,
      countryCode: countryCode,
      proximity: proximity,
    );
  }

  static Future<List<({String label, double latitude, double longitude})>>
  _searchAddressWithPhoton({
    required String query,
    required String city,
    required String countryCode,
    required LatLng proximity,
  }) async {
    final countryName = switch (countryCode.toUpperCase()) {
      'CL' => 'Chile',
      'BO' => 'Bolivia',
      _ => countryCode.toUpperCase(),
    };
    // Si el número exacto no existe en el mapa, se busca también la calle sola y se le
    // devuelve a la etiqueta el número que escribió el usuario.
    final numbered = RegExp(r'^(.*?[A-Za-zÁÉÍÓÚÜÑáéíóúüñ].*?)[\s,#]+(\d{1,6})\s*$')
        .firstMatch(query.trim());
    final streetOnly = numbered?.group(1)?.trim();
    final houseNumber = numbered?.group(2);
    final queries = <({String text, String? number})>[
      if (city.trim().isNotEmpty) (text: '${query.trim()}, ${city.trim()}', number: null),
      (text: query.trim(), number: null),
      if (streetOnly != null && streetOnly.length >= 3) ...[
        if (city.trim().isNotEmpty)
          (text: '$streetOnly, ${city.trim()}', number: houseNumber),
        (text: streetOnly, number: houseNumber),
      ],
    ];
    // Primero se busca alrededor del punto de referencia (el local), unos 30 km; solo si no hay
    // nada ahí se busca en todo el país. Así la calle de la ciudad del local sale primero y no
    // una homónima de otra ciudad.
    const areaDegrees = 0.3;
    for (final bounded in const [true, false]) {
    for (final entry in queries) {
      final candidate = entry.text;
      // Sin «lang»: Photon solo admite unos pocos idiomas y responde error con «es».
      final uri = Uri.https('photon.komoot.io', '/api/', {
        'q': '$candidate, $countryName',
        'limit': bounded ? '8' : '5',
        'lat': proximity.latitude.toString(),
        'lon': proximity.longitude.toString(),
        if (bounded)
          'bbox': [
            proximity.longitude - areaDegrees,
            proximity.latitude - areaDegrees,
            proximity.longitude + areaDegrees,
            proximity.latitude + areaDegrees,
          ].join(','),
      });
      try {
        final response = await routeHttpClient
            .get(uri, headers: const {'Accept-Language': 'es'})
            .timeout(const Duration(seconds: 5));
        if (response.statusCode != 200) continue;
        final decoded = jsonDecode(response.body);
        final features = decoded is Map ? decoded['features'] : null;
        if (features is! List) continue;
        final results = features
            .whereType<Map>()
            .map((feature) {
              final properties = feature['properties'];
              final geometry = feature['geometry'];
              final coordinates = geometry is Map
                  ? geometry['coordinates']
                  : null;
              if (properties is! Map ||
                  coordinates is! List ||
                  coordinates.length < 2) {
                return null;
              }
              final resultCountry = properties['countrycode']
                  ?.toString()
                  .toUpperCase();
              if (resultCountry != null &&
                  resultCountry != countryCode.toUpperCase()) {
                return null;
              }
              String clean(String key) => properties[key]?.toString().trim() ?? '';
              // El número que escribió el usuario se agrega a la calle cuando el mapa no lo
              // tiene (en OpenStreetMap casi no hay números de casa en la región).
              final typedNumber = houseNumber;
              final addNumber = typedNumber != null &&
                  clean('housenumber').isEmpty &&
                  (clean('street').isNotEmpty ||
                      properties['osm_key']?.toString() == 'highway');
              final streetPart = clean('street').isNotEmpty ? clean('street') : clean('name');
              final parts = <String>{
                for (final key in [
                  'name',
                  'housenumber',
                  'street',
                  'city',
                  'state',
                  'country',
                ])
                  if (clean(key).isNotEmpty)
                    addNumber && clean(key) == streetPart
                        ? '${clean(key)} $typedNumber'
                        : clean(key),
              };
              final longitude = double.tryParse(coordinates[0].toString());
              final latitude = double.tryParse(coordinates[1].toString());
              if (parts.isEmpty || latitude == null || longitude == null) {
                return null;
              }
              return (
                label: parts.join(', '),
                latitude: latitude,
                longitude: longitude,
              );
            })
            .whereType<({String label, double latitude, double longitude})>()
            .toList();
        // Una misma calle llega en varios tramos: se muestra una sola vez.
        final seen = <String>{};
        results.removeWhere((r) => !seen.add(r.label));
        if (results.isNotEmpty) {
          const distance = Distance();
          double meters(({String label, double latitude, double longitude}) r) =>
              distance(proximity, LatLng(r.latitude, r.longitude));
          results.sort((a, b) => meters(a).compareTo(meters(b)));
          return results.take(5).toList();
        }
      } catch (_) {
        // Try the less specific query before reporting no matches.
      }
    }
    }
    return const [];
  }

  static Future<String?> reverseGeocode({
    required LatLng point,
    required String countryCode,
  }) async {
    final normalizedCountry = countryCode.trim();
    if (normalizedCountry.length != 2) return null;
    return reverseGeocodeLocationLabel(
      point: point,
      countryCode: normalizedCountry,
    );
  }

  static Future<String?> reverseGeocodeLocationLabel({
    required LatLng point,
    String? countryCode,
  }) async {
    final normalizedCountry = countryCode?.trim().toUpperCase();
    if (normalizedCountry != null && normalizedCountry.length != 2) {
      return null;
    }
    final photonFuture = _photonReverseLabel(
      point,
      countryCode: normalizedCountry,
    );
    // Nominatim entra solo si Photon no responde en 1 s. Gana el primero que
    // devuelva una dirección válida; así no se espera el tope completo de Photon.
    final completer = Completer<String?>();
    var pending = 2;
    void settle(String? value) {
      if (value != null && !completer.isCompleted) completer.complete(value);
      pending--;
      if (pending == 0 && !completer.isCompleted) completer.complete(null);
    }

    photonFuture.then(settle);
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (completer.isCompleted) return;
      _nominatimReverseGeocode(point, countryCode: normalizedCountry)
          .then(settle);
    });
    return completer.future;
  }

  static Future<String?> _photonReverseLabel(
    LatLng point, {
    String? countryCode,
  }) async {
    final uri = Uri.https('photon.komoot.io', '/reverse', {
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'lang': 'es',
      'limit': '5',
    });
    try {
      final response = await routeHttpClient.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Accept-Language': 'es',
          // Browsers forbid custom User-Agent headers. They send their own
          // Origin/Referer; native clients identify the Express application.
          if (!kIsWeb) 'User-Agent': 'ExpressDelivery/1.6 (https://expressviajes.online)',
        },
      ).timeout(const Duration(seconds: 3));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      final features = decoded is Map ? decoded['features'] : null;
      return expressAddressLabelFromPhotonFeatures(
        features,
        countryCode: countryCode,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> _nominatimRequestQueue = Future<void>.value();
  static DateTime? _lastNominatimReverseRequestAt;

  static Future<String?> _nominatimReverseGeocode(
    LatLng point, {
    String? countryCode,
  }) async {
    final completer = Completer<void>();
    final previous = _nominatimRequestQueue;
    _nominatimRequestQueue = completer.future;
    await previous;
    try {
      final last = _lastNominatimReverseRequestAt;
      if (last != null) {
        final remaining = const Duration(milliseconds: 1100) -
            DateTime.now().difference(last);
        if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      }
      _lastNominatimReverseRequestAt = DateTime.now();

      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': point.latitude.toString(),
        'lon': point.longitude.toString(),
        'format': 'jsonv2',
        'zoom': '18',
        'addressdetails': '1',
      });
      final response = await routeHttpClient.get(
        uri,
        headers: const {
          'Accept': 'application/json',
          'Accept-Language': 'es',
          // The browser supplies its own Origin/Referer; native requests
          // can set the Express User-Agent required by the public geocoder.
          if (!kIsWeb) 'User-Agent': 'ExpressViajes/1.6.4 (https://expressviajes.online)',
        },
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      return expressAddressLabelFromNominatimPayload(
        decoded,
        countryCode: countryCode,
      );
    } catch (_) {
      return null;
    } finally {
      completer.complete();
    }
  }

  static Future<ExpressMapRoute> drivingRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    final route = await _osrmRoute(from: from, to: to);
    return route ??
        ExpressMapRoute(points: <LatLng>[from, to], provider: 'direct');
  }

  static Future<ExpressMapRoute?> _osrmRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};'
        '${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );
      final response =
          await routeHttpClient.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded['routes'] is! List) return null;
      final routes = decoded['routes'] as List;
      if (routes.isEmpty || routes.first is! Map) return null;
      final first = Map<String, dynamic>.from(routes.first as Map);
      final geometry = first['geometry'];
      if (geometry is! Map || geometry['coordinates'] is! List) return null;

      final points = _decodeGeoJsonCoordinates(geometry['coordinates'] as List);
      if (points.length < 2) return null;

      return ExpressMapRoute(
        points: points,
        distanceMeters: (first['distance'] as num?)?.toDouble(),
        durationSeconds: (first['duration'] as num?)?.toDouble(),
        provider: 'osrm',
      );
    } catch (_) {
      return null;
    }
  }

  static List<LatLng> _decodeGeoJsonCoordinates(List rawCoordinates) {
    final points = <LatLng>[];
    for (final raw in rawCoordinates) {
      if (raw is! List || raw.length < 2) continue;
      final lng = (raw[0] as num?)?.toDouble();
      final lat = (raw[1] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      if (!lat.isFinite ||
          !lng.isFinite ||
          lat < -90 ||
          lat > 90 ||
          lng < -180 ||
          lng > 180) {
        continue;
      }
      points.add(LatLng(lat, lng));
    }
    return points;
  }
}

String? expressAddressLabelFromPhotonFeatures(
  Object? rawFeatures, {
  String? countryCode,
}) {
  if (rawFeatures is! List) return null;
  final expectedCountry = countryCode?.trim().toUpperCase();
  String? bestLabel;
  var bestScore = -1;

  for (final feature in rawFeatures.whereType<Map>()) {
    final properties = feature['properties'];
    if (properties is! Map) continue;
    final resultCountry = properties['countrycode']?.toString().toUpperCase();
    if (expectedCountry != null &&
        expectedCountry.length == 2 &&
        resultCountry != null &&
        resultCountry != expectedCountry) {
      continue;
    }

    String? cleanPart(Object? raw) {
      final value = raw?.toString().trim();
      return value == null ||
              value.isEmpty ||
              isExpressPlaceholderAddress(value)
          ? null
          : value;
    }

    final name = cleanPart(properties['name']);
    final houseNumber = cleanPart(properties['housenumber']);
    final street = cleanPart(properties['street'] ?? properties['road']);
    final addressLine = [houseNumber, street]
        .whereType<String>()
        .toSet()
        .join(' ');
    final locality = <String>[];
    for (final key in [
      'neighbourhood',
      'neighborhood',
      'suburb',
      'city',
      'town',
      'village',
      'locality',
      'district',
      'county',
      'state',
      'country',
    ]) {
      final part = cleanPart(properties[key]);
      if (part != null) locality.add(part);
    }

    final parts = <String>[];
    if (name != null) parts.add(name);
    if (addressLine.isNotEmpty &&
        !parts.any((part) => part.toLowerCase() == addressLine.toLowerCase())) {
      parts.add(addressLine);
    }
    for (final part in locality) {
      if (!parts.any(
          (existing) => existing.toLowerCase() == part.toLowerCase())) {
        parts.add(part);
      }
    }
    if (parts.isEmpty) continue;

    final score = (addressLine.isNotEmpty ? 100 : 0) +
        (name != null ? 40 : 0) +
        (locality.isNotEmpty ? 20 : 0);
    if (score > bestScore) {
      bestScore = score;
      bestLabel = parts.join(', ');
    }
  }
  return bestLabel;
}

String? expressAddressLabelFromNominatimPayload(
  Object? payload, {
  String? countryCode,
}) {
  if (payload is! Map) return null;
  final address = payload['address'];
  if (address is! Map) return null;

  final expectedCountry = countryCode?.trim().toUpperCase();
  final resultCountry = address['country_code']?.toString().toUpperCase();
  if (expectedCountry != null &&
      expectedCountry.length == 2 &&
      resultCountry != null &&
      resultCountry != expectedCountry) {
    return null;
  }

  String? cleanPart(Object? raw) {
    final value = raw?.toString().trim();
    return value == null ||
            value.isEmpty ||
            isExpressPlaceholderAddress(value)
        ? null
        : value;
  }

  final houseNumber = cleanPart(address['house_number']);
  final street = cleanPart(
    address['road'] ??
        address['pedestrian'] ??
        address['residential'] ??
        address['footway'] ??
        address['path'] ??
        address['cycleway'],
  );
  final streetAddress = [houseNumber, street]
      .whereType<String>()
      .toSet()
      .join(' ');
  final parts = <String>[];
  if (streetAddress.isNotEmpty) parts.add(streetAddress);
  for (final key in [
    'neighbourhood',
    'suburb',
    'city_district',
    'city',
    'town',
    'village',
    'municipality',
    'county',
    'state',
    'country',
  ]) {
    final part = cleanPart(address[key]);
    if (part != null &&
        !parts.any(
          (existing) => existing.toLowerCase() == part.toLowerCase(),
        )) {
      parts.add(part);
    }
  }

  if (parts.isNotEmpty) return parts.join(', ');
  final displayName = cleanPart(payload['display_name']);
  return displayName;
}

bool isExpressPlaceholderAddress(Object? value) {
  final text = value?.toString().trim().toLowerCase() ?? '';
  return text.isEmpty ||
      text == 'origen' ||
      text == 'destino' ||
      text == 'origen no disponible' ||
      text == 'destino no disponible' ||
      text == 'ubicación seleccionada' ||
      text == 'ubicacion seleccionada' ||
      text.startsWith('ubicación seleccionada ·') ||
      text.startsWith('ubicacion seleccionada ·') ||
      text == 'punto seleccionado' ||
      text == 'punto marcado en el mapa' ||
      text.startsWith('punto seleccionado ·') ||
      text == 'mi ubicación' ||
      text == 'mi ubicacion' ||
      text == 'mi ubicación actual' ||
      text == 'mi ubicacion actual' ||
      text == 'ubicación actual' ||
      text == 'ubicacion actual' ||
      text == 'selecciona dónde te encuentras' ||
      text == 'selecciona donde te encuentras' ||
      text.contains('buscando dirección') ||
      text.contains('buscando direccion') ||
      text.contains('ajustando ubicación') ||
      text.contains('ajustando ubicacion');
}
