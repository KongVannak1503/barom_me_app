import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_lock_provider.dart';
import '../../providers/router_provider.dart';
import '../../themes/app_colors.dart';

enum _LockView { scan, pin }

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen>
    with TickerProviderStateMixin {
  static const int _pinLength = 4;

  final List<int> _entered = [];
  late final AnimationController _shakeController;
  late final AnimationController _pulseController;
  bool _wrong = false;
  bool _busy = false;
  bool _confirmingSignOut = false;
  bool _biometricError = false;
  _LockView _view = _LockView.scan;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(appLockProvider).valueOrNull;
      if (state?.biometricEnabled == true && state?.biometricAvailable == true) {
        _pulseController.repeat(reverse: true);
        _unlockWithBiometrics();
      } else {
        _view = _LockView.pin;
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _addDigit(int digit) {
    if (_busy || _entered.length >= _pinLength) return;
    setState(() {
      _entered.add(digit);
      _wrong = false;
      _confirmingSignOut = false;
    });
    if (_entered.length == _pinLength) {
      _submit();
    }
  }

  void _removeDigit() {
    if (_busy || _entered.isEmpty) return;
    setState(() {
      _entered.removeLast();
      _wrong = false;
      _confirmingSignOut = false;
    });
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final pin = _entered.join();
    final ok = await ref.read(appLockProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      _shakeController.forward(from: 0);
      setState(() {
        _entered.clear();
        _wrong = true;
      });
    }
  }

  Future<void> _unlockWithBiometrics() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _biometricError = false;
    });
    final ok = await ref.read(appLockProvider.notifier).unlockWithBiometrics();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      setState(() => _biometricError = true);
    }
  }

  void _showPinView() {
    setState(() {
      _view = _LockView.pin;
      _entered.clear();
      _wrong = false;
      _biometricError = false;
      _confirmingSignOut = false;
    });
  }

  void _showScanView() {
    setState(() {
      _view = _LockView.scan;
      _biometricError = false;
    });
    _unlockWithBiometrics();
  }

  void _forgotPin() {
    if (_busy) return;
    if (!_confirmingSignOut) {
      setState(() => _confirmingSignOut = true);
      return;
    }
    setState(() => _busy = true);
    ref.read(appLockProvider.notifier).resetAndSignOut(ref).then((_) {
      if (!mounted) return;
      ref.read(routerProvider).go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appLockProvider).valueOrNull;
    final showBiometric =
        state?.biometricEnabled == true && state?.biometricAvailable == true;
    final showScan = showBiometric && _view == _LockView.scan;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: showScan ? _buildScanView() : _buildPinView(showBiometric),
          ),
        ),
      ),
    );
  }

  Widget _buildScanView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          l10n.appIsLocked,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.placeFingerToUnlock,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: _busy ? null : _unlockWithBiometrics,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final t = _pulseController.value;
              final scale = 1 + t * 0.12;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15 - t * 0.05),
                    border: Border.all(color: Colors.white54, width: 2),
                  ),
                  child: const Icon(Icons.fingerprint,
                      size: 80, color: Colors.white),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        if (_busy)
          Text(l10n.scanning, style: const TextStyle(color: Colors.white70))
        else if (_biometricError) ...[
          Text(
            l10n.notRecognizedTapToRetry,
            style: const TextStyle(color: Colors.amberAccent),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.reAddFingerprintHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: _busy ? null : _showPinView,
          child: Text(
            l10n.enterPinInstead,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _forgotPin,
          child: Text(
            _confirmingSignOut
                ? l10n.tapAgainToSignOutResetPin
                : l10n.forgotPin,
            style: TextStyle(
              color: _confirmingSignOut ? Colors.amberAccent : Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinView(bool showBiometric) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.fingerprint, size: 72, color: Colors.white),
        const SizedBox(height: 16),
        Text(
          l10n.appIsLocked,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          showBiometric ? l10n.enterPinOrUseBiometrics : l10n.enterPinToUnlock,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 32),
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, _) {
            final offset = (_shakeController.value * 12).toDouble();
            return Transform.translate(
              offset: Offset(offset, 0),
              child: _PinDots(
                length: _pinLength,
                filled: _entered.length,
                error: _wrong,
              ),
            );
          },
        ),
        if (_wrong) ...[
          const SizedBox(height: 12),
          Text(
            l10n.incorrectPin,
            style: const TextStyle(color: Colors.amberAccent),
          ),
        ] else if (_biometricError) ...[
          const SizedBox(height: 12),
          Text(
            l10n.biometricAuthenticationFailed,
            style: const TextStyle(color: Colors.amberAccent),
          ),
        ],
        const SizedBox(height: 32),
        _PinPad(
          enabled: !_busy,
          onDigit: _addDigit,
          onBackspace: _removeDigit,
          trailing: showBiometric
              ? IconButton(
                  onPressed: _busy ? null : _showScanView,
                  icon: const Icon(Icons.fingerprint,
                      color: Colors.white, size: 32),
                )
              : null,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _busy ? null : _forgotPin,
          child: Text(
            _confirmingSignOut
                ? l10n.tapAgainToSignOutResetPin
                : l10n.forgotPin,
            style: TextStyle(
              color: _confirmingSignOut ? Colors.amberAccent : Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

class _PinDots extends StatelessWidget {
  final int length;
  final int filled;
  final bool error;

  const _PinDots({required this.length, required this.filled, required this.error});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length, (index) {
        final isFilled = index < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 18,
          height: 18,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: error
                ? Colors.amberAccent
                : (isFilled ? Colors.white : Colors.transparent),
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      }),
    );
  }
}

class _PinPad extends StatelessWidget {
  final bool enabled;
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final Widget? trailing;

  const _PinPad({
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const rows = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (final row in rows)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final digit in row)
                _DigitButton(
                  label: '$digit',
                  enabled: enabled,
                  onTap: () => onDigit(digit),
                ),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              SizedBox(width: 72, child: Center(child: trailing))
            else
              const SizedBox(width: 72),
            _DigitButton(
              label: '0',
              enabled: enabled,
              onTap: () => onDigit(0),
            ),
            SizedBox(
              width: 72,
              child: Center(
                child: IconButton(
                  onPressed: enabled ? onBackspace : null,
                  icon: const Icon(Icons.backspace_outlined, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _DigitButton({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54, width: 1.5),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
