import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  static String formatDisplay(DateTime date) =>
      DateFormat('MMM dd, yyyy').format(date);
  static String formatDateTime(DateTime date) =>
      DateFormat('MMM dd, yyyy HH:mm').format(date);
  static String formatTime(DateTime date) => DateFormat('HH:mm:ss').format(date);

  static String formatDisplayFromIso(String iso) {
    final datePart = iso.length >= 10 ? iso.substring(0, 10) : iso;
    final parts = datePart.split('-');
    if (parts.length != 3) return iso;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return iso;
    return DateFormat('MMM dd, yyyy')
        .format(DateTime.utc(year, month, day));
  }
}
