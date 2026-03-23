import 'package:latlong2/latlong.dart';
import '../../ews_ai/data/inarisk_service.dart';
import 'elevation_service.dart';
import 'routing_service.dart';

class VerticalEvacuationException implements Exception {
  final String message;
  VerticalEvacuationException(this.message);
  @override
  String toString() => message;
}

class SmartEvacuationService {
  final InaRiskService inarisk;
  final ElevationService elevationService;
  final RoutingService routingService;

  SmartEvacuationService({
    required this.inarisk,
    required this.elevationService,
    required this.routingService,
  });

  Future<List<LatLng>> findOptimalRoute(LatLng currentLocation) async {
    final List<double> searchRadii = [3000.0]; 
    final List<double> bearings = [0, 45, 90, 135, 180, 225, 270, 315];

    const distanceCalculator = Distance();

    print('\n=== MULAI ANALISIS RUTE EVAKUASI ===');
    print('Lokasi Saat Ini: ${currentLocation.latitude}, ${currentLocation.longitude}');

    for (double radius in searchRadii) {
      List<Map<String, dynamic>> validCandidates = [];

      final futures = bearings.map((bearing) async {
        try {
          final LatLng candidatePoint = distanceCalculator.offset(
            currentLocation,
            radius,
            bearing,
          );

          // 1. Cek zona merah
          final isRedZone = await inarisk.checkTsunamiHazard(
            candidatePoint.latitude,
            candidatePoint.longitude,
          );
          if (isRedZone) {
            print('❌ Arah $bearing° ditolak: Berada di Zona Merah InaRISK');
            return null;
          }

          // 2. Cek elevasi tanah
          final elevation = await elevationService.getElevation(candidatePoint);
          if (elevation <= 5.0) {
            print('❌ Arah $bearing° ditolak: Elevasi terlalu rendah ($elevation m)');
            return null;
          }

          print('✅ Arah $bearing° lolos seleksi awal! Elevasi: $elevation m');
          return {'point': candidatePoint, 'elevation': elevation, 'bearing': bearing};
        } catch (e) {
          print('❌ Arah $bearing° ditolak: Error API/Koneksi -> $e');
          return null; 
        }
      });

      final results = await Future.wait(futures);
      
      for (var res in results) {
        if (res != null) validCandidates.add(res);
      }

      print('\nTotal kandidat titik aman: ${validCandidates.length}');

      if (validCandidates.isNotEmpty) {
        validCandidates.sort(
          (a, b) => (b['elevation'] as double).compareTo(a['elevation'] as double),
        );

        for (var candidate in validCandidates) {
          final bearing = candidate['bearing'];
          print('⏳ Sedang mencoba kalkulasi rute ke arah $bearing° (Elevasi: ${candidate['elevation']} m)...');
          try {
            final route = await routingService.getEvacuationRoute(
              currentLocation,
              candidate['point'],
            );
            print('🎉 Rute sukses ditemukan ke arah $bearing°!');
            return route;
          } catch (e) {
            print('⚠️ Gagal membuat rute jalan kaki ke arah $bearing°: $e');
            continue; // Coba titik terbaik berikutnya
          }
        }
      }
    }

    print('🚨 KESIMPULAN: Semua titik gagal. Harus evakuasi vertikal.');
    throw VerticalEvacuationException(
      'Tidak ditemukan dataran tinggi yang aman dan bisa dijangkau jalan kaki dalam radius 3KM. Lakukan Evakuasi Vertikal ke gedung tinggi terdekat!',
    );
  }
}