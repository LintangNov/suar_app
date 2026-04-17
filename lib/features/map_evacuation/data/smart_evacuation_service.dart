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

    print('\n=== MULAI ANALISIS RUTE EVAKUASI (HYBRID SNAP) ===');
    
    for (double radius in searchRadii) {
      List<Map<String, dynamic>> validCandidates = [];

      final futures = bearings.map((bearing) async {
        try {
          final LatLng candidatePoint = distanceCalculator.offset(
            currentLocation,
            radius,
            bearing,
          );

          final isRedZone = await inarisk.checkTsunamiHazard(
            candidatePoint.latitude,
            candidatePoint.longitude,
          );
          if (isRedZone) {
            print('❌ Arah $bearing°: Di Zona Merah InaRISK');
            return null;
          }

          final elevation = await elevationService.getElevation(candidatePoint);
          if (elevation <= 5.0) {
            print('❌ Arah $bearing°: Elevasi rendah ($elevation m)');
            return null;
          }

          print('✅ Arah $bearing° lolos! (Elevasi: $elevation m)');
          return {'point': candidatePoint, 'elevation': elevation, 'bearing': bearing};
        } catch (e) {
          return null; 
        }
      });

      final results = await Future.wait(futures);
      for (var res in results) {
        if (res != null) validCandidates.add(res);
      }

      print('\nTotal kandidat kasar: ${validCandidates.length}');

      if (validCandidates.isNotEmpty) {
        validCandidates.sort(
          (a, b) => (b['elevation'] as double).compareTo(a['elevation'] as double),
        );

        for (var candidate in validCandidates) {
          final bearing = candidate['bearing'];
          final originalPoint = candidate['point'] as LatLng;
          print('\n⏳ Mengeksekusi kandidat terbaik arah $bearing°...');

          final snappedPoint = await routingService.getSnappedPoint(originalPoint);
          if (snappedPoint == null) {
            print('⚠️ Arah $bearing° diabaikan: Tidak ada akses jalan pejalan kaki terdekat (Terisolasi).');
            continue;
          }

          final isSnappedRedZone = await inarisk.checkTsunamiHazard(snappedPoint.latitude, snappedPoint.longitude);
          if (isSnappedRedZone) {
            print('⚠️ Arah $bearing° diabaikan: Titik jalan mundur ke Zona Merah Tsunami!');
            continue; 
          }

          final snappedElevation = await elevationService.getElevation(snappedPoint);
          if (snappedElevation <= 5.0) {
            print('⚠️ Arah $bearing° diabaikan: Jalan raya berada di elevasi rendah ($snappedElevation m).');
            continue;
          }

          try {
            print('🛣️ Validasi sukses! Membangun rute ke jalan aspal arah $bearing°...');
            final route = await routingService.getEvacuationRoute(
              currentLocation,
              snappedPoint,
            );
            print('🎉 RUTE EVAKUASI DITEMUKAN!');
            return route;
          } catch (e) {
            print('⚠️ Rute darat gagal dibuat (kemungkinan terhalang sungai): $e');
            continue; 
          }
        }
      }
    }

    print('🚨 KESIMPULAN: Semua titik jalan kaki gagal. Harus evakuasi vertikal.');
    throw VerticalEvacuationException(
      'Tidak ditemukan rute darat yang aman. Lakukan Evakuasi Vertikal ke gedung tinggi terdekat!',
    );
  }
}