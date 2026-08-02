import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/attendance')) return 0;
    if (location.startsWith('/leaves')) return 1;
    if (location.startsWith('/approvals')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/attendance');
            case 1: context.go('/leaves');
            case 2: context.go('/approvals');
            case 3: context.go('/settings');
          }
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.fingerprint), label: l10n.attendance),
          NavigationDestination(icon: const Icon(Icons.beach_access), label: l10n.leaves),
          NavigationDestination(icon: const Icon(Icons.how_to_reg), label: l10n.approvals),
          NavigationDestination(icon: const Icon(Icons.settings), label: l10n.settings),
        ],
      ),
    );
  }
}
