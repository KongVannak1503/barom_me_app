import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/leave_request.dart';
import '../../providers/leave_provider.dart';
import '../../themes/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/status_localizer.dart';

class LeaveDetailScreen extends ConsumerWidget {
  final LeaveRequest leaveRequest;

  const LeaveDetailScreen({super.key, required this.leaveRequest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaveProvider);
    final isSubmitting = state.isSubmitting;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.leaveDetails)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context, ref, isSubmitting),
          const SizedBox(height: 20),
          _buildInfoSection(l10n),
          const SizedBox(height: 20),
          _buildDetailRow(l10n.leaveType, leaveRequest.leaveType?.name ?? '-'),
          _buildDetailRow(l10n.dateRange, leaveRequest.dateRangeDisplay),
          if (leaveRequest.halfDay)
            _buildDetailRow(l10n.halfDay,
                leaveRequest.halfDaySession == 'morning' ? l10n.morning : l10n.afternoon),
          _buildDetailRow(l10n.status, statusLabel(l10n, leaveRequest.statusDisplay)),
          const SizedBox(height: 16),
          Text(l10n.reason, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              leaveRequest.reason.isNotEmpty ? leaveRequest.reason : '-',
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
            ),
          ),
          if (leaveRequest.contactDuringLeave != null && leaveRequest.contactDuringLeave!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailRow(l10n.contact, leaveRequest.contactDuringLeave!),
          ],
          if (leaveRequest.adminRemark != null && leaveRequest.adminRemark!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(l10n.adminRemark, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Text(
                leaveRequest.adminRemark!,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isSubmitting) {
    final l10n = AppLocalizations.of(context)!;
    final color = _statusColor(leaveRequest.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(leaveRequest.status), color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            leaveRequest.leaveType?.name ?? l10n.leaveRequest,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel(l10n, leaveRequest.statusDisplay),
              style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          if (leaveRequest.isCancellable) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.cancelLeave),
                            content: Text(l10n.areYouSure),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.no)),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.yes)),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await ref.read(leaveProvider.notifier).cancelLeaveRequest(leaveRequest.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.leaveCancelled)),
                              );
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${l10n.failedToCancel}: $e')),
                              );
                            }
                          }
                        }
                      },
                icon: const Icon(Icons.cancel, size: 18),
                label: Text(l10n.cancelThisRequest),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.details, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, l10n.submitted, _formatDateTime(leaveRequest.createdAt)),
          ..._buildExtraInfo(l10n),
        ],
      ),
    );
  }

  List<Widget> _buildExtraInfo(AppLocalizations l10n) {
    final rows = <Widget>[];
    if (leaveRequest.attachment != null) {
      rows.add(const SizedBox(height: 12));
      rows.add(_buildInfoRow(Icons.attach_file, l10n.attachment, leaveRequest.attachment!, isLink: true));
    }
    return rows;
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: isLink ? AppColors.info : AppColors.textPrimary,
                decoration: isLink ? TextDecoration.underline : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormatter.formatDateTime(dt);
    } catch (_) {
      return dateStr;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending': return AppColors.warning;
      case 'In Review': return AppColors.info;
      case 'Approved': return AppColors.success;
      case 'Rejected': return AppColors.danger;
      case 'Cancelled': return AppColors.textHint;
      default: return AppColors.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Pending': return Icons.hourglass_empty;
      case 'In Review': return Icons.rate_review;
      case 'Approved': return Icons.check_circle;
      case 'Rejected': return Icons.cancel;
      case 'Cancelled': return Icons.block;
      default: return Icons.info;
    }
  }
}
