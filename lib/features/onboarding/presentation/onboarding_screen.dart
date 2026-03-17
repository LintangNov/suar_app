import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suar_app/core/theme/app_colors.dart';
import 'package:suar_app/features/onboarding/onboarding_provider.dart';

class OnboardingScreen extends ConsumerWidget{
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back),
        title: const Text('Nanti Ganti Aja'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Identitas & Izin', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),),
            const SizedBox(height: 8,),
            Text(
              "Aktifkan fitur bantuan untuk memastikan Anda tetap terhubung saat darurat.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32,),

            Text('Nama Lengkap', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textPrimary),),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(hintText: 'Contoh: Budi Santoso')),
            const SizedBox(height: 16),
            
            Text('Pengenal Tambahan (Opsional)', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextFormField(decoration: const InputDecoration(hintText: 'Contoh: Ayah - Keluarga Santoso')),
            const SizedBox(height: 32),

            Text('AKSES DIBUTUHKAN', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: const [
                _PermissionCard(icon: Icons.location_on, title: 'GPS', subtitle: 'Lokasi Presisi'),
                _PermissionCard(icon: Icons.bluetooth, title: 'Bluetooth', subtitle: 'Koneksi Mesh'),
                _PermissionCard(icon: Icons.wifi, title: 'Wi-Fi', subtitle: 'Sinyal P2P'),
                _PermissionCard(icon: Icons.battery_charging_full, title: 'Baterai', subtitle: 'Tanpa Batasan'),
              ],
            ),
            const SizedBox(height: 32,),

            Text(
              'Dengan mengaktifkan, Anda mengizinkan SUAR untuk mengirimkan sinyal darurat dari perangkat Anda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: (){
                  ref.read(onboardingStateProvider.notifier).completeOnboarding();
                },
                icon: const Icon(Icons.bolt, color: AppColors.white,),
                label: const Text('Aktifkan SUAR', style: TextStyle(fontSize: 16),),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PermissionCard({required this.icon, required this.title, required this.subtitle});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20,),
          ),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
      );
  }
}