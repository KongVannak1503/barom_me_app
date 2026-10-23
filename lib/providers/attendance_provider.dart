import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../models/employee.dart';
import '../models/outside_work_request.dart';
import '../models/shift.dart';
import '../repositories/attendance_repository.dart';
import '../utils/date_formatter.dart';

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

@immutable
class AttendanceStatusState {
  final bool isLoading;
  final bool initialLoading;
  final String? error;
  final AttendanceRecord? todayRecord;
  final Employee? employee;
  final bool isClockingIn;
  final Shift? rosterShift;

  /// Approved outside-work request covering today (geofence bypass), if any.
  final OutsideWorkRequest? outsideWorkPermit;

  /// Machine-readable error code from the last failed punch, e.g.
  /// [geofenceBlockedCode].
  final String? errorCode;

  const AttendanceStatusState({
    this.isLoading = false,
    this.initialLoading = true,
    this.error,
    this.todayRecord,
    this.employee,
    this.isClockingIn = false,
    this.rosterShift,
    this.outsideWorkPermit,
    this.errorCode,
  });

  static const geofenceBlockedCode = 'GEOFENCE_BLOCKED';

  Shift? get effectiveShift => todayRecord?.shift ?? rosterShift;

  bool get isGeofenceBlocked => errorCode == geofenceBlockedCode;

  AttendanceStatusState copyWith({
    bool? isLoading,
    bool? initialLoading,
    String? error,
    AttendanceRecord? todayRecord,
    Employee? employee,
    bool? isClockingIn,
    Shift? rosterShift,
    OutsideWorkRequest? outsideWorkPermit,
    String? errorCode,
    bool clearError = false,
  }) {
    return AttendanceStatusState(
      isLoading: isLoading ?? this.isLoading,
      initialLoading: initialLoading ?? this.initialLoading,
      error: clearError ? null : error ?? this.error,
      todayRecord: todayRecord ?? this.todayRecord,
      employee: employee ?? this.employee,
      isClockingIn: isClockingIn ?? this.isClockingIn,
      rosterShift: rosterShift ?? this.rosterShift,
      outsideWorkPermit: outsideWorkPermit ?? this.outsideWorkPermit,
      errorCode: clearError ? null : errorCode ?? this.errorCode,
    );
  }
}

class AttendanceStatusNotifier extends StateNotifier<AttendanceStatusState> {
  final AttendanceRepository _repo;

  AttendanceStatusNotifier(this._repo) : super(const AttendanceStatusState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final result = await _repo.getStatus();
        // Build fresh state (not copyWith) so a missing record — e.g. a new
        // day started while the app stayed open — clears yesterday's punches.
        state = AttendanceStatusState(
          initialLoading: false,
          todayRecord: result.todayAttendance,
          employee: result.employee,
          rosterShift: result.rosterShift,
          outsideWorkPermit: result.outsideWorkPermit,
          error: state.error,
          errorCode: state.errorCode,
        );
        return;
      } catch (e) {
        if (attempt == 0) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          state = state.copyWith(isLoading: false, initialLoading: false, error: _message(e));
        }
      }
    }
  }

  Future<void> clockIn({
    required double latitude,
    required double longitude,
    int? shiftId,
    String? punchType,
  }) async {
    state = state.copyWith(isClockingIn: true, clearError: true);
    try {
      final result = await _repo.clockIn(
        latitude: latitude,
        longitude: longitude,
        shiftId: shiftId,
        punchType: punchType,
      );
      state = state.copyWith(isClockingIn: false, todayRecord: result.data);
      await refresh();
    } catch (e) {
      final message = _message(e);
      final code = _errorCode(e);
      state = state.copyWith(isClockingIn: false, error: message, errorCode: code);
      try {
        await refresh();
      } catch (_) {}
      // refresh() clears the error before reloading; restore the punch error
      // so the screen can show it (and the geofence action).
      state = state.copyWith(error: message, errorCode: code);
    }
  }

  String? _errorCode(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['error'] is String) return data['error'] as String;
    }
    return null;
  }

  String _message(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && (data['message'] ?? data['error']) is String) {
        return (data['message'] ?? data['error']) as String;
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Cannot reach the server. Check your internet connection.';
      }
    }
    return e.toString().replaceFirst('Exception: ', '');
  }
}

final attendanceStatusProvider =
    StateNotifierProvider<AttendanceStatusNotifier, AttendanceStatusState>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return AttendanceStatusNotifier(repo);
});

final attendanceHistoryProvider =
    AsyncNotifierProvider<AttendanceHistoryNotifier, AttendanceHistoryState>(
        AttendanceHistoryNotifier.new);

@immutable
class AttendanceHistoryState {
  final List<AttendanceRecord> items;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final DateTime? selectedDate;

  const AttendanceHistoryState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.selectedDate,
  });

  AttendanceHistoryState copyWith({
    List<AttendanceRecord>? items,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
  }) {
    return AttendanceHistoryState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedDate: clearSelectedDate ? null : selectedDate ?? this.selectedDate,
    );
  }
}

class AttendanceHistoryNotifier extends AsyncNotifier<AttendanceHistoryState> {
  String? _formatDate(DateTime? date) =>
      date == null ? null : DateFormatter.format(date);

  @override
  Future<AttendanceHistoryState> build() async {
    final result = await ref
        .read(attendanceRepositoryProvider)
        .getHistory(page: 1, date: _formatDate(null));
    return AttendanceHistoryState(
      items: result.data,
      page: 1,
      hasMore: result.hasMore,
    );
  }

  Future<void> loadInitial({DateTime? date}) async {
    state = const AsyncLoading();
    try {
      final result = await ref
          .read(attendanceRepositoryProvider)
          .getHistory(page: 1, date: _formatDate(date));
      state = AsyncData(AttendanceHistoryState(
        items: result.data,
        page: 1,
        hasMore: result.hasMore,
        selectedDate: date,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.page + 1;
      final result = await ref
          .read(attendanceRepositoryProvider)
          .getHistory(page: nextPage, date: _formatDate(current.selectedDate));
      state = AsyncData(current.copyWith(
        items: [...current.items, ...result.data],
        page: nextPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setDate(DateTime? date) => loadInitial(date: date);

  Future<void> refresh() async {
    final current = state.valueOrNull;
    if (current == null) {
      await loadInitial();
    } else {
      await loadInitial(date: current.selectedDate);
    }
  }
}
