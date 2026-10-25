import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RestaurantLocationProvider {
  RestaurantLocationProvider._();

  static http.Client httpClient = http.Client();

  static Future<List<({String label, double latitude, double longitude})>>
  searchAddress({
    required String query,
    required String countryCode,
    required LatLng proximity,
    String city = '',
  }) async {
    if (query.trim().length < 3) return const [];
    final countryName = switch (countryCode.toUpperCase()) {
      'CL' => 'Chile',
      'BO' => 'Bolivia',
      _ => countryCode.toUpperCase(),
    };
    final queries = <String>{
      if (city.trim().isNotEmpty) '$query, ${city.trim()}, $countryName',
      '$query, $countryName',
      query,
    };
    for (final candidate in queries) {
      final uri = Uri.https('photon.komoot.io', '/api/', {
        'q': candidate,
        'lang': 'es',
        'limit': '5',
        'lat': proximity.latitude.toString(),
        'lon': proximity.longitude.toString(),
      });
      try {
        final response = await httpClient
            .get(
              uri,
              headers: const {
                'Accept-Language': 'es',
                'User-Agent': 'ExpressViajes restaurant registration',
              },
            )
            .timeout(const Duration(seconds: 7));
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
              final foundCountry = properties['countrycode']
                  ?.toString()
                  .toUpperCase();
              if (foundCountry != null &&
                  foundCountry != countryCode.toUpperCase()) {
                return null;
              }
              final parts = <String>{
                for (final key in [
                  'name',
                  'housenumber',
                  'street',
                  'city',
                  'state',
                  'country',
                ])
                  if ((properties[key]?.toString().trim() ?? '').isNotEmpty)
                    properties[key].toString().trim(),
              };
              final label = parts.join(', ');
              final longitude = double.tryParse(coordinates[0].toString());
              final latitude = double.tryParse(coordinates[1].toString());
              if (label.isEmpty || latitude == null || longitude == null) {
                return null;
              }
              return (label: label, latitude: latitude, longitude: longitude);
            })
            .whereType<({String label, double latitude, double longitude})>()
            .toList();
        if (results.isNotEmpty) return results;
      } catch (error) {
        debugPrint('Address lookup failed: $error');
      }
    }
    return const [];
  }

  static Future<String?> reverseGeocode({
    required LatLng point,
    required String countryCode,
  }) async {
    final uri = Uri.https('photon.komoot.io', '/reverse', {
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'lang': 'es',
    });
    try {
      final response = await httpClient
          .get(uri, headers: const {'Accept-Language': 'es'})
          .timeout(const Duration(seconds: 7));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      final features = decoded is Map ? decoded['features'] : null;
      if (features is! List || features.isEmpty || features.first is! Map) {
        return null;
      }
      final properties = (features.first as Map)['properties'];
      if (properties is! Map) return null;
      final foundCountry = properties['countrycode']?.toString().toUpperCase();
      if (foundCountry != null && foundCountry != countryCode.toUpperCase()) {
        return null;
      }
      final parts = <String>{
        for (final key in [
          'name',
          'housenumber',
          'street',
          'city',
          'state',
          'country',
        ])
          if ((properties[key]?.toString().trim() ?? '').isNotEmpty)
            properties[key].toString().trim(),
      };
      return parts.isEmpty ? null : parts.join(', ');
    } catch (_) {
      return null;
    }
  }
}
