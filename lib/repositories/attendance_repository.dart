import '../models/api_response.dart';
import '../models/attendance_record.dart';
import '../models/employee.dart';
import '../models/paginated_response.dart';
import '../models/shift.dart';
import '../services/barom_api.dart';

class AttendanceStatusResult {
  final Employee employee;
  final AttendanceRecord? todayAttendance;
  final List<Shift> availableShifts;
  final Shift? rosterShift;

  const AttendanceStatusResult({
    required this.employee,
    this.todayAttendance,
    required this.availableShifts,
    this.rosterShift,
  });
}

class AttendanceRepository {
  final BaromApi _api;

  AttendanceRepository() : _api = BaromApi();

  Future<AttendanceStatusResult> getStatus() async {
    final response = await _api.dio.get('/my-attendance/status');
    final data = response.data as Map<String, dynamic>;
    return AttendanceStatusResult(
      employee: Employee.fromJson(data['employee'] as Map<String, dynamic>),
      todayAttendance: data['attendance'] != null
          ? AttendanceRecord.fromJson(data['attendance'] as Map<String, dynamic>)
          : null,
      availableShifts: (data['available_shifts'] as List<dynamic>?)
              ?.map((e) => Shift.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      rosterShift: data['roster_shift'] != null
          ? Shift.fromJson(data['roster_shift'] as Map<String, dynamic>)
          : null,
    );
  }

  Future<PaginatedResponse<AttendanceRecord>> getHistory({int page = 1, int perPage = 10, String? date}) async {
    final response = await _api.dio.get('/my-attendance/history', queryParameters: {
      'page': page,
      'per_page': perPage,
      if (date != null) 'date': date,
    });
    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      (item) => AttendanceRecord.fromJson(item as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<AttendanceRecord>> clockIn({
    required double latitude,
    required double longitude,
    int? shiftId,
    String? punchType,
  }) async {
    // DioException propagates; AttendanceStatusNotifier turns it into a message.
    final response = await _api.dio.post('/my-attendance/clock-in', data: {
      'latitude': latitude,
      'longitude': longitude,
      if (shiftId != null) 'shift_id': shiftId,
      if (punchType != null) 'punch_type': punchType,
    });
    final json = response.data as Map<String, dynamic>;
    return ApiResponse.fromJson(
      json,
      (data) => AttendanceRecord.fromJson(data as Map<String, dynamic>),
    );
  }
}
