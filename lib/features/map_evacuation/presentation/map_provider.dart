import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../ews_ai/presentation/ews_provider.dart'; 
import '../data/routing_service.dart';
import '../data/elevation_service.dart';
import '../data/smart_evacuation_service.dart';

final userLocationStreamProvider = StreamProvider<LatLng>((ref) {
  return Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, 
    ),
  ).map((position) => LatLng(position.latitude, position.longitude));
});

final routingServiceProvider = Provider<RoutingService>((ref) {
  final apiKey = dotenv.env['ORS_API_KEY'] ?? '';
  return RoutingService(ref.watch(dioProvider), apiKey: apiKey);
});

final elevationServiceProvider = Provider<ElevationService>((ref) {
  final apiKey = dotenv.env['ORS_API_KEY'] ?? '';
  return ElevationService(ref.watch(dioProvider), apiKey: apiKey);
});

final smartEvacuationProvider = Provider<SmartEvacuationService>((ref) {
  return SmartEvacuationService(
    inarisk: ref.watch(inariskServiceProvider),
    elevationService: ref.watch(elevationServiceProvider),
    routingService: ref.watch(routingServiceProvider),
  );
});

final evacuationRouteProvider = FutureProvider<List<LatLng>>((ref) async {
  final currentLocation = await ref.watch(userLocationStreamProvider.future);
  
  final smartEvacuation = ref.read(smartEvacuationProvider);
  
  return await smartEvacuation.findOptimalRoute(currentLocation);
});