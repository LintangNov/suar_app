class TriageResult {
  final String statusTindakan;
  final String instruksiDarurat;
  final bool aktifkanPeta;

  TriageResult({
    required this.statusTindakan,
    required this.instruksiDarurat,
    required this.aktifkanPeta,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      statusTindakan: json['status_tindakan'] ?? 'BERLINDUNG',
      instruksiDarurat: json['instruksi_darurat'] ?? 'Terjadi guncangan. Tetap waspada dan ikuti arahan pihak berwenang.',
      aktifkanPeta: json['aktifkan_peta'] ?? false,
    );
  }
}