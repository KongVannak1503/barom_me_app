import 'dart:async';
import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/session_helper.dart';

class ClockButton extends StatefulWidget {
  final AttendanceSession session;
  final bool isCheckedIn;
  final bool isCheckedOut;
  final bool isLoading;
  final VoidCallback? onClockIn;
  final VoidCallback? onClockOut;

  const ClockButton({
    super.key,
    required this.session,
    this.isCheckedIn = false,
    this.isCheckedOut = false,
    this.isLoading = false,
    this.onClockIn,
    this.onClockOut,
  });

  @override
  State<ClockButton> createState() => _ClockButtonState();
}

class _ClockButtonState extends State<ClockButton> {
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canClockIn = !widget.isCheckedIn && !widget.isCheckedOut && !widget.isLoading;
    final canClockOut = widget.isCheckedIn && !widget.isCheckedOut && !widget.isLoading;
    final disabled = (!canClockIn && !canClockOut) || (widget.isCheckedIn && widget.isCheckedOut);
    final sessionLabel = SessionHelper.label(widget.session);
    final isMorning = widget.session == AttendanceSession.morning;

    String buttonLabel;
    IconData icon;
    Color bgColor;

    if (widget.isLoading) {
      buttonLabel = '';
      icon = Icons.fingerprint;
      bgColor = AppColors.primary;
    } else if (!widget.isCheckedIn) {
      buttonLabel = '$sessionLabel In';
      icon = isMorning ? Icons.wb_sunny_outlined : Icons.fingerprint;
      bgColor = AppColors.success;
    } else if (widget.isCheckedIn && !widget.isCheckedOut) {
      buttonLabel = '$sessionLabel Out';
      icon = Icons.logout;
      bgColor = AppColors.danger;
    } else {
      buttonLabel = '$sessionLabel Done';
      icon = Icons.check_circle;
      bgColor = AppColors.textHint;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 72,
        child: ElevatedButton(
          onPressed: disabled ? null : (canClockIn ? widget.onClockIn : canClockOut ? widget.onClockOut : null),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: disabled ? 0 : 4,
          ),
          child: widget.isLoading
              ? const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 24),
                    const SizedBox(height: 4),
                    Text(
                      disabled ? buttonLabel : '$buttonLabel  ${DateFormatter.formatTime(_now)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
