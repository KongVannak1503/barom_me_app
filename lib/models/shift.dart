import '../utils/session_helper.dart';

class Shift {
  final int id;
  final int? companyId;
  final String? shiftCode;
  final String? description;
  final String? morningIn;
  final String? morningOut;
  final String? afternoonIn;
  final String? afternoonOut;
  final String? eveningIn;
  final String? eveningOut;
  final String? nightIn;
  final String? nightOut;
  final String? status;

  const Shift({
    required this.id,
    this.companyId,
    this.shiftCode,
    this.description,
    this.morningIn,
    this.morningOut,
    this.afternoonIn,
    this.afternoonOut,
    this.eveningIn,
    this.eveningOut,
    this.nightIn,
    this.nightOut,
    this.status,
  });

  String get displayName => shiftCode ?? description ?? 'Shift #$id';

  List<AttendanceSession> get activeSessions {
    final sessions = <AttendanceSession>[];
    if (morningIn != null) sessions.add(AttendanceSession.morning);
    if (afternoonIn != null) sessions.add(AttendanceSession.afternoon);
    if (eveningIn != null) sessions.add(AttendanceSession.evening);
    if (nightIn != null) sessions.add(AttendanceSession.night);
    return sessions;
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
    String? t(dynamic v) {
      final s = v as String?;
      return (s == null || s.isEmpty) ? null : s;
    }

    return Shift(
      id: json['id'] as int,
      companyId: json['company_id'] as int?,
      shiftCode: json['shift_code'] as String?,
      description: json['description'] as String?,
      morningIn: t(json['morning_in']),
      morningOut: t(json['morning_out']),
      afternoonIn: t(json['afternoon_in']),
      afternoonOut: t(json['afternoon_out']),
      eveningIn: t(json['evening_in']),
      eveningOut: t(json['evening_out']),
      nightIn: t(json['night_in']),
      nightOut: t(json['night_out']),
      status: json['status'] as String?,
    );
  }
}
