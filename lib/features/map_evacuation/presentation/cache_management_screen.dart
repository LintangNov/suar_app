import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/map_cache_service.dart';
import 'map_provider.dart';

class CacheManagementScreen extends ConsumerWidget {
  const CacheManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(mapCacheStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Penyimpanan Peta'),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Peta Offline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Peta evakuasi disimpan secara lokal agar dapat digunakan tanpa koneksi internet saat krisis terjadi.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Gagal memuat data: $err'),
                data: (stats) {
                  final tileCount = stats['count'] as int;
                  final sizeMb = stats['sizeMb'] as double;

                  if (tileCount == 0) {
                    return const Column(
                      children: [
                        Icon(Icons.cloud_off, size: 48, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Belum ada peta yang diunduh', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      const Icon(Icons.sd_storage, size: 48, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        '${sizeMb.toStringAsFixed(2)} MB',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$tileCount kepingan gambar (tiles)',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const Spacer(),
            
            statsAsync.maybeWhen(
              data: (stats) => stats['count'] > 0
                  ? SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dangerLight,
                          foregroundColor: AppColors.danger,
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Peta?'),
                              content: const Text('Anda tidak akan bisa melihat peta evakuasi saat offline jika peta dihapus.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            final cacheService = MapCacheService();
                            await cacheService.clearCache();

                            ref.invalidate(mapCacheStatsProvider);
                            ref.invalidate(mapCacheStatusProvider);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Peta offline berhasil dihapus dari memori.'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Hapus Peta Offline'),
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}