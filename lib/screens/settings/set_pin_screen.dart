import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/app_lock_provider.dart';
import '../../themes/app_colors.dart';

class SetPinScreen extends ConsumerStatefulWidget {
  const SetPinScreen({super.key});

  @override
  ConsumerState<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends ConsumerState<SetPinScreen> {
  static const int _pinLength = 4;

  final List<int> _first = [];
  final List<int> _second = [];
  String? _error;
  bool _busy = false;

  bool get _confirming => _first.length == _pinLength;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_confirming ? l10n.confirmPin : l10n.setAppLockPin),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.lock_outline, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                _confirming ? l10n.reenterSamePin : l10n.chooseFourDigitPin,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _Dots(
                length: _pinLength,
                filled: _confirming ? _second.length : _first.length,
                error: _error != null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 32),
              _PinPad(
                onDigit: _addDigit,
                onBackspace: _removeDigit,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _busy ? null : () => context.go('/settings'),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addDigit(int digit) {
    if (_busy) return;
    setState(() {
      _error = null;
      if (_confirming) {
        if (_second.length < _pinLength) {
          _second.add(digit);
        }
        if (_second.length == _pinLength) {
          _validate();
        }
      } else {
        if (_first.length < _pinLength) {
          _first.add(digit);
        }
      }
    });
  }

  void _removeDigit() {
    if (_busy) return;
    setState(() {
      _error = null;
      if (_confirming) {
        if (_second.isNotEmpty) _second.removeLast();
      } else {
        if (_first.isNotEmpty) _first.removeLast();
      }
    });
  }

  Future<void> _validate() async {
    final first = _first.join();
    final second = _second.join();
    if (first != second) {
      setState(() {
        _second.clear();
        _error = AppLocalizations.of(context)!.pinsDoNotMatch;
      });
      return;
    }

    setState(() => _busy = true);
    final enabled = ref.read(appLockProvider).valueOrNull?.enabled ?? false;
    final notifier = ref.read(appLockProvider.notifier);
    if (enabled) {
      await notifier.changePin(first);
    } else {
      await notifier.enable(first);
    }
    if (!mounted) return;
    context.go('/settings');
  }
}

class _Dots extends StatelessWidget {
  final int length;
  final int filled;
  final bool error;

  const _Dots({required this.length, required this.filled, required this.error});

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
                ? AppColors.danger
                : (isFilled ? AppColors.primary : Colors.transparent),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        );
      }),
    );
  }
}

class _PinPad extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;

  const _PinPad({required this.onDigit, required this.onBackspace});

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
                  onTap: () => onDigit(digit),
                ),
            ],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 72),
            _DigitButton(
              label: '0',
              onTap: () => onDigit(0),
            ),
            SizedBox(
              width: 72,
              child: Center(
                child: IconButton(
                  onPressed: onBackspace,
                  icon: const Icon(Icons.backspace_outlined, color: AppColors.primary),
                  tooltip: AppLocalizations.of(context)?.delete,
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
  final VoidCallback? onTap;

  const _DigitButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
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
