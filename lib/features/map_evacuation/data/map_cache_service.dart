import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MapCacheService {
  static const String _storeName = 'evacuation_map';

  Future<void> _initStore() async {
    final store = FMTCStore(_storeName);
    await store.manage.create();
  }

  Future<void> downloadMapRadius(
    LatLng center, {
    double radiusInMeters = 3000,
  }) async {
    try {
      await _initStore();
      final store = FMTCStore(_storeName);

      const distance = Distance();

      final sw = distance.offset(center, radiusInMeters, 225);
      final ne = distance.offset(center, radiusInMeters, 45);

      final region = RectangleRegion(LatLngBounds(sw, ne));
      final downloadableRegion = region.toDownloadable(
        minZoom: 14,
        maxZoom: 17,
        options: TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.suar.app',
        ),
      );

      final downloadStream = store.download.startForeground(
        region: downloadableRegion,
        parallelThreads: 4,
        skipExistingTiles: true,
        skipSeaTiles: true,
      );

      await downloadStream.downloadProgress.last;
    } catch (e) {
      throw Exception('Gagal mengunduh peta: $e');
    }
  }

  static const String _routeKey = 'offline_evacuation_route';

  Future<void> saveOfflineRoute(List<LatLng> route) async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, double>> routeData = route.map((point) {
      return {'lat': point.latitude, 'lng': point.longitude};
    }).toList();

    final String encodedRoute = jsonEncode(routeData);
    await prefs.setString(_routeKey, encodedRoute);
  }

  Future<List<LatLng>?> getOfflineRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedRoute = prefs.getString(_routeKey);

    if (encodedRoute == null) return null;

    try {
      final List<dynamic> decodedData = jsonDecode(encodedRoute);

      return decodedData.map((item) {
        return LatLng(item['lat'] as double, item['lng'] as double);
      }).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    final store = FMTCStore(_storeName);
    await store.manage.delete();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_routeKey);
  }
}
