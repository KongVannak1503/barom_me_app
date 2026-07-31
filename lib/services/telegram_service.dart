import 'package:dio/dio.dart';
import 'barom_api.dart';

class TelegramConnectInfo {
  final String? deepLink;
  final bool connected;
  final bool botConfigured;

  const TelegramConnectInfo({
    this.deepLink,
    required this.connected,
    required this.botConfigured,
  });

  factory TelegramConnectInfo.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return TelegramConnectInfo(
      deepLink: data['deep_link'] as String?,
      connected: data['connected'] as bool? ?? false,
      botConfigured: data['bot_configured'] as bool? ?? false,
    );
  }
}

class TelegramService {
  final Dio _dio = BaromApi().dio;

  Future<TelegramConnectInfo> getConnectInfo() async {
    final response = await _dio.get('/my-attendance/telegram/connect');
    return TelegramConnectInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> disconnect() async {
    await _dio.delete('/my-attendance/telegram');
  }
}
