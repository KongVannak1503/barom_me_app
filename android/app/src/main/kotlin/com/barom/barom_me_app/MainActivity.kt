package com.barom.barom_me_app

import android.content.Intent
import android.hardware.biometrics.BiometricManager
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "barom/app_lock")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openBiometricSettings" -> openBiometricSettings(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun openBiometricSettings(result: MethodChannel.Result) {
        val enrollIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            Intent(Settings.ACTION_BIOMETRIC_ENROLL)
        } else {
            Intent(Settings.ACTION_FINGERPRINT_ENROLL)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            enrollIntent.putExtra(
                Settings.EXTRA_BIOMETRIC_AUTHENTICATORS_ALLOWED,
                BiometricManager.Authenticators.BIOMETRIC_WEAK or
                    BiometricManager.Authenticators.BIOMETRIC_STRONG,
            )
        }
        try {
            startActivity(enrollIntent)
            result.success(true)
        } catch (e: Exception) {
            try {
                startActivity(Intent(Settings.ACTION_SECURITY_SETTINGS))
                result.success(true)
            } catch (e2: Exception) {
                result.error("UNAVAILABLE", "No biometric settings activity", null)
            }
        }
    }
}
