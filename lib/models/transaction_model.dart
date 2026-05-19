import '../core/utils/json_parsers.dart';

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
        id: parseIntValue(json['id']),
        userId: parseIntValue(json['user_id']),
        tipeTransaksi: json['tipe_transaksi']?.toString() ?? 'pengeluaran',
        jumlah: parseIntValue(json['jumlah']),
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
    required this.tanggal,
    this.kategori,
    this.deskripsi,
  });

  final String tipeTransaksi;
  final int jumlah;
  final String tanggal;
  final String? kategori;
  final String? deskripsi;

  Map<String, dynamic> toJson() {
    final payload = <String, dynamic>{
      'tipe_transaksi': tipeTransaksi,
      'jumlah': jumlah,
      'tanggal': tanggal,
    };
    final kategoriValue = kategori?.trim();
    final deskripsiValue = deskripsi?.trim();

    if (kategoriValue != null && kategoriValue.isNotEmpty) {
      payload['kategori'] = kategoriValue;
    }
    if (deskripsiValue != null && deskripsiValue.isNotEmpty) {
      payload['deskripsi'] = deskripsiValue;
    }
    return payload;
  }
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
      saldo: parseIntValue(data['saldo']),
      totalPemasukan: parseIntValue(data['total_pemasukan']),
      totalPengeluaran: parseIntValue(data['total_pengeluaran']),
    );
  }
}
