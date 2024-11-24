class GreenhouseM {
  final int id;
  final String nama;
  final String pemilik;
  final String alamat;
  final String ukuran;
  final String gambar;
  final String pengelola;
  final double? latitude;
  final double? longitude;
  final String? telegramId;
  final String jenisTanamanId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final JenisTanaman jenisTanaman;

  GreenhouseM({
    required this.id,
    required this.nama,
    required this.pemilik,
    required this.alamat,
    required this.ukuran,
    required this.gambar,
    required this.pengelola,
    this.latitude,
    this.longitude,
    this.telegramId,
    required this.jenisTanamanId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.jenisTanaman,
  });

  factory GreenhouseM.fromJson(Map<String, dynamic> json) {
    return GreenhouseM(
      id: json['id'],
      nama: json['nama'],
      pemilik: json['pemilik'],
      alamat: json['alamat'],
      ukuran: json['ukuran'],
      gambar: json['gambar'],
      pengelola: json['pengelola'],
      latitude:
          json['latitude'] != null ? double.tryParse(json['latitude']) : null,
      longitude:
          json['longitude'] != null ? double.tryParse(json['longitude']) : null,
      telegramId: json['telegram_id'],
      jenisTanamanId: json['jenis_tanaman_id'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      jenisTanaman: JenisTanaman.fromJson(json['jenis_tanaman']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'pemilik': pemilik,
      'alamat': alamat,
      'ukuran': ukuran,
      'gambar': gambar,
      'image': gambar,
      'pengelola': pengelola,
      'latitude': latitude?.toString(),
      'longitude': longitude?.toString(),
      'telegram_id': telegramId,
      'jenis_tanaman_id': jenisTanamanId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'jenis_tanaman': jenisTanaman.toJson(),
    };
  }
}

class JenisTanaman {
  final int id;
  final String nama;

  JenisTanaman({
    required this.id,
    required this.nama,
  });

  factory JenisTanaman.fromJson(Map<String, dynamic> json) {
    return JenisTanaman(
      id: json['id'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}
