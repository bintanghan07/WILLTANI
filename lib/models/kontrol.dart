import 'package:webagro/models/perangkat.dart';

class KontrolM {
  int id;
  double suhuMin;
  double suhuMax;
  int tdsMin;
  int tdsMax;
  int kelembabanMin;
  int kelembabanMax;
  int volumeMin;
  int volumeMax;
  int perangkatId;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  Perangkat perangkat;

  KontrolM({
    required this.id,
    required this.suhuMin,
    required this.suhuMax,
    required this.tdsMin,
    required this.tdsMax,
    required this.kelembabanMin,
    required this.kelembabanMax,
    required this.volumeMin,
    required this.volumeMax,
    required this.perangkatId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.perangkat,
  });

  factory KontrolM.fromJson(Map<String, dynamic> json) {
    return KontrolM(
      id: json['id'],
      suhuMin: double.parse(json['suhu_min']),
      suhuMax: double.parse(json['suhu_max']),
      tdsMin: int.parse(json['tds_min']),
      tdsMax: int.parse(json['tds_max']),
      kelembabanMin: int.parse(json['kelembaban_min']),
      kelembabanMax: int.parse(json['kelembaban_max']),
      volumeMin: int.parse(json['volume_min']),
      volumeMax: int.parse(json['volume_max']),
      perangkatId: int.parse(json['perangkat_id']),
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
      'suhu_min': suhuMin.toString(),
      'suhu_max': suhuMax.toString(),
      'tds_min': tdsMin,
      'tds_max': tdsMax,
      'kelembaban_min': kelembabanMin,
      'kelembaban_max': kelembabanMax,
      'volume_min': volumeMin,
      'volume_max': volumeMax,
      'perangkat_id': perangkatId.toString(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'perangkat': perangkat.toJson(),
    };
  }
}
