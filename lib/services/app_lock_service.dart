import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class AppLockService {
  AppLockService._();

  static final AppLockService instance = AppLockService._();

  static const String _pinKey = 'app_lock_pin_hash';
  static const String _saltKey = 'app_lock_pin_salt';
  static const String _biometricKey = 'app_lock_biometric_enabled';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _auth = LocalAuthentication();
  static const MethodChannel _channel = MethodChannel('barom/app_lock');

  /// Opens the device's biometric (fingerprint/face) enrollment screen.
  /// Returns true if a settings screen was opened, false otherwise.
  Future<bool> openBiometricEnrollment() async {
    if (!Platform.isAndroid) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('openBiometricSettings');
      return ok == true;
    } catch (_) {
      return false;
    }
  }

  String _hash(String salt, String pin) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  Future<bool> isEnabled() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _pinKey, value: _hash(salt, pin));
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null || stored.isEmpty) return false;
    final salt = await _storage.read(key: _saltKey) ?? '';
    return _hash(salt, pin) == stored;
  }

  Future<void> disable() async {
    await _storage.delete(key: _pinKey);
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _biometricKey);
  }

  Future<bool> isBiometricEnabled() async =>
      await _storage.read(key: _biometricKey) == 'true';

  Future<void> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      await _storage.write(key: _biometricKey, value: 'true');
    } else {
      await _storage.delete(key: _biometricKey);
    }
  }

  Future<bool> canUseBiometrics() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      if (!await _auth.canCheckBiometrics) return false;
      final available = await _auth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock BAROM.ME',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Unlock BAROM.ME',
            signInHint: 'Place your finger to unlock',
            cancelButton: 'Enter PIN instead',
          ),
          IOSAuthMessages(
            localizedFallbackTitle: 'Enter PIN',
          ),
        ],
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        sensitiveTransaction: false,
      );
    } catch (_) {
      return false;
    }
  }

  String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }
}
