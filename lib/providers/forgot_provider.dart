import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotProvider extends ChangeNotifier {
  // 🔥 GANTI SESUAIKAN DENGAN URL HOSTING/API KAMU
  final String baseUrl = 'https://mobile.itungin.my.id/api';

  bool isLoading = false;
  String? errorMessage;

  // 1. Kirim OTP ke Email
  Future<bool> sendOtp(String email) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Accept': 'application/json'},
        body: {'email': email},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = data['message'] ?? 'Gagal mengirim OTP.';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan koneksi.';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // 2. Verifikasi OTP
  Future<bool> verifyOtp(String email, String otpCode) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'otp_code': otpCode,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = data['message'] ?? 'Kode OTP salah.';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan koneksi.';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  // 3. Reset Password Baru
  Future<bool> resetPassword({
    required String email,
    required String otpCode,
    required String password,
    required String passwordConfirmation,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Accept': 'application/json'},
        body: {
          'email': email,
          'otp_code': otpCode,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = data['message'] ?? 'Gagal mereset password.';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan koneksi.';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}