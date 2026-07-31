import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_entitlement.dart';
import '../models/leave_request.dart';
import '../models/leave_type.dart';
import '../models/paginated_response.dart';
import '../repositories/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepository();
});

@immutable
class LeaveState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final List<LeaveRequest> leaves;
  final List<LeaveType> leaveTypes;
  final List<LeaveEntitlement> entitlements;
  final Map<String, dynamic> stats;
  final int currentPage;
  final bool hasMore;
  final int total;

  const LeaveState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.leaves = const [],
    this.leaveTypes = const [],
    this.entitlements = const [],
    this.stats = const {},
    this.currentPage = 1,
    this.hasMore = false,
    this.total = 0,
  });

  LeaveState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    List<LeaveRequest>? leaves,
    List<LeaveType>? leaveTypes,
    List<LeaveEntitlement>? entitlements,
    Map<String, dynamic>? stats,
    int? currentPage,
    bool? hasMore,
    int? total,
    bool clearError = false,
  }) {
    return LeaveState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
      leaves: leaves ?? this.leaves,
      leaveTypes: leaveTypes ?? this.leaveTypes,
      entitlements: entitlements ?? this.entitlements,
      stats: stats ?? this.stats,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
    );
  }
}

class LeaveNotifier extends StateNotifier<LeaveState> {
  final LeaveRepository _repo;

  LeaveNotifier(this._repo) : super(const LeaveState());

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getMyLeaves(page: 1),
        _repo.getLeaveTypes(),
        _repo.getLeaveStats(),
        _repo.getLeaveEntitlements(),
      ]);

      final leavesResult = results[0] as PaginatedResponse<LeaveRequest>;
      final leaveTypes = results[1] as List<LeaveType>;
      final stats = results[2] as Map<String, dynamic>;
      final entitlements = results[3] as List<LeaveEntitlement>;

      state = state.copyWith(
        isLoading: false,
        leaves: leavesResult.data,
        leaveTypes: leaveTypes,
        stats: stats,
        entitlements: entitlements,
        currentPage: 1,
        hasMore: leavesResult.hasMore,
        total: leavesResult.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    final nextPage = state.currentPage + 1;
    try {
      final result = await _repo.getMyLeaves(page: nextPage);
      state = state.copyWith(
        isLoading: false,
        leaves: [...state.leaves, ...result.data],
        currentPage: nextPage,
        hasMore: result.hasMore,
        total: result.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getMyLeaves(page: 1),
        _repo.getLeaveStats(),
        _repo.getLeaveEntitlements(),
      ]);

      final leavesResult = results[0] as PaginatedResponse<LeaveRequest>;
      final stats = results[1] as Map<String, dynamic>;
      final entitlements = results[2] as List<LeaveEntitlement>;

      state = state.copyWith(
        isLoading: false,
        leaves: leavesResult.data,
        stats: stats,
        entitlements: entitlements,
        currentPage: 1,
        hasMore: leavesResult.hasMore,
        total: leavesResult.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createLeaveRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    bool halfDay = false,
    String? halfDaySession,
    String? contactDuringLeave,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.createLeaveRequest(
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        halfDay: halfDay,
        halfDaySession: halfDaySession,
        contactDuringLeave: contactDuringLeave,
      );
      state = state.copyWith(isSubmitting: false);
      await refresh();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> cancelLeaveRequest(int id) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.cancelLeaveRequest(id);
      state = state.copyWith(isSubmitting: false);
      await refresh();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }
}

final leaveProvider = StateNotifierProvider<LeaveNotifier, LeaveState>((ref) {
  final repo = ref.watch(leaveRepositoryProvider);
  return LeaveNotifier(repo);
});
