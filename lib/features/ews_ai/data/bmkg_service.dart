import 'package:dio/dio.dart';
import '../domain/gempa_model.dart';

class BmkgService {
  final Dio _dio;

  BmkgService(this._dio);

  Future<GempaModel> fetchLatestEarthquake() async {
    try {
      const url = 'https://data.bmkg.go.id/DataMKG/TEWS/autogempa.json';
      
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return GempaModel.fromJson(response.data);
      } else {
        throw Exception('Gagal menghubungi server BMKG: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Masalah jaringan atau server BMKG down: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memproses data gempa: $e');
    }
  }
}