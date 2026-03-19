import 'package:latlong2/latlong.dart';
import '../../ews_ai/data/inarisk_service.dart';
import 'elevation_service.dart';
import 'routing_service.dart';

// Exception if no safe route found
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
    // search radius
    final List<double> searchRadii = [2000.0, 5000.0, 7000.0];
    // 8 directional bearings
    final List<double> bearings = [0, 45, 90, 135, 180, 225, 270, 315];

    const distanceCalculator = Distance();

    for (double radius in searchRadii) {
      List<Map<String, dynamic>> validCandidates = [];

      for (double bearing in bearings) {
        final LatLng candidatePoint = distanceCalculator.offset(
          currentLocation,
          radius,
          bearing,
        );

        final isRedZone = await inarisk.checkTsunamiHazard(
          candidatePoint.latitude,
          candidatePoint.longitude,
        );
        if (isRedZone) continue;

        final elevation = await elevationService.getElevation(candidatePoint);
        if (elevation <= 5.0) continue;

        validCandidates.add({'point': candidatePoint, 'elevation': elevation});
      }

      // Desicion Support
      if (validCandidates.isNotEmpty) {
        validCandidates.sort(
          (a, b) =>
              (b['elevation'] as double).compareTo(a['elevation'] as double),
        );

        final LatLng bestPoint = validCandidates.first['point'];

        for (var candidate in validCandidates) {
          try {
            return await routingService.getEvacuationRoute(
              currentLocation,
              bestPoint,
            );
          } catch (e) {
            continue;
          }
        }
      }
    }

    // Fallback if no route found after all radius searches
    throw VerticalEvacuationException(
      'Tidak ditemukan dataran tinggi yang aman dalam radius tempuh jalan kaki. Lakukan Evakuasi Vertikal!',
    );
  }
}
