import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leave_request.dart';
import '../../providers/leave_provider.dart';
import '../../themes/app_colors.dart';
import 'create_leave_screen.dart';
import 'leave_detail_screen.dart';

class MyLeavesScreen extends ConsumerStatefulWidget {
  const MyLeavesScreen({super.key});

  @override
  ConsumerState<MyLeavesScreen> createState() => _MyLeavesScreenState();
}

class _MyLeavesScreenState extends ConsumerState<MyLeavesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveProvider.notifier).loadInitialData();
    });
  }

  Future<void> _refresh() async {
    await ref.read(leaveProvider.notifier).refresh();
  }

  void _openCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateLeaveScreen()),
    );
  }

  void _openDetail(LeaveRequest leave) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LeaveDetailScreen(leaveRequest: leave)),
    );
  }

  Future<void> _cancelLeave(LeaveRequest leave) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Leave'),
        content: Text('Are you sure you want to cancel ${leave.leaveType?.name ?? 'leave'} request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ref.read(leaveProvider.notifier).cancelLeaveRequest(leave.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave request cancelled')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Leaves'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(LeaveState state) {
    if (state.isLoading && state.leaves.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.leaves.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(state.error!, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        _buildStatsRow(state.stats),
        const SizedBox(height: 20),
        if (state.leaves.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 48),
              child: Column(
                children: [
                  Icon(Icons.beach_access, size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text('No leave requests yet', style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  Text('Tap + to create one', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                ],
              ),
            ),
          )
        else
          ...state.leaves.map((leave) => _buildLeaveCard(leave, state)),
        if (state.isLoading && state.leaves.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final pending = stats['total_pending'] as int? ?? 0;
    final approved = stats['total_approved_this_month'] as int? ?? 0;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.hourglass_empty,
            iconColor: AppColors.warning,
            iconBgColor: AppColors.warning.withValues(alpha: 0.1),
            label: 'Pending',
            value: pending.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            iconBgColor: AppColors.success.withValues(alpha: 0.1),
            label: 'Approved',
            value: approved.toString(),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(LeaveRequest leave, LeaveState state) {
    final color = _statusColor(leave.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(leave),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (leave.leaveType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _parseColor(leave.leaveType!.color) ?? AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        leave.leaveType!.name,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      leave.statusDisplay,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(leave.dateRangeDisplay, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                ],
              ),
              if (leave.reason.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  leave.reason,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
              if (leave.isCancellable) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 30,
                    child: TextButton.icon(
                      onPressed: state.isSubmitting ? null : () => _cancelLeave(leave),
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Cancel', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger, padding: const EdgeInsets.symmetric(horizontal: 10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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

  Color? _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final c = hex.replaceFirst('#', '');
    if (c.length != 6) return null;
    return Color(int.parse('FF$c', radix: 16));
  }
}
