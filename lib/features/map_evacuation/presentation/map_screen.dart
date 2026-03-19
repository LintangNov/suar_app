import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:suar_app/core/theme/app_colors.dart';
import 'package:suar_app/features/map_evacuation/presentation/map_provider.dart';
import '../data/smart_evacuation_service.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(userLocationStreamProvider);
    final routeAsync = ref.watch(evacuationRouteProvider);

    ref.listen<AsyncValue<LatLng>>(userLocationStreamProvider, (prev, next){
      if (_isMapReady && next.hasValue && next.value!= null) {
        _mapController.move(next.value!, _mapController.camera.zoom);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Katakan Peta!")),
      body: locationAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mencari sinyal satelit GPS...'),
            ],
          ),
        ),
        error: (err, stack) => Center(child: Text('Gagal memuat lokasi: $err')),
        data: (currentLocation) {
          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentLocation,
                  initialZoom: 16,
                  onMapReady: () {
                    setState(() {
                      _isMapReady = true;
                    });
                  },
                ),
                children: [
                  // base map layer
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.suar.app',
                    tileProvider: FMTCTileProvider(
                      stores: const {
                        'evacuation_map': BrowseStoreStrategy.read,
                      },
                    ),
                  ),

                  if (routeAsync.hasValue && routeAsync.value!.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routeAsync.value!,
                          color: AppColors.primary,
                          strokeWidth: 5,
                          strokeJoin: StrokeJoin.round,
                        ),
                      ],
                    ),

                  // user position layer
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentLocation,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(
                              alpha: 0.5,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.my_location,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: routeAsync.when(
                  data: (_) => const SizedBox.shrink(),
                  loading: () => const Card(
                    color: AppColors.surface,
                    child: ListTile(
                      leading: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      title: Text(
                        'Menganalisis Topografi...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Mencari rute ke dataran tinggi terdekat',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  error: (err, stack) {
                    if (err is VerticalEvacuationException) {
                      return Card(
                        color: AppColors.danger,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.white,
                                    size: 28,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'EVAKUASI VERTIKAL!',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                err.message,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Card(
                      color: AppColors.warningLight,
                      child: ListTile(
                        leading: const Icon(
                          Icons.wifi_off,
                          color: AppColors.warning,
                        ),
                        title: const Text('Gagal membuat rute darat'),
                        subtitle: Text(
                          err.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                bottom: 24,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'recenter_fab',
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primary,
                  onPressed: _isMapReady
                      ? () {
                          _mapController.move(currentLocation, 16.0);
                        }
                      : null,
                  child: const Icon(Icons.center_focus_strong),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
