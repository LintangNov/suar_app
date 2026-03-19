import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:suar_app/features/map_evacuation/presentation/geofence_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'ews_provider.dart';
import '../domain/triage_result_model.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../map_evacuation/presentation/map_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ewsState = ref.watch(ewsProvider);
    ref.watch(geofenceProvider);

    final isCacheReady = ref.watch(mapCacheStatusProvider).value ?? false;
    final networkState =
        ref.watch(networkStatusProvider).value ?? [ConnectivityResult.none];
    final hasInternet = !networkState.contains(ConnectivityResult.none);

    String mapTitle = 'Peta Evakuasi';
    String mapSubtitle = 'Memuat status peta...';
    IconData mapIcon = Icons.map;
    Color mapBadgeColor = AppColors.primary;
    bool isMapAvailable = true;

    if (isCacheReady) {
      mapTitle = 'Peta (Offline Ready)';
      mapSubtitle = 'Aman, jalur tersedia tanpa internet';
      mapIcon = Icons.offline_pin;
      mapBadgeColor = AppColors.success;
    } else if (hasInternet) {
      mapTitle = 'Peta (Live Online)';
      mapSubtitle = 'Menggunakan data untuk memuat peta';
      mapIcon = Icons.wifi;
      mapBadgeColor = AppColors.info;
    } else {
      mapTitle = 'Peta Belum Tersedia';
      mapSubtitle = 'Tidak ada internet & belum diunduh';
      mapIcon = Icons.wifi_off;
      mapBadgeColor = AppColors.danger;
      isMapAvailable = false;
    }

    ref.listen<AsyncValue<TriageResult?>>(ewsProvider, (previous, next) {
      if (next.hasValue &&
          next.value != null &&
          next.value!.statusTindakan == 'EVAKUASI') {
        _showEwsAlertModal(context, next.value!, isMapAvailable);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.emergency_share, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('SUAR', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: AppColors.textHint),
            tooltip: 'EWS Simulator',
            onPressed: () => context.push('/testing'),
          ),

          IconButton(
            icon: const Icon(
              Icons.notifications_active,
              color: AppColors.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
            ),
            onPressed: () => ref.read(ewsProvider.notifier).checkLatestThreat(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: AppColors.success, size: 12),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mesh Network Aktif',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '5 orang terhubung di sekitar Anda',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.sensors, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 16),

            ewsState.when(
              data: (result) {
                if (result == null || result.statusTindakan != 'EVAKUASI') {
                  return _buildStatusCard(
                    color: AppColors.successLight,
                    iconColor: AppColors.success,
                    icon: Icons.check_circle,
                    title: 'Tidak ada peringatan aktif',
                    subtitle: 'Kondisi saat ini aman dan terkendali.',
                  );
                }
                return _buildStatusCard(
                  color: AppColors.dangerLight,
                  iconColor: AppColors.danger,
                  icon: Icons.warning,
                  title: 'PERINGATAN AKTIF',
                  subtitle: 'Tekan untuk melihat instruksi evakuasi.',
                );
              },
              loading: () => _buildStatusCard(
                color: AppColors.infoLight,
                iconColor: AppColors.info,
                icon: Icons.sync,
                title: 'Menganalisis Cuaca & Seismik',
                subtitle: 'Menunggu respon dari AI dan BMKG...',
              ),
              error: (err, stack) => _buildStatusCard(
                color: AppColors.surface,
                iconColor: AppColors.textHint,
                icon: Icons.signal_wifi_off,
                title: 'Gagal Menghubungi Server',
                subtitle: 'Sistem beralih ke mode offline sepenuhnya.',
              ),
            ),
            const SizedBox(height: 16),

            _buildMenuCard(
              context,
              icon: Icons.chat,
              title: 'Mesh Chat',
              subtitle: 'Public Channel & Direct Message',
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              icon: mapIcon,
              iconColor: mapBadgeColor,
              title: mapTitle,
              subtitle: mapSubtitle,
              isMap: true,
              isMapAvailable: isMapAvailable,
              onTap: isMapAvailable
                  ? () => context.push('/map')
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Peta tidak dapat diakses tanpa internet! Unduh terlebih dahulu saat online.',
                          ),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    },
            ),
            const SizedBox(height: 24),

            Text(
              'SUMBER DAYA CEPAT',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildResourceButton(
                    Icons.medical_services,
                    'P3K Dasar',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildResourceButton(
                    Icons.contact_phone,
                    'Nomor Darurat',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required Color color,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(subtitle, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: iconColor),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = AppColors.primary,
    bool isMap = false,
    bool isMapAvailable = true,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textHint),
                ],
              ),
            ),
            if (isMap)
              isMapAvailable
                  ? Consumer(
                      builder: (context, ref, child) {
                        final locationAsync = ref.watch(
                          userLocationStreamProvider,
                        );

                        return Container(
                          height: 120,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.border,
                          ),
                          child: locationAsync.when(
                            data: (currentLocation) => FlutterMap(
                              options: MapOptions(
                                initialCenter: currentLocation,
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.suar.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: currentLocation,
                                      width: 30,
                                      height: 30,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLight
                                              .withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.my_location,
                                            color: AppColors.primary,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (err, stack) => const Center(
                              child: Text(
                                'Gagal memuat cuplikan peta',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 120,
                      width: double.infinity,
                      decoration: const BoxDecoration(color: AppColors.border),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              color: AppColors.textHint,
                              size: 32,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Peta ditangguhkan (Mode Offline)',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showEwsAlertModal(BuildContext context, TriageResult result, bool isMapAvailable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (context) {
        return SizedBox(
          height: double.infinity,
          child: Column(
            children: [
              // Header Merah
              Container(
                color: AppColors.dangerLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.danger),
                      // ganti ke logika hentikan alarm besok
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'SUAR EWS ALERT',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Icon(Icons.share, color: AppColors.danger),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.danger,
                        child: Icon(
                          Icons.warning,
                          size: 40,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'POTENSI TSUNAMI',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(color: AppColors.danger),
                      ),
                      const Text(
                        'Peringatan Dini di Wilayah Anda',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            'MAGNITUDE',
                            '7.8 SR',
                            '+0.2',
                            isRed: true,
                          ),
                          _buildStatCard(
                            'KEDALAMAN',
                            '10 km',
                            'Stabil',
                            isRed: false,
                          ),
                          _buildStatCard(
                            'JARAK',
                            '2.5 km',
                            'Dekat',
                            isRed: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.bottomLeft,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                color: AppColors.danger,
                                size: 10,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'LOKASI ANDA: ZONA MERAH',
                                style: TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.psychology, color: AppColors.white),
                                SizedBox(width: 8),
                                Text(
                                  'AI RECOMMENDATION',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              result.instruksiDarurat,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isMapAvailable? AppColors.white : AppColors.surface,
                                  foregroundColor: isMapAvailable? AppColors.danger : AppColors.textHint,
                                ),
                                onPressed: () {
                                  if (isMapAvailable) {
                                    Navigator.pop(context);
                                    context.push('/map');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: const Text('Peta tidak tersedia! Harap ikuti instruksi dari AI.'),
                                        backgroundColor: AppColors.warning,
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(isMapAvailable ? Icons.location_on : Icons.location_off),
                                label: Text(
                                  isMapAvailable ? 'BUKA PETA EVAKUASI' : "PETA TIDAK TERSEDIA",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String sub, {
    required bool isRed,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isRed ? AppColors.danger : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRed ? Icons.trending_up : Icons.remove,
                size: 12,
                color: isRed ? AppColors.danger : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                sub,
                style: TextStyle(
                  fontSize: 10,
                  color: isRed ? AppColors.danger : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
