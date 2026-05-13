import '../core/utils/json_parsers.dart';

class TargetModel {
  const TargetModel({
    required this.id,
    required this.userId,
    required this.namaTarget,
    required this.targetJumlah,
    required this.jumlahTerkumpul,
    required this.tanggalTarget,
    required this.status,
    required this.kategori,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String namaTarget;
  final int targetJumlah;
  final int jumlahTerkumpul;
  final String tanggalTarget;
  final String status;
  final String kategori;
  final String? createdAt;
  final String? updatedAt;

  double get progress {
    if (targetJumlah <= 0) return 0;
    return (jumlahTerkumpul / targetJumlah).clamp(0, 1).toDouble();
  }

  factory TargetModel.fromJson(Map<String, dynamic> json) => TargetModel(
    id: parseIntValue(json['id']),
    userId: parseIntValue(json['user_id']),
    namaTarget: json['nama_target']?.toString() ?? '',
    targetJumlah: parseIntValue(json['target_jumlah']),
    jumlahTerkumpul: parseIntValue(json['jumlah_terkumpul']),
    tanggalTarget: json['tanggal_target']?.toString() ?? '',
    status: json['status']?.toString() ?? 'aktif',
    kategori: json['kategori']?.toString() ?? '',
    createdAt: json['created_at']?.toString(),
    updatedAt: json['updated_at']?.toString(),
  );
}

class CreateTargetRequest {
  const CreateTargetRequest({
    required this.namaTarget,
    required this.targetJumlah,
    required this.tanggalTarget,
    required this.kategori,
  });

  final String namaTarget;
  final int targetJumlah;
  final String tanggalTarget;
  final String kategori;

  Map<String, dynamic> toJson() => {
    'nama_target': namaTarget,
    'target_jumlah': targetJumlah,
    'tanggal_target': tanggalTarget,
    'kategori': kategori,
  };
}

class TargetListResponse {
  const TargetListResponse({required this.targets, required this.saldo});

  final List<TargetModel> targets;
  final int saldo;

  factory TargetListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final list = data['targets'] ?? data['data'] ?? [];
    return TargetListResponse(
      targets: list is List
          ? list
                .map(
                  (item) => TargetModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
      saldo: parseIntValue(data['saldo']),
    );
  }
}
