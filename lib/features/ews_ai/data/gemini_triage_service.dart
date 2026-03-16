import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../domain/gempa_model.dart';
import '../domain/triage_result_model.dart';

class GeminiTriageService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiTriageService({required this.apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<TriageResult> analyzeThreat({
    required GempaModel gempa,
    required bool isDiZonaMerah,
  }) async {
    try {
      final String prompt = '''
Anda adalah AI Sistem Peringatan Dini (EWS) pada aplikasi evakuasi darurat.
Tugas Anda adalah memberikan instruksi keselamatan singkat dan akurat berdasarkan dua fakta berikut:

FAKTA 1 (DATA BMKG):
- Kekuatan: ${gempa.magnitude} SR
- Kedalaman: ${gempa.kedalaman}
- Lokasi Pusat Gempa: ${gempa.wilayah}
- Status BMKG: ${gempa.potensi}

FAKTA 2 (DATA INARISK & GPS):
- Apakah pengguna saat ini berada di dalam zona merah rawan sapuan tsunami? JAWABAN: ${isDiZonaMerah ? 'YA' : 'TIDAK'}

ATURAN TRIASE:
1. Jika Status BMKG menyatakan berpotensi Tsunami DAN pengguna berada di zona merah (YA), tetapkan status "EVAKUASI" dan aktifkan peta.
2. Jika Status BMKG menyatakan berpotensi Tsunami, TETAPI pengguna TIDAK berada di zona merah, tetapkan status "BERLINDUNG". Jangan suruh evakuasi.
3. Jika Status BMKG menyatakan TIDAK berpotensi tsunami, tetapkan status "BERLINDUNG". Ingatkan protokol Drop, Cover, Hold.

Keluarkan hasil analisis Anda DALAM FORMAT JSON SEPERTI INI:
{
  "status_tindakan": "EVAKUASI / BERLINDUNG",
  "instruksi_darurat": "Instruksi maksimal 2 kalimat, tegas dan jelas",
  "aktifkan_peta": true / false
}
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final String responseText = response.text ?? '{}';

      final Map<String, dynamic> jsonMap = jsonDecode(responseText);
      
      return TriageResult.fromJson(jsonMap);

    } catch (e) {
      final bool daruratKritis = gempa.potensi.toLowerCase().contains('tsunami') && isDiZonaMerah;
      
      return TriageResult(
        statusTindakan: daruratKritis ? 'EVAKUASI' : 'BERLINDUNG',
        instruksiDarurat: daruratKritis 
            ? 'Potensi Tsunami terdeteksi! Segera menjauh dari pantai dan cari tempat tinggi!' 
            : 'Gempa bumi terdeteksi. Jauhi kaca dan berlindung di bawah meja yang kuat.',
        aktifkanPeta: daruratKritis,
      );
    }
  }
}