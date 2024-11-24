class JenisTanaman {
  int id;
  String nama;

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
