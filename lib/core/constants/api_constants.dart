import 'package:flutter/foundation.dart';

class ApiConstants {
  static const _overrideBaseUrl = String.fromEnvironment(
    'ITUNGIN_API_BASE_URL',
  );

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    if (kDebugMode) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'http://10.0.2.2:8000/api';
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          return 'http://localhost:8000/api';
        case TargetPlatform.fuchsia:
          return 'http://localhost:8000/api';
      }
    }

    return 'https://itungin.my.id/api';
  }
}
