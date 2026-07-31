import 'shift.dart';
import '../utils/session_helper.dart';

class AttendanceRecord {
  final int id;
  final int employeeId;
  final String date;
  final int? shiftId;
  final String? checkInTime;
  final String? checkOutTime;
  final String? morningOut;
  final String? afternoonIn;
  final String? eveningIn;
  final String? eveningOut;
  final String? nightIn;
  final String? nightOut;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final bool? isInBranchRadius;
  final String? status;
  final String? remark;
  final bool isTar;
  final bool isLe;
  final bool isAl;
  final bool isSl;
  final bool isMl;
  final bool isUl;
  final bool isAb;
  final Shift? shift;

  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    this.shiftId,
    this.checkInTime,
    this.checkOutTime,
    this.morningOut,
    this.afternoonIn,
    this.eveningIn,
    this.eveningOut,
    this.nightIn,
    this.nightOut,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.isInBranchRadius,
    this.status,
    this.remark,
    this.isTar = false,
    this.isLe = false,
    this.isAl = false,
    this.isSl = false,
    this.isMl = false,
    this.isUl = false,
    this.isAb = false,
    this.shift,
  });

  bool get hasCheckedIn => checkInTime != null;
  bool get hasCheckedOut => checkOutTime != null;

  String? getSessionInTime(AttendanceSession session) {
    switch (session) {
      case AttendanceSession.morning: return checkInTime;
      case AttendanceSession.afternoon: return afternoonIn;
      case AttendanceSession.evening: return eveningIn;
      case AttendanceSession.night: return nightIn;
    }
  }

  String? getSessionOutTime(AttendanceSession session) {
    switch (session) {
      case AttendanceSession.morning: return morningOut;
      case AttendanceSession.afternoon: return checkOutTime;
      case AttendanceSession.evening: return eveningOut;
      case AttendanceSession.night: return nightOut;
    }
  }

  bool isSessionCheckedIn(AttendanceSession session) => getSessionInTime(session) != null;
  bool isSessionCheckedOut(AttendanceSession session) => getSessionOutTime(session) != null;

  static String? _parseTime(dynamic value) {
    if (value is String) return value;
    if (value is Map) return (value['date'] as String?);
    return null;
  }

  static String displayTime(String? time) {
    if (time == null) return '--:--';
    if (time.length >= 19) return time.substring(11, 16);
    if (time.length >= 16) return time.substring(11, 16);
    if (time.length >= 5) return time.substring(0, 5);
    return time;
  }

  static double? _parseNum(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    return null;
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      date: json['date'] as String,
      shiftId: json['shift_id'] as int?,
      checkInTime: _parseTime(json['check_in_time']),
      checkOutTime: _parseTime(json['check_out_time']),
      morningOut: _parseTime(json['morning_out']),
      afternoonIn: _parseTime(json['afternoon_in']),
      eveningIn: _parseTime(json['evening_in']),
      eveningOut: _parseTime(json['evening_out']),
      nightIn: _parseTime(json['night_in']),
      nightOut: _parseTime(json['night_out']),
      checkInLatitude: _parseNum(json['check_in_latitude']),
      checkInLongitude: _parseNum(json['check_in_longitude']),
      checkOutLatitude: _parseNum(json['check_out_latitude']),
      checkOutLongitude: _parseNum(json['check_out_longitude']),
      isInBranchRadius: _parseBool(json['is_in_branch_radius']),
      status: json['status'] as String?,
      remark: json['remark'] as String?,
      isTar: _parseBool(json['is_tar']) ?? false,
      isLe: _parseBool(json['is_le']) ?? false,
      isAl: _parseBool(json['is_al']) ?? false,
      isSl: _parseBool(json['is_sl']) ?? false,
      isMl: _parseBool(json['is_ml']) ?? false,
      isUl: _parseBool(json['is_ul']) ?? false,
      isAb: _parseBool(json['is_ab']) ?? false,
      shift: json['shift'] != null
          ? Shift.fromJson(json['shift'] as Map<String, dynamic>)
          : null,
    );
  }
}
