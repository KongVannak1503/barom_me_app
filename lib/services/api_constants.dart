import 'dart:io' show Platform;

enum ApiFlavor { dev, stage, production }

class ApiConstants {
  ApiConstants._();

  static ApiFlavor _flavor = ApiFlavor.dev;

  static void setFlavor(ApiFlavor flavor) => _flavor = flavor;

  // Overridable at build time: flutter run --dart-define=API_HOST=192.168.1.10
  // so a physical phone can reach the dev backend on your LAN.
  static const String _overrideHost = String.fromEnvironment('API_HOST');

  static String get _devHost {
    if (_overrideHost.isNotEmpty) return _overrideHost;
    return Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
  }

  static String get baseUrl {
    switch (_flavor) {
      case ApiFlavor.dev:
        return 'http://$_devHost:8000/api';
      case ApiFlavor.stage:
        return 'https://staging-api.barom.me/api';
      case ApiFlavor.production:
        return 'https://barom.me/api';
    }
  }

  static String get storageBaseUrl {
    switch (_flavor) {
      case ApiFlavor.dev:
        return 'http://$_devHost:8000/storage';
      case ApiFlavor.stage:
        return 'https://staging-api.barom.me/storage';
      case ApiFlavor.production:
        return 'https://barom.me/storage';
    }
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
}
