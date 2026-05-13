import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class DioClient {
  DioClient(this._storage)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final SecureStorageService _storage;
  final Dio dio;

  ApiException normalizeError(Object error) {
    if (error is DioException) {
      final response = error.response;
      final data = response?.data;
      if (data is Map) {
        final errors = <String, List<String>>{};
        final rawErrors = data['errors'];
        if (rawErrors is Map) {
          rawErrors.forEach((key, value) {
            errors[key.toString()] = value is List
                ? value.map((item) => item.toString()).toList()
                : [value.toString()];
          });
        }
        final message =
            data['message']?.toString() ??
            (response?.statusCode == 500
                ? 'Terjadi kesalahan pada server. Silakan coba lagi.'
                : 'Permintaan gagal. Silakan coba lagi.');
        if (kDebugMode && response?.statusCode == 500) {
          debugPrint('API 500: ${response?.data}');
        }
        return ApiException(
          message,
          statusCode: response?.statusCode,
          errors: errors,
        );
      }
      return ApiException(
        response?.statusCode == 500
            ? 'Terjadi kesalahan pada server. Silakan coba lagi.'
            : 'Tidak dapat terhubung ke server.',
        statusCode: response?.statusCode,
      );
    }
    return ApiException('Terjadi kesalahan. Silakan coba lagi.');
  }
}
