import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import 'package:express_restaurante/restaurant_location_provider.dart';

void main() {
  late http.Client originalClient;

  setUp(() {
    originalClient = RestaurantLocationProvider.httpClient;
  });

  tearDown(() {
    RestaurantLocationProvider.httpClient.close();
    RestaurantLocationProvider.httpClient = originalClient;
  });

  test(
    'address autocomplete retries without city when there are no matches',
    () async {
      final queries = <String>[];
      RestaurantLocationProvider.httpClient = MockClient((request) async {
        queries.add(request.url.queryParameters['q'] ?? '');
        if (queries.length == 1) return http.Response('{"features":[]}', 200);
        return http.Response(
          jsonEncode({
            'features': [
              {
                'geometry': {
                  'coordinates': [-64.9008, -14.8337],
                },
                'properties': {
                  'countrycode': 'BO',
                  'name': 'Calle Bolívar',
                  'city': 'Trinidad',
                  'country': 'Bolivia',
                },
              },
            ],
          }),
          200,
        );
      });

      final results = await RestaurantLocationProvider.searchAddress(
        query: 'calle b',
        city: 'Trinidad',
        countryCode: 'BO',
        proximity: const LatLng(-14.8337, -64.9008),
      );

      expect(queries, hasLength(2));
      expect(queries.first, contains('Trinidad'));
      expect(results, hasLength(1));
      expect(results.single.label, contains('Trinidad'));
    },
  );
}
