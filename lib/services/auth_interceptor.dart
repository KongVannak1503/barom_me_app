import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  /// Bumped whenever the server rejects our token, so the router can
  /// re-run its redirect and send the user back to the login screen.
  static final ValueNotifier<int> sessionExpired = ValueNotifier(0);

  AuthInterceptor({required FlutterSecureStorage storage}) : _storage = storage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: ApiConstants.tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // A 401 from /login just means wrong credentials, not an expired session.
    final isLogin = err.requestOptions.path.endsWith('/login');
    if (err.response?.statusCode == 401 && !isLogin) {
      final hadToken = await _storage.read(key: ApiConstants.tokenKey) != null;
      await _storage.delete(key: ApiConstants.tokenKey);
      await _storage.delete(key: ApiConstants.refreshTokenKey);
      if (hadToken) sessionExpired.value++;
    }
    handler.next(err);
  }
}
