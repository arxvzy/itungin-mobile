import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/target_model.dart';
import '../services/target_service.dart';
import '../services/notification_service.dart';

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

  Future<bool> saveTarget(CreateTargetRequest request, {int? id}) async {
    try {
      if (id == null) {
        await _service.createTarget(request);
        // 🔥 Notifikasi Tambah Target (Sudah Pakai ID Unik)
        NotificationService.showInstantNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "Target Tabungan Dibuat! 🎯",
          body: "Semangat! Target barumu berhasil ditambahkan ke Itungin.",
        );
      } else {
        await _service.updateTarget(id, request);
        // 🔥 Notifikasi Update Target (Sudah Pakai ID Unik)
        NotificationService.showInstantNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: "Target Diperbarui! ✏️",
          body: "Perubahan pada target tabunganmu berhasil disimpan.",
        );
      }
      await fetchTargets();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addFund(int id, int amount) async {
    try {
      await _service.addFund(id, amount);
      
      // 🔥 PERBAIKAN: Ditambahkan id unik waktu agar tidak error/macet
      NotificationService.showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "Tabungan Berhasil Ditambah! 💰",
        body: "Dikit demi dikit lama-lama jadi bukit. Mantap!",
      );

      await fetchTargets();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteTarget(int id) async {
    try {
      await _service.deleteTarget(id);
      
      // 🔥 PERBAIKAN: Ditambahkan id unik waktu agar tidak error/macet
      NotificationService.showInstantNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: "Target Dihapus 🗑️",
        body: "Target tabungan telah berhasil dihapus.",
      );

      await fetchTargets();
    } catch (_) {
      errorMessage = 'Gagal menghapus target.';
      notifyListeners();
    }
  }
}