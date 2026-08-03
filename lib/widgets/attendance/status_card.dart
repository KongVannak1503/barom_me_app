import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/attendance_record.dart';
import '../../themes/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/session_helper.dart';

class StatusCard extends StatelessWidget {
  final AttendanceRecord? record;
  final List<AttendanceSession> sessions;
  final bool compact;

  const StatusCard({
    super.key,
    this.record,
    required this.sessions,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    if (compact) {
      return _buildCompact(context, now);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormatter.formatDisplay(now),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                _buildOverallStatus(context, sessions),
              ],
            ),
            const SizedBox(height: 16),
            ...sessions.map((session) => _buildSessionRow(context, session)),
            if (record?.shift != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Shift: ${record!.shift!.displayName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, DateTime now) {
    final doneCount = sessions.where((s) =>
        record?.isSessionCheckedOut(s) == true).length;
    final total = sessions.length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormatter.formatDisplay(now),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$doneCount/$total ${record?.shift != null ? '· ${record!.shift!.displayName}' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            _buildOverallStatus(context, sessions),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatus(BuildContext context, List<AttendanceSession> sessions) {
    final l10n = AppLocalizations.of(context)!;
    if (record == null) {
      return _badge(l10n.notYet, AppColors.warning);
    }

    final anyActive = sessions.any((s) =>
        record!.isSessionCheckedIn(s) && !record!.isSessionCheckedOut(s));
    final allDone = sessions.every((s) =>
        !record!.isSessionCheckedIn(s) || record!.isSessionCheckedOut(s));

    if (anyActive) return _badge(l10n.working, AppColors.success);
    if (allDone && sessions.any((s) => record!.isSessionCheckedIn(s))) {
      return _badge(l10n.complete, AppColors.textSecondary);
    }
    return _badge(l10n.notYet, AppColors.warning);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSessionRow(BuildContext context, AttendanceSession session) {
    final inTime = record?.getSessionInTime(session);
    final outTime = record?.getSessionOutTime(session);
    final isActive = inTime != null && outTime == null;
    final isDone = inTime != null && outTime != null;

    Color dotColor;
    if (isDone) {
      dotColor = AppColors.success;
    } else if (isActive) {
      dotColor = AppColors.success;
    } else {
      dotColor = AppColors.textHint;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(
              SessionHelper.label(session),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: isActive || isDone ? AppColors.textPrimary : AppColors.textHint,
              ),
            ),
          ),
          Expanded(child: _timeCell(context, 'IN', inTime, isActive)),
          const SizedBox(width: 8),
          Expanded(child: _timeCell(context, 'OUT', outTime, isActive)),
        ],
      ),
    );
  }

  Widget _timeCell(BuildContext context, String label, String? time, bool isActive) {
    final hasValue = time != null;
    return Row(
      children: [
        Text(
          '$label ',
          style: TextStyle(fontSize: 10, color: hasValue ? AppColors.textSecondary : AppColors.textHint),
        ),
        Text(
          AttendanceRecord.displayTime(time),
          style: TextStyle(
            fontSize: 13,
            fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
            color: hasValue ? (label == 'IN' ? AppColors.success : AppColors.danger) : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
