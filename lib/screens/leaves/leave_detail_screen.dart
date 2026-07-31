import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leave_request.dart';
import '../../providers/leave_provider.dart';
import '../../themes/app_colors.dart';
import '../../utils/date_formatter.dart';

class LeaveDetailScreen extends ConsumerWidget {
  final LeaveRequest leaveRequest;

  const LeaveDetailScreen({super.key, required this.leaveRequest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leaveProvider);
    final isSubmitting = state.isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Leave Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context, ref, isSubmitting),
          const SizedBox(height: 20),
          _buildInfoSection(),
          const SizedBox(height: 20),
          _buildDetailRow('Leave Type', leaveRequest.leaveType?.name ?? '-'),
          _buildDetailRow('Date Range', leaveRequest.dateRangeDisplay),
          if (leaveRequest.halfDay)
            _buildDetailRow('Half Day', leaveRequest.halfDaySession == 'morning' ? 'Morning' : 'Afternoon'),
          _buildDetailRow('Status', leaveRequest.statusDisplay),
          const SizedBox(height: 16),
          const Text('Reason', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
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
            _buildDetailRow('Contact', leaveRequest.contactDuringLeave!),
          ],
          if (leaveRequest.adminRemark != null && leaveRequest.adminRemark!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Admin Remark', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary)),
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
            leaveRequest.leaveType?.name ?? 'Leave Request',
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
              leaveRequest.statusDisplay,
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
                            title: const Text('Cancel Leave'),
                            content: const Text('Are you sure?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await ref.read(leaveProvider.notifier).cancelLeaveRequest(leaveRequest.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Leave cancelled')),
                              );
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            }
                          }
                        }
                      },
                icon: const Icon(Icons.cancel, size: 18),
                label: const Text('Cancel This Request'),
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

  Widget _buildInfoSection() {
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
          const Text('Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today, 'Submitted', _formatDateTime(leaveRequest.createdAt)),
          ..._buildExtraInfo(),
        ],
      ),
    );
  }

  List<Widget> _buildExtraInfo() {
    final rows = <Widget>[];
    if (leaveRequest.attachment != null) {
      rows.add(const SizedBox(height: 12));
      rows.add(_buildInfoRow(Icons.attach_file, 'Attachment', leaveRequest.attachment!, isLink: true));
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
