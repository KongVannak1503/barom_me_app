import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_lock_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/router_provider.dart';
import 'providers/session_provider.dart';
import 'screens/lock/app_lock_screen.dart';
import 'themes/app_theme.dart';

class BaromMeApp extends ConsumerStatefulWidget {
  const BaromMeApp({super.key});

  @override
  ConsumerState<BaromMeApp> createState() => _BaromMeAppState();
}

class _BaromMeAppState extends ConsumerState<BaromMeApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshSession(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final appLock = ref.watch(appLockProvider);
    final session = ref.watch(sessionProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'BAROM.ME',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('km')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        if (appLock.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final showLock = appLock.valueOrNull?.locked == true && session;
        return Stack(
          children: [
            if (child != null) child,
            if (showLock) const AppLockScreen(),
          ],
        );
      },
    );
  }
}
