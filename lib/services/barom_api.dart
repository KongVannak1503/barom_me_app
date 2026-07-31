import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';
import 'auth_interceptor.dart';

class BaromApi {
  static BaromApi? _instance;
  late final Dio dio;
  late final FlutterSecureStorage storage;

  BaromApi._() {
    storage = const FlutterSecureStorage();
    dio = _createDio();
  }

  factory BaromApi() {
    _instance ??= BaromApi._();
    return _instance!;
  }

  Dio _createDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    d.interceptors.add(AuthInterceptor(
      storage: storage,
      createDio: _createDio,
    ));
    return d;
  }
}
