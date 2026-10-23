import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_constants.dart';
import '../services/barom_api.dart';
import 'attendance_provider.dart';
import 'leave_provider.dart';

final sessionProvider = StateProvider<bool>((ref) => false);

Future<void> refreshSession(WidgetRef ref) async {
  final api = BaromApi();
  final token = await api.storage.read(key: ApiConstants.tokenKey);
  ref.read(sessionProvider.notifier).state = token != null && token.isNotEmpty;
}

void setSession(WidgetRef ref, bool loggedIn) {
  ref.read(sessionProvider.notifier).state = loggedIn;
  if (!loggedIn) {
    // Drop the previous user's cached data so the next login starts clean.
    ref.invalidate(attendanceStatusProvider);
    ref.invalidate(attendanceHistoryProvider);
    ref.invalidate(leaveProvider);
  }
}
