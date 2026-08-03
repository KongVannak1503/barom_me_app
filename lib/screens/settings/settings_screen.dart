import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import '../../l10n/app_localizations.dart';
import '../../models/attendance_screen_template.dart';
import '../../providers/app_lock_provider.dart';
import '../../providers/attendance_template_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/theme_provider.dart';
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
    final themeMode = ref.watch(themeProvider);
    final template = ref.watch(attendanceTemplateProvider);
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
              subtitle: Text(_themeModeLabel(themeMode, l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemePicker(context),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.view_agenda, color: AppColors.primary),
              title: Text(l10n.attendanceTemplate),
              subtitle: Text(_templateLabel(template, l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showTemplatePicker(context),
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

  Future<void> _showThemePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(themeProvider);
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.theme),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ThemeMode.system),
            child: Row(
              children: [
                Icon(current == ThemeMode.system
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.systemTheme),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ThemeMode.light),
            child: Row(
              children: [
                Icon(current == ThemeMode.light
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.lightMode),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ThemeMode.dark),
            child: Row(
              children: [
                Icon(current == ThemeMode.dark
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.darkMode),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) {
      await ref.read(themeProvider.notifier).setThemeMode(selected);
    }
  }

  String _themeModeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode;
      case ThemeMode.dark:
        return l10n.darkMode;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  Future<void> _showTemplatePicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final current = ref.read(attendanceTemplateProvider);
    final selected = await showDialog<AttendanceScreenTemplate>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.attendanceTemplate),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, AttendanceScreenTemplate.classic),
            child: Row(
              children: [
                Icon(current == AttendanceScreenTemplate.classic
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.classicTemplate),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, AttendanceScreenTemplate.punchFirst),
            child: Row(
              children: [
                Icon(current == AttendanceScreenTemplate.punchFirst
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.punchFirstTemplate),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, AttendanceScreenTemplate.compact),
            child: Row(
              children: [
                Icon(current == AttendanceScreenTemplate.compact
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.compactTemplate),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, AttendanceScreenTemplate.sessions),
            child: Row(
              children: [
                Icon(current == AttendanceScreenTemplate.sessions
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off),
                const SizedBox(width: 12),
                Text(l10n.sessionsTemplate),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) {
      await ref.read(attendanceTemplateProvider.notifier).setTemplate(selected);
    }
  }

  String _templateLabel(AttendanceScreenTemplate template, AppLocalizations l10n) {
    switch (template) {
      case AttendanceScreenTemplate.classic:
        return l10n.classicTemplate;
      case AttendanceScreenTemplate.punchFirst:
        return l10n.punchFirstTemplate;
      case AttendanceScreenTemplate.compact:
        return l10n.compactTemplate;
      case AttendanceScreenTemplate.sessions:
        return l10n.sessionsTemplate;
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
