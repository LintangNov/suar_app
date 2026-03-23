import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:suar_app/features/map_evacuation/data/map_cache_service.dart';

import '../../ews_ai/presentation/ews_provider.dart'; 
import '../data/routing_service.dart';
import '../data/elevation_service.dart';
import '../data/smart_evacuation_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

final userLocationStreamProvider = StreamProvider<LatLng>((ref) async* {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('GPS tidak aktif. Mohon nyalakan lokasi Anda.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Izin lokasi ditolak permanen. Buka pengaturan HP.');
  }

  yield* Geolocator.getPositionStream(
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
  final networkState = await ref.watch(networkStatusProvider.future);
  final hasInternet = !networkState.contains(ConnectivityResult.none);
  
  final cacheService = MapCacheService();

  if (!hasInternet) {
    final cachedRoute = await cacheService.getOfflineRoute();
    if (cachedRoute != null && cachedRoute.isNotEmpty) {
      return cachedRoute;
    } else {
      throw VerticalEvacuationException('Tidak ada rute offline yang tersimpan di memori. Lakukan Evakuasi Vertikal!');
    }
  }

  final locService = ref.read(locationServiceProvider);
  final position = await locService.getCurrentPosition();
  final startLocation = LatLng(position.latitude, position.longitude);
  
  final smartEvacuation = ref.read(smartEvacuationProvider);
  final freshRoute = await smartEvacuation.findOptimalRoute(startLocation);

  await cacheService.saveOfflineRoute(freshRoute);

  return freshRoute;
});

final networkStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final mapCacheStatusProvider = FutureProvider<bool>((ref) async {
  try {
    final store = FMTCStore('evacuation_map');
    final length = await store.stats.length;
    return length > 0;
  } catch (e) {
    return false;
  }
});

final mapCacheStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final store = FMTCStore('evacuation_map');
    final length = await store.stats.length;
    
    final estimatedSizeMb = (length * 18.0) / 1024.0; 
    
    return {
      'count': length,
      'sizeMb': estimatedSizeMb,
    };
  } catch (e) {
    return {
      'count': 0,
      'sizeMb': 0.0,
    };
  }
});