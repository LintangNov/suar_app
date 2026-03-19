import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:suar_app/features/map_evacuation/data/map_cache_service.dart';
import 'package:suar_app/features/map_evacuation/presentation/map_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/gempa_model.dart';
import 'ews_provider.dart';

class EwsTestingScreen extends ConsumerWidget {
  const EwsTestingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer: EWS Simulator'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Panel Pengujian Skenario AI',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih skenario di bawah ini untuk menyuapkan data dummy ke sistem Triage AI. Aplikasi akan otomatis kembali ke Beranda setelah tombol ditekan.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          _ScenarioCard(
            title: 'Skenario 1: Tsunami Kritis',
            description: 'Gempa 8.5 SR, Berpotensi Tsunami, User di Zona Merah. (Ekspektasi: Muncul Pop-up Merah EVAKUASI)',
            icon: Icons.waves,
            color: AppColors.danger,
            onTap: () {
              final dummyGempa = GempaModel(
                tanggal: '17 Mar 2026',
                jam: '20:30:00 WIB',
                dateTime: '2026-03-17T13:30:00+00:00',
                coordinates: '-8.50, 109.00',
                magnitude: '8.5',
                kedalaman: '10 km',
                wilayah: '150 km Barat Daya KAB-PANGANDARAN',
                potensi: 'Berpotensi TSUNAMI untuk diteruskan pada masyarakat',
                dirasakan: 'V-VI Pangandaran, IV Cilacap',
                shakemapUrl: '',
              );

              ref.read(ewsProvider.notifier).triggerMockThreat(
                dummyGempa: dummyGempa,
                dummyIsDiZonaMerah: true,
              );

              context.pop();
            },
          ),
          const SizedBox(height: 16),

          _ScenarioCard(
            title: 'Skenario 2: Gempa Ringan Darat',
            description: 'Gempa 5.2 SR, Tidak Berpotensi Tsunami. (Ekspektasi: Muncul Banner Oranye BERLINDUNG di Home)',
            icon: Icons.dashboard_customize,
            color: AppColors.warning,
            onTap: () {
              final dummyGempa = GempaModel(
                tanggal: '17 Mar 2026',
                jam: '10:15:00 WIB',
                dateTime: '2026-03-17T03:15:00+00:00',
                coordinates: '-7.80, 110.36',
                magnitude: '5.2',
                kedalaman: '80 km',
                wilayah: '10 km Tenggara KOTA-YOGYAKARTA',
                potensi: 'Tidak berpotensi tsunami',
                dirasakan: 'III Yogyakarta',
                shakemapUrl: '',
              );

              ref.read(ewsProvider.notifier).triggerMockThreat(
                dummyGempa: dummyGempa,
                dummyIsDiZonaMerah: false,
              );

              context.pop();
            },
          ),
          const SizedBox(height: 16,),

          _ScenarioCard(
            title: 'Skenario 3: Masuk Zona Merah',
            description: 'GPS mendeteksi Anda masuk ke zona rawan tsunami saat cuaca aman. (Ekspektasi: Peta offline mulai diunduh otomatis di background)',
            icon: Icons.download_for_offline,
            color: AppColors.info,
            onTap: () async {
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Expanded(child: Text('Simulasi: Memasuki Zona Merah. Mengunduh peta radius 3KM...')),
                    ],
                  ),
                  backgroundColor: AppColors.info,
                  duration: Duration(seconds: 4),
                ),
              );

              final messenger = ScaffoldMessenger.of(context);

              context.pop();

              try {
                final locService = ref.read(locationServiceProvider);
                final position = await locService.getCurrentPosition();
                final centerPoint = LatLng(position.latitude, position.longitude);

                final cacheService = MapCacheService();
                await cacheService.downloadMapRadius(centerPoint, radiusInMeters: 3000);

                messenger.showSnackBar(
               const SnackBar(
                 content: Row(
                   children: [
                     Icon(Icons.check_circle, color: AppColors.white),
                     SizedBox(width: 12),
                     Text('Peta Offline 3KM Siap Digunakan!'),
                   ],
                 ),
                 backgroundColor: AppColors.success,
                 duration: Duration(seconds: 5),
               ),
             );
             ref.invalidate(mapCacheStatusProvider);
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Gagal menyimpan peta: $e'),
                    duration: const Duration(seconds: 4),
                  )
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ScenarioCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: AppColors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_arrow, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}