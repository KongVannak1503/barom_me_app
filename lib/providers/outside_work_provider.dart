import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/outside_work_request.dart';
import '../repositories/outside_work_repository.dart';

final outsideWorkRepositoryProvider = Provider<OutsideWorkRepository>((ref) {
  return OutsideWorkRepository();
});

@immutable
class OutsideWorkState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final List<OutsideWorkRequest> requests;
  final int currentPage;
  final bool hasMore;
  final int total;

  const OutsideWorkState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.requests = const [],
    this.currentPage = 1,
    this.hasMore = false,
    this.total = 0,
  });

  OutsideWorkState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    List<OutsideWorkRequest>? requests,
    int? currentPage,
    bool? hasMore,
    int? total,
    bool clearError = false,
  }) {
    return OutsideWorkState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
      requests: requests ?? this.requests,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      total: total ?? this.total,
    );
  }
}

class OutsideWorkNotifier extends StateNotifier<OutsideWorkState> {
  final OutsideWorkRepository _repo;

  OutsideWorkNotifier(this._repo) : super(const OutsideWorkState());

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.getMyRequests(page: 1);
      state = state.copyWith(
        isLoading: false,
        requests: result.data,
        currentPage: 1,
        hasMore: result.hasMore,
        total: result.total,
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
      final result = await _repo.getMyRequests(page: nextPage);
      state = state.copyWith(
        isLoading: false,
        requests: [...state.requests, ...result.data],
        currentPage: nextPage,
        hasMore: result.hasMore,
        total: result.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Returns whether the request was auto-approved.
  Future<bool> createRequest({
    required String startDate,
    String? endDate,
    required String reason,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final result = await _repo.createRequest(
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );
      state = state.copyWith(isSubmitting: false);
      await refresh();
      return result.autoApproved;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> cancelRequest(int id) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repo.cancelRequest(id);
      state = state.copyWith(isSubmitting: false);
      await refresh();
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }
}

final outsideWorkProvider =
    StateNotifierProvider<OutsideWorkNotifier, OutsideWorkState>((ref) {
      final repo = ref.watch(outsideWorkRepositoryProvider);
      return OutsideWorkNotifier(repo);
    });
