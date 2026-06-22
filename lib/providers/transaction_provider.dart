import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../widgets/app_shell.dart'; 

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
    BuildContext context, // 
    CreateTransactionRequest request, {
    int? id,
  }) async {
    try {
      if (id == null) {
        await _service.createTransaction(request);
        showSnack(context, 'Transaksi baru berhasil disimpan!');
      } else {
        await _service.updateTransaction(id, request);
        showSnack(context, 'Perubahan transaksi berhasil disimpan!');
      }
      await fetchTransactions(filter: currentFilter);
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  // UPDATE: Menambahkan BuildContext dan mengubah return type menjadi Future<bool>
  // agar screen tahu kalau proses hapus selesai dan sukses.
  Future<bool> deleteTransaction(BuildContext context, int id) async { 
    try {
      await _service.deleteTransaction(id);
      
      // 🌟 NOTIFIKASI BERHASIL HAPUS
      showSnack(context, 'Transaksi berhasil dihapus! ');
      
      await fetchTransactions(filter: currentFilter);
      return true;
    } catch (e) {
      errorMessage = 'Gagal menghapus transaksi.';
      notifyListeners();
      return false;
    }
  }
}