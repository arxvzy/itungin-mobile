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
          return 'https://mobile.itungin.my.id/api';
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          return 'https://mobile.itungin.my.id/api';
        case TargetPlatform.fuchsia:
          return 'https://mobile.itungin.my.id/api';
      }
    }

    return 'https://mobile.itungin.my.id/api';
  }
}
