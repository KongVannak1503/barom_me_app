import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/outside_work_request.dart';
import '../../providers/outside_work_provider.dart';
import '../../themes/app_colors.dart';
import '../../utils/status_localizer.dart';

class MyOutsideWorkScreen extends ConsumerStatefulWidget {
  const MyOutsideWorkScreen({super.key});

  @override
  ConsumerState<MyOutsideWorkScreen> createState() =>
      _MyOutsideWorkScreenState();
}

class _MyOutsideWorkScreenState extends ConsumerState<MyOutsideWorkScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(outsideWorkProvider.notifier).refresh();
    });
  }

  Future<void> _refresh() async {
    await ref.read(outsideWorkProvider.notifier).refresh();
  }

  void _openCreate() {
    context.push('/outside-work/new');
  }

  Future<void> _cancelRequest(OutsideWorkRequest request) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelOutsideWorkRequest),
        content: Text(
          l10n.areYouSureCancelOutsideWork(request.dateRangeDisplay),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.yesCancel),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ref.read(outsideWorkProvider.notifier).cancelRequest(request.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.outsideWorkRequestCancelled)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.failedToCancel}: ${e.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(outsideWorkProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myOutsideWork),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
              ref.read(outsideWorkProvider.notifier).loadMore();
            }
            return false;
          },
          child: _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(OutsideWorkState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isLoading && state.requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _refresh, child: Text(l10n.retry)),
          ],
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        if (state.requests.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    size: 64,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noOutsideWorkRequestsYet,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tapPlusToCreateOne,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...state.requests.map((r) => _buildRequestCard(r, state)),
        if (state.isLoading && state.requests.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildRequestCard(OutsideWorkRequest request, OutsideWorkState state) {
    final color = _statusColor(request.status);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    request.dateRangeDisplay,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel(l10n, request.status),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (request.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                request.reason,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (request.adminRemark != null &&
                request.adminRemark!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.adminRemark}: ${request.adminRemark}',
                style: const TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
            if (request.isCancellable) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 30,
                  child: TextButton.icon(
                    onPressed: state.isSubmitting
                        ? null
                        : () => _cancelRequest(request),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: Text(
                      l10n.cancel,
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'In Review':
        return AppColors.info;
      case 'Approved':
        return AppColors.success;
      case 'Rejected':
        return AppColors.danger;
      case 'Cancelled':
        return AppColors.textHint;
      default:
        return AppColors.textSecondary;
    }
  }
}
