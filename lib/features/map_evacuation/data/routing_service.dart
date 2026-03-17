import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class RoutingService {
  final Dio _dio;
  final String apiKey;

  RoutingService(this._dio, {required this.apiKey});

  Future<List<LatLng>> getEvacuationRoute(LatLng start, LatLng destination) async {
    try {
      const String profile = 'foot-walking';
      const String url = 'https://api.openrouteservice.org/v2/directions/$profile';
      
      final response = await _dio.get(
        url,
        queryParameters: {
          'start': '${start.longitude},${start.latitude}',
          'end': '${destination.longitude},${destination.latitude}',
        },
        options: Options(
          headers: {
            'Authorization': apiKey,
            'Accept': 'application/json, application/geo+json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List coordinates = response.data['features'][0]['geometry']['coordinates'];
        
        return coordinates.map((coord) {
          final double lon = coord[0] as double;
          final double lat = coord[1] as double;
          return LatLng(lat, lon);
        }).toList();
      } else {
        throw Exception('Gagal mengambil rute: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error kalkulasi rute evakuasi ORS: $e');
    }
  }
}