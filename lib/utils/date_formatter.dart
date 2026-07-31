import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  static String formatDisplay(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);
  static String formatDateTime(DateTime date) =>
      DateFormat('MMM dd, yyyy HH:mm').format(date);
  static String formatTime(DateTime date) => DateFormat('HH:mm:ss').format(date);
}
