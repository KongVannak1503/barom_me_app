import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/leave_entitlement.dart';
import '../models/leave_request.dart';
import '../models/leave_type.dart';
import '../models/paginated_response.dart';
import '../services/barom_api.dart';

class LeaveRepository {
  final BaromApi _api;

  LeaveRepository() : _api = BaromApi();

  Future<PaginatedResponse<LeaveRequest>> getMyLeaves({int page = 1, int perPage = 20}) async {
    final response = await _api.dio.get('/leave-requests/my-leaves', queryParameters: {
      'page': page,
      'per_page': perPage,
    });
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (item) => LeaveRequest.fromJson(item as Map<String, dynamic>),
    );
  }

  Future<LeaveRequest> getLeaveDetail(int id) async {
    final response = await _api.dio.get('/leave-requests/$id');
    final data = response.data as Map<String, dynamic>;
    if (data['success'] == true && data['data'] != null) {
      return LeaveRequest.fromJson(data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load leave detail');
  }

  Future<ApiResponse<LeaveRequest>> createLeaveRequest({
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    required String reason,
    bool halfDay = false,
    String? halfDaySession,
    String? contactDuringLeave,
  }) async {
    try {
      final response = await _api.dio.post('/leave-requests', data: {
        'leave_type_id': leaveTypeId,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
        'half_day': halfDay,
        if (halfDaySession != null) 'half_day_session': halfDaySession,
        if (contactDuringLeave != null) 'contact_during_leave': contactDuringLeave,
      });
      final json = response.data as Map<String, dynamic>;
      return ApiResponse.fromJson(
        json,
        (data) => LeaveRequest.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<void> cancelLeaveRequest(int id) async {
    try {
      await _api.dio.patch('/leave-request-actions/$id/cancel');
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    }
  }

  Future<List<LeaveType>> getLeaveTypes() async {
    final response = await _api.dio.get('/leave-types', queryParameters: {
      'per_page': 100,
    });
    final data = response.data as Map<String, dynamic>;
    final items = data['data'] as List<dynamic>? ?? [];
    return items
        .map((e) => LeaveType.fromJson(e as Map<String, dynamic>))
        .where((t) => t.status == 'Active')
        .toList();
  }

  Future<Map<String, dynamic>> getLeaveStats() async {
    try {
      final response = await _api.dio.get('/leave-requests/stats');
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return data['data'] as Map<String, dynamic>;
      }
      return {};
    } on DioException {
      return {};
    }
  }

  Future<List<LeaveEntitlement>> getLeaveEntitlements() async {
    try {
      final response = await _api.dio.get('/leave-entitlements', queryParameters: {
        'per_page': 100,
      });
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      return items
          .map((e) => LeaveEntitlement.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      return [];
    }
  }

  String _extractError(DioException e) {
    if (e.response?.data is Map) {
      final data = e.response!.data as Map<String, dynamic>;
      return (data['message'] ?? data['error'] ?? e.toString()) as String;
    }
    return e.toString();
  }
}
