import 'package:flutter/material.dart';

class ApiDiagnosticsProvider extends ChangeNotifier {
  ApiDiagnosticsProvider(this.baseUrl);

  final String baseUrl;

  String? lastRequest;
  int? lastStatusCode;
  String? lastError;
  DateTime? lastUpdatedAt;

  void markRequest(String method, String path) {
    lastRequest = '$method $path';
    lastStatusCode = null;
    lastError = null;
    lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  void markResponse(String method, String path, int? statusCode) {
    lastRequest = '$method $path';
    lastStatusCode = statusCode;
    lastError = null;
    lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  void markError(String method, String path, String message, {int? statusCode}) {
    lastRequest = '$method $path';
    lastStatusCode = statusCode;
    lastError = message;
    lastUpdatedAt = DateTime.now();
    notifyListeners();
  }

  void clear() {
    lastRequest = null;
    lastStatusCode = null;
    lastError = null;
    lastUpdatedAt = null;
    notifyListeners();
  }

  String get summary {
    final request = lastRequest ?? 'Belum ada request';
    final status = lastStatusCode == null ? '...' : lastStatusCode.toString();
    final error = lastError;
    if (error != null && error.trim().isNotEmpty) {
      return '$request | $status | $error';
    }
    return '$request | $status';
  }
}
