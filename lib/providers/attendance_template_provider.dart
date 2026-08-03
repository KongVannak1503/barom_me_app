import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance_screen_template.dart';

const _prefsKey = 'attendance_screen_template';

class AttendanceTemplateNotifier extends Notifier<AttendanceScreenTemplate> {
  @override
  AttendanceScreenTemplate build() {
    _load();
    return AttendanceScreenTemplate.classic;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null) {
      state = _parse(saved);
    }
  }

  AttendanceScreenTemplate _parse(String value) {
    switch (value) {
      case 'punchFirst':
        return AttendanceScreenTemplate.punchFirst;
      case 'compact':
        return AttendanceScreenTemplate.compact;
      case 'sessions':
        return AttendanceScreenTemplate.sessions;
      default:
        return AttendanceScreenTemplate.classic;
    }
  }

  Future<void> setTemplate(AttendanceScreenTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, template.name);
    state = template;
  }
}

final attendanceTemplateProvider =
    NotifierProvider<AttendanceTemplateNotifier, AttendanceScreenTemplate>(
  AttendanceTemplateNotifier.new,
);
