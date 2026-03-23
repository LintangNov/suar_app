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
Anda adalah AI Sistem Peringatan Dini (EWS) pada aplikasi evakuasi darurat di Indonesia.
Berikan instruksi keselamatan yang sangat spesifik dan mudah dipahami berdasarkan data berikut:

FAKTA 1 (DATA BMKG):
- Kekuatan: ${gempa.magnitude} SR
- Kedalaman: ${gempa.kedalaman}
- Lokasi Pusat: ${gempa.wilayah}
- Status: ${gempa.potensi}

FAKTA 2 (DATA INARISK & GPS):
- Apakah pengguna di zona merah tsunami? JAWABAN: ${isDiZonaMerah ? 'YA' : 'TIDAK'}

ATURAN TRIASE:
1. Jika berpotensi Tsunami DAN di zona merah (YA) -> "EVAKUASI" dan aktifkan peta.
2. Jika berpotensi Tsunami TETAPI BUKAN di zona merah (TIDAK) -> "BERLINDUNG" (Jangan suruh evakuasi, suruh jauhi pantai).
3. Jika TIDAK berpotensi tsunami -> "BERLINDUNG" (Ingatkan Drop, Cover, Hold).

Keluarkan hasil analisis DALAM FORMAT JSON SEPERTI INI:
{
  "status_tindakan": "EVAKUASI / BERLINDUNG",
  "tindakan_segera": ["tindakan 1", "tindakan 2", "tindakan 3"],
  "persiapan": ["barang bawaan 1", "persiapan 2"],
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
        tindakanSegera: daruratKritis 
            ? ['Segera berlari ke dataran tinggi.', 'Jauhi area pantai dan sungai.']
            : ['Berlindung di bawah meja yang kuat.', 'Jauhi kaca dan benda yang mudah jatuh.'],
        persiapan: daruratKritis
            ? ['Bawa Tas Siaga Bencana.', 'Pakai alas kaki yang tertutup.']
            : ['Matikan kompor dan cabut gas.', 'Siapkan senter jika listrik padam.'],
        aktifkanPeta: daruratKritis,
      );
    }
  }
}