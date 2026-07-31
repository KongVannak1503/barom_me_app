enum AttendanceSession { morning, afternoon, evening, night }

class SessionHelper {
  static AttendanceSession detect(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return AttendanceSession.morning;
    if (hour < 17) return AttendanceSession.afternoon;
    if (hour < 21) return AttendanceSession.evening;
    return AttendanceSession.night;
  }

  static String label(AttendanceSession session) {
    switch (session) {
      case AttendanceSession.morning: return 'Morning';
      case AttendanceSession.afternoon: return 'Afternoon';
      case AttendanceSession.evening: return 'Evening';
      case AttendanceSession.night: return 'Night';
    }
  }

  static String shortLabel(AttendanceSession session) {
    switch (session) {
      case AttendanceSession.morning: return 'AM';
      case AttendanceSession.afternoon: return 'PM';
      case AttendanceSession.evening: return 'EV';
      case AttendanceSession.night: return 'NT';
    }
  }

  static String punchType(AttendanceSession session, {required bool isOut}) {
    switch (session) {
      case AttendanceSession.morning: return isOut ? 'morning_out' : 'morning_in';
      case AttendanceSession.afternoon: return isOut ? 'afternoon_out' : 'afternoon_in';
      case AttendanceSession.evening: return isOut ? 'evening_out' : 'evening_in';
      case AttendanceSession.night: return isOut ? 'night_out' : 'night_in';
    }
  }
}
