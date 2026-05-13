import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._service);

  final DashboardService _service;
  DashboardModel? dashboard;
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchDashboard() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      dashboard = await _service.getDashboard();
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Tidak dapat memuat dashboard.';
    }
    isLoading = false;
    notifyListeners();
  }
}
