import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio Function() _createDio;

  AuthInterceptor({
    required FlutterSecureStorage storage,
    required Dio Function() createDio,
  })  : _storage = storage,
        _createDio = createDio;

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
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: ApiConstants.refreshTokenKey);
      if (refreshToken != null) {
        try {
          final dio = _createDio();
          final response = await dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
          );
          final newToken = response.data['access_token'] as String;
          await _storage.write(key: ApiConstants.tokenKey, value: newToken);

          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(opts);
          return handler.resolve(retryResponse);
        } catch (_) {
          await _storage.deleteAll();
        }
      }
    }
    handler.next(err);
  }
}
