import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/target_model.dart';
import '../services/target_service.dart';
import '../widgets/app_shell.dart'; //  SINKRONISASI RELATIF

class TargetProvider extends ChangeNotifier {
  TargetProvider(this._service);

  final TargetService _service;
  List<TargetModel> targets = [];
  int saldo = 0;
  bool isLoading = false;
  String? errorMessage;

  int get totalTarget =>
      targets.fold(0, (sum, item) => sum + item.jumlahTerkumpul);
  int get completedCount =>
      targets.where((item) => item.status == 'tercapai').length;
  int get activeCount => targets.length - completedCount;

  Future<void> fetchTargets() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getTargets();
      targets = response.targets;
      saldo = response.saldo;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Tidak dapat memuat target.';
    }
    isLoading = false;
    notifyListeners();
  }

  // TAMBAH CONTEXT & NOTIFIKASI SIMPAN/UPDATE
  Future<bool> saveTarget(BuildContext context, CreateTargetRequest request, {int? id}) async {
    try {
      if (id == null) {
        await _service.createTarget(request);
        showSnack(context, 'Target tabungan baru berhasil dibuat!');
      } else {
        await _service.updateTarget(id, request);
        showSnack(context, 'Perubahan target berhasil disimpan!');
      }
      await fetchTargets();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  // TAMBAH CONTEXT & NOTIFIKASI TAMBAH DANA
  Future<bool> addFund(BuildContext context, int id, int amount) async {
    try {
      await _service.addFund(id, amount);
      showSnack(context, 'Dana berhasil ditambahkan ke target!');
      await fetchTargets();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  // TAMBAH CONTEXT & NOTIFIKASI HAPUS
  Future<bool> deleteTarget(BuildContext context, int id) async {
    try {
      await _service.deleteTarget(id);
      showSnack(context, 'Target tabungan berhasil dihapus!');
      await fetchTargets();
      return true;
    } catch (_) {
      errorMessage = 'Gagal menghapus target.';
      notifyListeners();
      return false;
    }
  }
}