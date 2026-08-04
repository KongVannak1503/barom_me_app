import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../models/employee.dart';
import '../models/paginated_response.dart';
import '../models/shift.dart';
import '../repositories/attendance_repository.dart';

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

  const AttendanceStatusState({
    this.isLoading = false,
    this.initialLoading = true,
    this.error,
    this.todayRecord,
    this.employee,
    this.isClockingIn = false,
    this.rosterShift,
  });

  Shift? get effectiveShift => todayRecord?.shift ?? rosterShift;

  AttendanceStatusState copyWith({
    bool? isLoading,
    bool? initialLoading,
    String? error,
    AttendanceRecord? todayRecord,
    Employee? employee,
    bool? isClockingIn,
    Shift? rosterShift,
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
        state = state.copyWith(
          isLoading: false,
          initialLoading: false,
          todayRecord: result.todayAttendance,
          employee: result.employee,
          rosterShift: result.rosterShift,
        );
        return;
      } catch (e) {
        if (attempt == 0) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          state = state.copyWith(isLoading: false, initialLoading: false, error: e.toString());
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
      state = state.copyWith(isClockingIn: false, error: e.toString());
      try {
        await refresh();
      } catch (_) {}
    }
  }
}

final attendanceStatusProvider =
    StateNotifierProvider<AttendanceStatusNotifier, AttendanceStatusState>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return AttendanceStatusNotifier(repo);
});

final attendanceHistoryProvider = FutureProvider.family<PaginatedResponse<AttendanceRecord>, int>((ref, page) async {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getHistory(page: page);
});
