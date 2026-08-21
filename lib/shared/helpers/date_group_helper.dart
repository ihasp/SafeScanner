import 'package:intl/intl.dart';

abstract final class DateGroupHelper {
  static String getGroupKey(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    final h = dateTime.hour.toString().padLeft(2, '0');
    return '$y-$m-$d $h:00';
  }

  static String getGroupTitle(DateTime dateTime) {
    final rounded = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
    );
    return DateFormat.yMMMd().add_jm().format(rounded);
  }
}
