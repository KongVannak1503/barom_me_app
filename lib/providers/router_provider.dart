import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/auth/login_screen.dart';
import '../screens/attendance/my_attendance_screen.dart';
import '../screens/leaves/my_leaves_screen.dart';
import '../screens/approvals/my_approvals_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/telegram_connect_screen.dart';
import '../screens/settings/set_pin_screen.dart';
import '../widgets/common/app_shell.dart';
import '../services/api_constants.dart';

final _storage = FlutterSecureStorage();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/attendance',
    redirect: (context, state) async {
      final token = await _storage.read(key: ApiConstants.tokenKey);
      final isLoginRoute = state.matchedLocation == '/login';
      if (token == null && !isLoginRoute) return '/login';
      if (token != null && isLoginRoute) return '/attendance';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/attendance',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: MyAttendanceScreen(),
            ),
          ),
          GoRoute(
            path: '/leaves',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: MyLeavesScreen(),
            ),
          ),
          GoRoute(
            path: '/approvals',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: MyApprovalsScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, __) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'telegram',
                builder: (_, __) => const TelegramConnectScreen(),
              ),
              GoRoute(
                path: 'app-lock',
                builder: (_, __) => const SetPinScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
