import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_constants.dart';
import '../services/barom_api.dart';

final sessionProvider = StateProvider<bool>((ref) => false);

Future<void> refreshSession(WidgetRef ref) async {
  final api = BaromApi();
  final token = await api.storage.read(key: ApiConstants.tokenKey);
  ref.read(sessionProvider.notifier).state = token != null && token.isNotEmpty;
}

void setSession(WidgetRef ref, bool loggedIn) {
  ref.read(sessionProvider.notifier).state = loggedIn;
}
