class TriageResult {
  final String statusTindakan;
  final List<String> tindakanSegera;
  final List<String> persiapan;      
  final bool aktifkanPeta;

  TriageResult({
    required this.statusTindakan,
    required this.tindakanSegera,
    required this.persiapan,
    required this.aktifkanPeta,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      statusTindakan: json['status_tindakan'] ?? 'BERLINDUNG',
      tindakanSegera: List<String>.from(json['tindakan_segera'] ?? ['Tetap waspada dan ikuti arahan pihak berwenang.']),
      persiapan: List<String>.from(json['persiapan'] ?? ['Siapkan alat komunikasi dan dokumen penting.']),
      aktifkanPeta: json['aktifkan_peta'] ?? false,
    );
  }
}