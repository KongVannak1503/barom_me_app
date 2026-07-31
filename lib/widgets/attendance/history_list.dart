import 'package:flutter/material.dart';
import '../../models/attendance_record.dart';
import '../../models/paginated_response.dart';
import '../../themes/app_colors.dart';
import '../../utils/date_formatter.dart';

class HistoryList extends StatelessWidget {
  final PaginatedResponse<AttendanceRecord>? history;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final String? error;

  const HistoryList({
    super.key,
    this.history,
    this.isLoading = false,
    this.onLoadMore,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(error!, style: const TextStyle(color: AppColors.danger)),
      );
    }

    if (isLoading && history == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = history?.data ?? [];

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('No attendance records yet', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + (history?.hasMore == true ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: TextButton(
                onPressed: onLoadMore,
                child: const Text('Load more'),
              ),
            ),
          );
        }
        return _buildHistoryItem(context, items[index]);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, AttendanceRecord record) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: record.hasCheckedIn
            ? (record.hasCheckedOut ? AppColors.textHint.withValues(alpha: 0.2) : AppColors.success.withValues(alpha: 0.2))
            : AppColors.warning.withValues(alpha: 0.2),
        child: Icon(
          record.hasCheckedOut
              ? Icons.check_circle
              : record.hasCheckedIn
                  ? Icons.play_circle
                  : Icons.pending,
          color: record.hasCheckedOut
              ? AppColors.success
              : record.hasCheckedIn
                  ? AppColors.success
                  : AppColors.warning,
          size: 20,
        ),
      ),
      title: Text(
        DateFormatter.formatDisplay(DateTime.parse(record.date)),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'In: ${record.checkInTime ?? '--'}  Out: ${record.checkOutTime ?? '--'}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: record.shift != null
          ? Text(
              record.shift!.displayName,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            )
          : null,
    );
  }
}
