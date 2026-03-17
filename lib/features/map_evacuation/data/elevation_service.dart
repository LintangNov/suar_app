import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class ElevationService {
  final Dio _dio;
  final String apiKey;

  ElevationService(this._dio, {required this.apiKey});

  Future<double> getElevation(LatLng point) async {
    try {
      const String url = 'https://api.openrouteservice.org/elevation/point';
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "format_in": "geojson",
          "format_out": "geojson",
          "geometry": {
            "type": "Point",
            "coordinates": [point.longitude, point.latitude] 
          }
        },
      );

      if (response.statusCode == 200) {
        final List coordinates = response.data['geometry']['coordinates'];
        
        return (coordinates[2] as num).toDouble();
      } else {
        throw Exception('Gagal mengambil elevasi');
      }
    } catch (e) {
      return 0.0; 
    }
  }
}