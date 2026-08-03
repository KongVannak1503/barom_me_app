import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/attendance_record.dart';
import '../../themes/app_colors.dart';
import '../../utils/session_helper.dart';

class SessionPunchList extends StatelessWidget {
  final AttendanceRecord? record;
  final List<AttendanceSession> sessions;
  final bool isLoading;
  final bool isSyncing;
  final void Function(AttendanceSession session, {required bool isOut}) onPunch;

  const SessionPunchList({
    super.key,
    required this.record,
    required this.sessions,
    required this.isLoading,
    this.isSyncing = false,
    required this.onPunch,
  });

  static String _icon(AttendanceSession session) {
    switch (session) {
      case AttendanceSession.morning:
        return '☀';
      case AttendanceSession.afternoon:
        return '🌙';
      case AttendanceSession.evening:
        return '🌆';
      case AttendanceSession.night:
        return '🌃';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isSyncing && record == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      children: sessions.map((session) => _buildSession(context, session)).toList(),
    );
  }

  Widget _buildSession(BuildContext context, AttendanceSession session) {
    final isCheckedIn = record?.isSessionCheckedIn(session) == true;
    final isCheckedOut = record?.isSessionCheckedOut(session) == true;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  _icon(session),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  SessionHelper.label(session),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                _statusChip(context, session, isCheckedIn, isCheckedOut),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            if (isCheckedOut)
              const SizedBox(height: 12)
            else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading || isCheckedIn
                          ? null
                          : () => onPunch(session, isOut: false),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Check In'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading || !isCheckedIn || isCheckedOut
                          ? null
                          : () => onPunch(session, isOut: true),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Check Out'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _timeRow(context, 'IN', AttendanceRecord.displayTime(record?.getSessionInTime(session))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _timeRow(context, 'OUT', AttendanceRecord.displayTime(record?.getSessionOutTime(session))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(
    BuildContext context,
    AttendanceSession session,
    bool isCheckedIn,
    bool isCheckedOut,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final String label;
    final Color color;
    if (isCheckedOut) {
      label = l10n.complete;
      color = AppColors.success;
    } else if (isCheckedIn) {
      label = l10n.working;
      color = AppColors.warning;
    } else {
      label = l10n.notYet;
      color = AppColors.textHint;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _timeRow(BuildContext context, String label, String time) {
    final hasValue = time != '--:--';
    return Row(
      children: [
        Text(
          '$label ',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: hasValue ? FontWeight.w600 : FontWeight.normal,
            color: hasValue ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
