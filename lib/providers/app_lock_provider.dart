import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_lock_service.dart';
import '../services/barom_api.dart';
import 'session_provider.dart';

class AppLockState {
  final bool enabled;
  final bool locked;
  final bool biometricEnabled;
  final bool biometricAvailable;

  const AppLockState({
    required this.enabled,
    required this.locked,
    required this.biometricEnabled,
    required this.biometricAvailable,
  });

  AppLockState copyWith({
    bool? enabled,
    bool? locked,
    bool? biometricEnabled,
    bool? biometricAvailable,
  }) {
    return AppLockState(
      enabled: enabled ?? this.enabled,
      locked: locked ?? this.locked,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    );
  }
}

final appLockProvider =
    AsyncNotifierProvider<AppLockNotifier, AppLockState>(AppLockNotifier.new);

class AppLockNotifier extends AsyncNotifier<AppLockState> {
  final AppLockService _service = AppLockService.instance;
  AppLifecycleListener? _lifecycleListener;

  @override
  Future<AppLockState> build() async {
    final enabled = await _service.isEnabled();
    final biometricEnabled = enabled && await _service.isBiometricEnabled();
    final biometricAvailable = await _service.canUseBiometrics();

    _lifecycleListener = AppLifecycleListener(
      onPause: _lockIfEnabled,
      onHide: _lockIfEnabled,
    );
    ref.onDispose(() => _lifecycleListener?.dispose());

    return AppLockState(
      enabled: enabled,
      locked: enabled,
      biometricEnabled: biometricEnabled,
      biometricAvailable: biometricAvailable,
    );
  }

  void _lockIfEnabled() {
    final current = state.valueOrNull;
    if (current != null && current.enabled && !current.locked) {
      state = AsyncData(current.copyWith(locked: true));
    }
  }

  Future<bool> unlockWithPin(String pin) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    final ok = await _service.verifyPin(pin);
    if (ok) {
      state = AsyncData(current.copyWith(locked: false));
    }
    return ok;
  }

  Future<bool> unlockWithBiometrics() async {
    final current = state.valueOrNull;
    if (current == null || !current.biometricEnabled) return false;
    final ok = await _service.authenticateWithBiometrics();
    if (ok) {
      state = AsyncData(current.copyWith(locked: false));
    }
    return ok;
  }

  Future<void> enable(String pin) async {
    await _service.setPin(pin);
    final available = await _service.canUseBiometrics();
    final biometricEnabled = available;
    await _service.setBiometricEnabled(biometricEnabled);
    state = AsyncData(
      (state.valueOrNull ?? const AppLockState(
          enabled: false, locked: false, biometricEnabled: false, biometricAvailable: false))
          .copyWith(
        enabled: true,
        locked: false,
        biometricEnabled: biometricEnabled,
        biometricAvailable: available,
      ),
    );
  }

  Future<void> refreshBiometricAvailability() async {
    final current = state.valueOrNull;
    if (current == null) return;
    final available = await _service.canUseBiometrics();
    if (available != current.biometricAvailable) {
      state = AsyncData(current.copyWith(biometricAvailable: available));
    }
  }

  Future<void> changePin(String pin) async {
    await _service.setPin(pin);
  }

  Future<void> disable() async {
    await _service.disable();
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        enabled: false,
        locked: false,
        biometricEnabled: false,
      ));
    }
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _service.setBiometricEnabled(value);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(biometricEnabled: value));
    }
  }

  Future<void> resetAndSignOut(WidgetRef ref) async {
    await _service.disable();
    final api = BaromApi();
    await api.storage.deleteAll();
    setSession(ref, false);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncData(current.copyWith(
        enabled: false,
        locked: false,
        biometricEnabled: false,
      ));
    }
  }
}
