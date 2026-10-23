import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../models/attendance_record.dart';
import '../../models/attendance_screen_template.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/attendance_template_provider.dart';
import '../../themes/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../../utils/location_helper.dart';
import '../../utils/session_helper.dart';
import '../../widgets/attendance/attendance_map.dart';
import '../../widgets/attendance/clock_button.dart';
import '../../widgets/attendance/history_list.dart';
import '../../widgets/attendance/profile_header_card.dart';
import '../../widgets/attendance/session_punch_list.dart';
import '../../widgets/attendance/session_selector.dart';
import '../../widgets/attendance/status_card.dart';

class MyAttendanceScreen extends ConsumerStatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  ConsumerState<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends ConsumerState<MyAttendanceScreen> {
  late AttendanceSession _selectedSession;
  // Until the user taps a session tab, follow the session they should punch next.
  bool _userPickedSession = false;
  bool _isSyncing = false;
  int _mapKey = 0;
  double? _freshLatitude;
  double? _freshLongitude;

  @override
  void initState() {
    super.initState();
    _selectedSession = SessionHelper.detect(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isSyncing = true);
    try {
      _refreshLocation();
      await ref.read(attendanceStatusProvider.notifier).refresh();
      await ref.read(attendanceHistoryProvider.notifier).refresh();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _refreshLocation() async {
    try {
      final pos = await LocationHelper.getCurrentPosition();
      if (mounted) {
        setState(() {
          _freshLatitude = pos.latitude;
          _freshLongitude = pos.longitude;
          _mapKey++;
        });
      }
    } catch (_) {}
  }

  Future<void> _handlePunch({
    required AttendanceSession session,
    required bool isOut,
  }) async {
    try {
      final pos = await LocationHelper.getCurrentPosition();
      if (!mounted) return;

      final punchType = SessionHelper.punchType(session, isOut: isOut);
      await ref.read(attendanceStatusProvider.notifier).clockIn(
        latitude: pos.latitude,
        longitude: pos.longitude,
        punchType: punchType,
      );
      if (mounted) {
        await ref.read(attendanceHistoryProvider.notifier).refresh();
      }
    } on LocationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.failedToGetLocation}: $e')),
        );
      }
    }
  }

  /// The session the employee most likely wants to punch now: one that is
  /// clocked in but not out, otherwise the first one not started yet.
  AttendanceSession _suggestedSession(List<AttendanceSession> sessions, AttendanceRecord? record) {
    if (record == null) {
      final detected = SessionHelper.detect(DateTime.now());
      return sessions.contains(detected) ? detected : sessions.first;
    }
    for (final s in sessions) {
      if (record.isSessionCheckedIn(s) && !record.isSessionCheckedOut(s)) return s;
    }
    for (final s in sessions) {
      if (!record.isSessionCheckedIn(s)) return s;
    }
    return sessions.last;
  }

  Widget _buildDateFilter() {
    final l10n = AppLocalizations.of(context)!;
    final selectedDate = ref.watch(attendanceHistoryProvider).valueOrNull?.selectedDate;
    return InputDecorator(
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.calendar_today, size: 16),
        suffixIcon: selectedDate != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () => ref.read(attendanceHistoryProvider.notifier).setDate(null),
              )
            : null,
      ),
      child: GestureDetector(
        onTap: () => _pickHistoryDate(),
        child: Text(
          selectedDate != null ? DateFormatter.format(selectedDate) : l10n.allDates,
          style: TextStyle(
            fontSize: 13,
            color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _pickHistoryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: ref.watch(attendanceHistoryProvider).valueOrNull?.selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now,
    );
    if (picked != null) {
      await ref.read(attendanceHistoryProvider.notifier).setDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusState = ref.watch(attendanceStatusProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider);
    final template = ref.watch(attendanceTemplateProvider);
    final record = statusState.todayRecord;
    final shift = statusState.effectiveShift;

    final sessions = () {
      final fromShift = shift?.activeSessions ?? <AttendanceSession>[];
      final fromRecord = <AttendanceSession>{};
      if (record != null) {
        for (final s in AttendanceSession.values) {
          if (record.isSessionCheckedIn(s) || record.isSessionCheckedOut(s)) {
            fromRecord.add(s);
          }
        }
      }
      final merged = <AttendanceSession>{...fromShift, ...fromRecord};
      return merged.isEmpty ? AttendanceSession.values.toList() : merged.toList();
    }();
    final detectedSession = SessionHelper.detect(DateTime.now());

    if (!_userPickedSession || !sessions.contains(_selectedSession)) {
      _selectedSession = _suggestedSession(sessions, record);
    }

    final isSessionIn = record?.isSessionCheckedIn(_selectedSession) ?? false;
    final isSessionOut = record?.isSessionCheckedOut(_selectedSession) ?? false;
    final l10n = AppLocalizations.of(context)!;

    final statusWidget = StatusCard(
      record: record,
      sessions: sessions,
      compact: template == AttendanceScreenTemplate.compact,
    );
    final sessionWidget = SessionSelector(
      selectedSession: _selectedSession,
      detectedSession: detectedSession,
      record: record,
      sessions: sessions,
      onChanged: (session) => setState(() {
        _selectedSession = session;
        _userPickedSession = true;
      }),
    );
    final clockWidget = statusState.initialLoading
        ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 72,
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        : ClockButton(
            session: _selectedSession,
            isCheckedIn: isSessionIn,
            isCheckedOut: isSessionOut,
            isLoading: statusState.isClockingIn,
            onClockIn: () => _handlePunch(session: _selectedSession, isOut: false),
            onClockOut: () => _handlePunch(session: _selectedSession, isOut: true),
          );
    final errorWidget = statusState.error != null
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: statusState.isGeofenceBlocked
                ? Row(
                    children: [
                      Expanded(
                        child: Text(
                          statusState.error!,
                          style: const TextStyle(color: AppColors.danger, fontSize: 12),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/outside-work/new'),
                        icon: const Icon(Icons.directions_walk, size: 16),
                        label: Text(l10n.requestOutsideWork, style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  )
                : Text(
                    statusState.error!,
                    style: const TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
          )
        : const SizedBox.shrink();
    final permit = statusState.outsideWorkPermit;
    final permitWidget = permit != null
        ? Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.outsideWorkAllowedUntil(permit.endDateDisplay),
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
    final locationWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(l10n.todaysLocation, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AttendanceMap(
            key: ValueKey(_mapKey),
            branch: null,
            userLatitude: _freshLatitude ?? record?.checkInLatitude,
            userLongitude: _freshLongitude ?? record?.checkInLongitude,
          ),
        ),
      ],
    );
    final historyWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Row(
            children: [
              Text(l10n.history, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(width: 12),
              Expanded(child: _buildDateFilter()),
            ],
          ),
        ),
        historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => HistoryList(error: err.toString()),
          data: (state) => HistoryList(
            history: state,
            onLoadMore: () => ref.read(attendanceHistoryProvider.notifier).loadMore(),
          ),
        ),
        if (statusState.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        const SizedBox(height: 32),
      ],
    );

    final profileWidget = ProfileHeaderCard(
      employee: statusState.employee,
      loading: statusState.initialLoading,
    );

    final List<Widget> blocks;
    switch (template) {
      case AttendanceScreenTemplate.sessions:
        blocks = [
          profileWidget,
          permitWidget,
          SessionPunchList(
            record: record,
            sessions: sessions,
            isLoading: statusState.isClockingIn,
            isSyncing: _isSyncing || statusState.initialLoading,
            onPunch: (session, {required isOut}) => _handlePunch(session: session, isOut: isOut),
          ),
          errorWidget,
          locationWidget,
          historyWidget,
        ];
      case AttendanceScreenTemplate.punchFirst:
        blocks = [
          profileWidget,
          permitWidget,
          clockWidget,
          errorWidget,
          statusWidget,
          sessionWidget,
          locationWidget,
          historyWidget,
        ];
      case AttendanceScreenTemplate.compact:
      case AttendanceScreenTemplate.classic:
        blocks = [
          profileWidget,
          permitWidget,
          statusWidget,
          sessionWidget,
          clockWidget,
          errorWidget,
          locationWidget,
          historyWidget,
        ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAttendance),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isSyncing ? null : _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(children: blocks),
      ),
    );
  }
}
