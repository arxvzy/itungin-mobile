import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
// IMPORT SERVICE NOTIFIKASI
import '../services/notification_service.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider(this._service);

  final TransactionService _service;
  List<TransactionModel> transactions = [];
  int saldo = 0;
  int totalPemasukan = 0;
  int totalPengeluaran = 0;
  String currentFilter = 'semua';
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchTransactions({String filter = 'semua'}) async {
    currentFilter = filter;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getTransactions(filter: filter);
      transactions = response.transactions;
      saldo = response.saldo;
      totalPemasukan = response.totalPemasukan;
      totalPengeluaran = response.totalPengeluaran;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Tidak dapat memuat transaksi.';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> saveTransaction(
    CreateTransactionRequest request, {
    int? id,
  }) async {
    try {
      if (id == null) {
        await _service.createTransaction(request);
        // 🔥 Notifikasi Tambah Transaksi (Sudah Pakai ID Unik)
        NotificationService.showInstantNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "Catatan Keuangan Diperbarui! 💸",
          body: "Transaksi baru kamu telah berhasil disimpan ke Itungin.",
        );
      } else {
        await _service.updateTransaction(id, request);
        // 🔥 PERBAIKAN: Ditambahkan id unik waktu untuk Update Transaksi
        NotificationService.showInstantNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "Transaksi Diperbarui! ✏️",
          body: "Data transaksi keuanganmu berhasil diubah.",
        );
      }
      await fetchTransactions(filter: currentFilter);
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _service.deleteTransaction(id);
      
      // 🔥 PERBAIKAN: Ditambahkan id unik waktu untuk Hapus Transaksi
      NotificationService.showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "Transaksi Dihapus 🗑️",
        body: "Catatan transaksi berhasil dihapus dari sistem.",
      );

      await fetchTransactions(filter: currentFilter);
    } catch (_) {
      errorMessage = 'Gagal menghapus transaksi.';
      notifyListeners();
    }
  }
}