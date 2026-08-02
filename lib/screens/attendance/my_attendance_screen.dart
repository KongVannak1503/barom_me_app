import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/attendance_provider.dart';
import '../../themes/app_colors.dart';
import '../../utils/session_helper.dart';
import '../../widgets/attendance/attendance_map.dart';
import '../../widgets/attendance/clock_button.dart';
import '../../widgets/attendance/history_list.dart';
import '../../widgets/attendance/session_selector.dart';
import '../../widgets/attendance/status_card.dart';

class MyAttendanceScreen extends ConsumerStatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  ConsumerState<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends ConsumerState<MyAttendanceScreen> {
  int _historyPage = 1;
  late AttendanceSession _selectedSession;

  @override
  void initState() {
    super.initState();
    _selectedSession = SessionHelper.detect(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    await ref.read(attendanceStatusProvider.notifier).refresh();
    ref.invalidate(attendanceHistoryProvider(_historyPage));
  }

  Future<void> _handlePunch({required bool isOut}) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;

      final punchType = SessionHelper.punchType(_selectedSession, isOut: isOut);
      await ref.read(attendanceStatusProvider.notifier).clockIn(
        latitude: pos.latitude,
        longitude: pos.longitude,
        punchType: punchType,
      );
      if (mounted) {
        ref.invalidate(attendanceHistoryProvider(_historyPage));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.failedToGetLocation}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusState = ref.watch(attendanceStatusProvider);
    final historyAsync = ref.watch(attendanceHistoryProvider(_historyPage));
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

    if (!sessions.contains(_selectedSession)) {
      _selectedSession = sessions.contains(detectedSession) ? detectedSession : sessions.first;
    }

    final isSessionIn = record?.isSessionCheckedIn(_selectedSession) ?? false;
    final isSessionOut = record?.isSessionCheckedOut(_selectedSession) ?? false;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myAttendance),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            StatusCard(record: record, sessions: sessions),
            const SizedBox(height: 8),
            SessionSelector(
              selectedSession: _selectedSession,
              detectedSession: detectedSession,
              record: record,
              sessions: sessions,
              onChanged: (session) => setState(() => _selectedSession = session),
            ),
            const SizedBox(height: 8),
            if (statusState.initialLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 72,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              ClockButton(
                session: _selectedSession,
                isCheckedIn: isSessionIn,
                isCheckedOut: isSessionOut,
                isLoading: statusState.isClockingIn,
                onClockIn: () => _handlePunch(isOut: false),
                onClockOut: () => _handlePunch(isOut: true),
              ),
            if (statusState.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  statusState.error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 12),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(l10n.todaysLocation, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AttendanceMap(
                branch: null,
                userLatitude: record?.checkInLatitude,
                userLongitude: record?.checkInLongitude,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(l10n.history, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => HistoryList(error: err.toString()),
              data: (history) => HistoryList(
                history: history,
                onLoadMore: () {
                  setState(() => _historyPage++);
                  ref.invalidate(attendanceHistoryProvider(_historyPage));
                },
              ),
            ),
            if (statusState.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
