import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../data/bmkg_service.dart';
import '../data/location_service.dart';
import '../data/inarisk_service.dart';
import '../data/gemini_triage_service.dart';
import '../domain/triage_result_model.dart';
import '../domain/gempa_model.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final bmkgServiceProvider = Provider<BmkgService>((ref) {
  return BmkgService(ref.watch(dioProvider));
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final inariskServiceProvider = Provider<InaRiskService>((ref) {
  return InaRiskService(ref.watch(dioProvider));
});

final geminiTriageServiceProvider = Provider<GeminiTriageService>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? ''; 
  return GeminiTriageService(apiKey: apiKey);
});


class EwsNotifier extends AsyncNotifier<TriageResult?> {
  
  @override
  Future<TriageResult?> build() async {
    return null; 
  }

  Future<void> checkLatestThreat() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final bmkgService = ref.read(bmkgServiceProvider);
      final gempa = await bmkgService.fetchLatestEarthquake();

      final locService = ref.read(locationServiceProvider);
      final position = await locService.getCurrentPosition();

      final inariskService = ref.read(inariskServiceProvider);
      final isDiZonaMerah = await inariskService.checkTsunamiHazard(
        position.latitude,
        position.longitude,
      );

      final geminiService = ref.read(geminiTriageServiceProvider);
      final finalResult = await geminiService.analyzeThreat(
        gempa: gempa,
        isDiZonaMerah: isDiZonaMerah,
      );

      return finalResult;
    });
  }

  Future<void> triggerMockThreat({
    required GempaModel dummyGempa,
    required bool dummyIsDiZonaMerah,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final geminiService = ref.read(geminiTriageServiceProvider);
      final finalResult = await geminiService.analyzeThreat(
        gempa: dummyGempa,
        isDiZonaMerah: dummyIsDiZonaMerah,
      );

      return finalResult;
    });
  }
}

final ewsProvider = AsyncNotifierProvider<EwsNotifier, TriageResult?>(() {
  return EwsNotifier();
});