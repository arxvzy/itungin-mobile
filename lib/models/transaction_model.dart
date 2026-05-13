class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.userId,
    required this.tipeTransaksi,
    required this.jumlah,
    required this.kategori,
    required this.deskripsi,
    required this.tanggal,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final String tipeTransaksi;
  final int jumlah;
  final String kategori;
  final String deskripsi;
  final String tanggal;
  final String? createdAt;
  final String? updatedAt;

  bool get isIncome => tipeTransaksi == 'pemasukan';

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        userId: (json['user_id'] as num?)?.toInt() ?? 0,
        tipeTransaksi: json['tipe_transaksi']?.toString() ?? 'pengeluaran',
        jumlah: (json['jumlah'] as num?)?.toInt() ?? 0,
        kategori: json['kategori']?.toString() ?? '',
        deskripsi: json['deskripsi']?.toString() ?? '',
        tanggal: json['tanggal']?.toString() ?? '',
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );
}

class CreateTransactionRequest {
  const CreateTransactionRequest({
    required this.tipeTransaksi,
    required this.jumlah,
    required this.kategori,
    required this.deskripsi,
    required this.tanggal,
  });

  final String tipeTransaksi;
  final int jumlah;
  final String kategori;
  final String deskripsi;
  final String tanggal;

  Map<String, dynamic> toJson() => {
    'tipe_transaksi': tipeTransaksi,
    'jumlah': jumlah,
    'kategori': kategori,
    'deskripsi': deskripsi,
    'tanggal': tanggal,
  };
}

class TransactionListResponse {
  const TransactionListResponse({
    required this.transactions,
    required this.saldo,
    required this.totalPemasukan,
    required this.totalPengeluaran,
  });

  final List<TransactionModel> transactions;
  final int saldo;
  final int totalPemasukan;
  final int totalPengeluaran;

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    final list = data['transactions'] ?? data['data'] ?? [];
    return TransactionListResponse(
      transactions: list is List
          ? list
                .map(
                  (item) => TransactionModel.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  ),
                )
                .toList()
          : const [],
      saldo: (data['saldo'] as num?)?.toInt() ?? 0,
      totalPemasukan: (data['total_pemasukan'] as num?)?.toInt() ?? 0,
      totalPengeluaran: (data['total_pengeluaran'] as num?)?.toInt() ?? 0,
    );
  }
}
