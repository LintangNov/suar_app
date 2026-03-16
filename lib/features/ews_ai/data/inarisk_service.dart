import 'package:dio/dio.dart';

class InaRiskService {
  final Dio _dio;

  InaRiskService(this._dio);

  Future<bool> checkTsunamiHazard(double latitude, double longitude) async {
    try {
      const url = 'https://gis.bnpb.go.id/server/rest/services/inarisk/tsunami_bahaya/MapServer/0/query';

      final response = await _dio.get(
        url,
        queryParameters: {
          'f': 'json', 
          'geometryType': 'esriGeometryPoint', 
          'geometry': '$longitude,$latitude',
          'inSR': '4326', // Spatial Reference WGS84
          'spatialRel': 'esriSpatialRelIntersects', 
          'returnGeometry': 'false', 
          'outFields': '*',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['features'] != null && (data['features'] as List).isNotEmpty) {
          return true; 
        } else {
          return false;
        }
      } else {
        throw Exception('Gagal menghubungi server InaRISK BNPB');
      }
    } catch (e) {
      return true; 
    }
  }
}