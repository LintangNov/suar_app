class GempaModel {
  final String tanggal;
  final String jam;
  final String dateTime;
  final String coordinates; // latlong
  final String magnitude;
  final String kedalaman;
  final String wilayah;
  final String potensi;
  final String dirasakan;
  final String shakemapUrl;

  GempaModel({
    required this.tanggal,
    required this.jam,
    required this.dateTime,
    required this.coordinates,
    required this.magnitude,
    required this.kedalaman,
    required this.wilayah,
    required this.potensi,
    required this.dirasakan,
    required this.shakemapUrl,
  });

  factory GempaModel.fromJson(Map<String, dynamic> json) {
    final gempa = json['Infogempa']['gempa'];
    
    return GempaModel(
      tanggal: gempa['Tanggal'] ?? '',
      jam: gempa['Jam'] ?? '',
      dateTime: gempa['DateTime'] ?? '',
      coordinates: gempa['Coordinates'] ?? '',
      magnitude: gempa['Magnitude'] ?? '',
      kedalaman: gempa['Kedalaman'] ?? '',
      wilayah: gempa['Wilayah'] ?? '',
      potensi: gempa['Potensi'] ?? '',
      dirasakan: gempa['Dirasakan'] ?? 'Tidak ada data',
      shakemapUrl: gempa['Shakemap'] != null 
          ? 'https://static.bmkg.go.id/${gempa['Shakemap']}' 
          : '',
    );
  }
}