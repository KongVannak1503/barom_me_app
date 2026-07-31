import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../themes/app_colors.dart';

class MyApprovalsScreen extends ConsumerWidget {
  const MyApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Approvals')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_reg, size: 64, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('Approvals coming soon', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
