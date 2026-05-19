import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../../providers/api_diagnostics_provider.dart';
import 'api_exception.dart';

class DioClient {
  DioClient(this._storage, this._diagnostics)
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
          _diagnostics.markRequest(options.method, options.path);
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          _diagnostics.markResponse(
            response.requestOptions.method,
            response.requestOptions.path,
            response.statusCode,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          final response = error.response;
          _diagnostics.markError(
            error.requestOptions.method,
            error.requestOptions.path,
            error.message ?? error.toString(),
            statusCode: response?.statusCode,
          );
          handler.next(error);
        },
      ),
    );
  }

  final SecureStorageService _storage;
  final ApiDiagnosticsProvider _diagnostics;
  final Dio dio;

  ApiException normalizeError(Object error) {
    if (error is DioException) {
      final response = error.response;
      final data = response?.data;
      if (response?.statusCode == 401) {
        unawaited(_storage.deleteToken());
        _diagnostics.markError(
          error.requestOptions.method,
          error.requestOptions.path,
          '401 Unauthorized',
          statusCode: 401,
        );
      }
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
      final isConnectionIssue =
          error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.badCertificate ||
          error.type == DioExceptionType.unknown && response == null;
      return ApiException(
        response?.statusCode == 500
            ? 'Terjadi kesalahan pada server. Silakan coba lagi.'
            : isConnectionIssue
            ? 'Tidak dapat terhubung ke server.'
            : 'Permintaan gagal. Silakan coba lagi.',
        statusCode: response?.statusCode,
      );
    }
    return ApiException('Terjadi kesalahan. Silakan coba lagi.');
  }
}
