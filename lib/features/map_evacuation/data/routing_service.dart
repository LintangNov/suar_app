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
          final double lon = (coord[0] as num).toDouble();
          final double lat = (coord[1] as num).toDouble();
          return LatLng(lat, lon);
        }).toList();
      } else {
        throw Exception('Gagal mengambil rute: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error kalkulasi rute evakuasi ORS: $e');
    }
  }

  Future<LatLng?> getSnappedPoint(LatLng point, {int radius = 500}) async {
    try {
      const String profile = 'foot-walking';
      const String url = 'https://api.openrouteservice.org/v2/snap/$profile';

      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': apiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          "locations": [[point.longitude, point.latitude]],
          "radius": radius
        },
      );

      if (response.statusCode == 200) {
        final locations = response.data['locations'] as List;
        if (locations.isNotEmpty && locations[0] != null) {
          final snappedCoords = locations[0]['location'];
          final double lon = (snappedCoords[0] as num).toDouble();
          final double lat = (snappedCoords[1] as num).toDouble();
          return LatLng(lat, lon);
        }
      }
      return null;
    } catch (e) {
      print('⚠️ Snapping API Error: $e');
      return null;
    }
  }
}