import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fingerprint), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.beach_access), label: 'Leaves'),
          NavigationDestination(icon: Icon(Icons.how_to_reg), label: 'Approvals'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
