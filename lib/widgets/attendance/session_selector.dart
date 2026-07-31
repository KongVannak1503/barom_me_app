import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';
import '../../utils/session_helper.dart';
import '../../themes/app_colors.dart';

class SessionSelector extends StatelessWidget {
  final AttendanceSession selectedSession;
  final AttendanceSession? detectedSession;
  final AttendanceRecord? record;
  final List<AttendanceSession> sessions;
  final ValueChanged<AttendanceSession> onChanged;

  const SessionSelector({
    super.key,
    required this.selectedSession,
    this.detectedSession,
    this.record,
    required this.sessions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: sessions.map((session) {
          final isSelected = session == selectedSession;
          final isActive = record?.isSessionCheckedIn(session) == true;
          final isCompleted = record?.isSessionCheckedOut(session) == true;
          final isDetected = session == detectedSession;

          Color bgColor;
          Color fgColor;
          if (isSelected) {
            bgColor = AppColors.primary;
            fgColor = Colors.white;
          } else if (isCompleted) {
            bgColor = AppColors.success.withValues(alpha: 0.15);
            fgColor = AppColors.success;
          } else if (isActive) {
            bgColor = AppColors.warning.withValues(alpha: 0.15);
            fgColor = AppColors.warning;
          } else if (isDetected) {
            bgColor = AppColors.primary.withValues(alpha: 0.08);
            fgColor = AppColors.primary;
          } else {
            bgColor = AppColors.border.withValues(alpha: 0.3);
            fgColor = AppColors.textHint;
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => onChanged(session),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: isDetected && !isSelected
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        SessionHelper.shortLabel(session),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: fgColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        SessionHelper.label(session),
                        style: TextStyle(
                          fontSize: 9,
                          color: fgColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
