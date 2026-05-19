import 'package:flutter/material.dart';

import '../core/network/api_exception.dart';
import '../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service, this._storage);

  final AuthService _service;
  final SecureStorageService _storage;

  UserModel? user;
  bool isAuthenticated = false;
  bool isLoading = false;
  String? errorMessage;

  Future<void> checkSession() async {
    isLoading = true;
    notifyListeners();
    final token = await _storage.getToken();
    if (token == null) {
      isLoading = false;
      notifyListeners();
      return;
    }
    try {
      user = await _service.getCurrentUser();
      isAuthenticated = true;
    } catch (_) {
      await _storage.deleteToken();
      isAuthenticated = false;
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    return _authenticate(() => _service.login(username, password));
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _authenticate(
      () => _service.register(
        name: name,
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  Future<bool> _authenticate(Future<AuthResponse> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await action();
      await _storage.saveToken(response.token);
      user = response.user;
      isAuthenticated = true;
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } catch (_) {
      errorMessage = 'Tidak dapat terhubung ke server.';
    }
    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {
      // Local cleanup must still happen when the server is unavailable.
    }
    await _storage.deleteToken();
    user = null;
    isAuthenticated = false;
    notifyListeners();
  }

  Future<void> handleUnauthorized() async {
    await _storage.deleteToken();
    user = null;
    isAuthenticated = false;
    errorMessage = 'Sesi habis, silakan login ulang.';
    notifyListeners();
  }
}
