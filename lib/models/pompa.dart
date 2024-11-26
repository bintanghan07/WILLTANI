import 'package:webagro/models/perangkat.dart';

class Pompa {
  int id;
  String status;
  String auto;
  String keterangan;
  int perangkatId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  Perangkat perangkat;

  Pompa({
    required this.id,
    required this.status,
    required this.auto,
    required this.keterangan,
    required this.perangkatId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.perangkat,
  });

  factory Pompa.fromJson(Map<String, dynamic> json) {
    return Pompa(
      id: json['id'],
      status: json['status'],
      auto: json['auto'],
      keterangan: json['keterangan'],
      perangkatId: json['perangkat_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      perangkat: Perangkat.fromJson(json['perangkat']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'auto': auto,
      'keterangan': keterangan,
      'perangkat_id': perangkatId.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'perangkat': perangkat.toJson(),
    };
  }
}
