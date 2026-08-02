import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import '../../l10n/app_localizations.dart';
import '../../providers/app_lock_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/session_provider.dart';
import '../../services/app_lock_service.dart';
import '../../services/barom_api.dart';
import '../../themes/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appLockProvider.notifier).refreshBiometricAvailability();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appLock = ref.watch(appLockProvider).valueOrNull;
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: Text(l10n.language),
              subtitle: Text(locale.languageCode == 'km'
                  ? l10n.khmer
                  : l10n.english),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguagePicker(context),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.telegram, color: AppColors.primary),
              title: Text(l10n.telegram),
              subtitle: Text(l10n.connectTelegramForNotifications),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/settings/telegram'),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                  title: Text(l10n.appLock),
                  subtitle: Text(appLock?.enabled == true
                      ? (appLock?.biometricEnabled == true
                          ? l10n.pinAndBiometricsLabel
                          : l10n.pinLabel)
                      : l10n.lockAppWithPinAndBiometrics),
                  trailing: Switch(
                    value: appLock?.enabled == true,
                    onChanged: (value) {
                      if (value) {
                        context.go('/settings/app-lock');
                      } else {
                        _confirmDisableLock(context, ref);
                      }
                    },
                  ),
                ),
                if (appLock?.enabled == true) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.password, color: AppColors.primary),
                    title: Text(l10n.changePin),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go('/settings/app-lock'),
                  ),
                ],
                if (appLock?.enabled == true) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.fingerprint, color: AppColors.primary),
                    title: Text(l10n.useFaceFingerprint),
                    subtitle: appLock?.biometricAvailable == true
                        ? null
                        : Text(l10n.noBiometricsAvailable),
                    trailing: Switch(
                      value: appLock?.biometricEnabled == true,
                      onChanged: appLock?.biometricAvailable == true
                          ? (value) => ref
                              .read(appLockProvider.notifier)
                              .setBiometricEnabled(value)
                          : null,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_input_antenna, color: AppColors.primary),
                    title: Text(l10n.manageBiometrics),
                    subtitle: Text(l10n.openPhoneSecurityToEnroll),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _manageBiometrics(context),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette, color: AppColors.primary),
              title: Text(l10n.theme),
              subtitle: Text(l10n.lightMode),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final api = BaromApi();
                await api.storage.deleteAll();
                setSession(ref, false);
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: Text(l10n.signOut, style: const TextStyle(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(localeProvider).languageCode;
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.language),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'en'),
            child: Row(
              children: [
                Icon(current == 'en'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.english),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'km'),
            child: Row(
              children: [
                Icon(current == 'km'
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.khmer),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) {
      await ref.read(localeProvider.notifier).setLocale(selected);
    }
  }

  Future<void> _manageBiometrics(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (Platform.isAndroid) {
      final opened = await AppLockService.instance.openBiometricEnrollment();
      if (opened) return;
    }
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addFingerprintOrFace),
        content: Text(
          Platform.isIOS || Platform.isMacOS
              ? l10n.iosEnrollInstructions
              : l10n.androidEnrollInstructions,
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDisableLock(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.disableAppLock),
        content: Text(l10n.disableAppLockMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.disable),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appLockProvider.notifier).disable();
    }
  }
}
