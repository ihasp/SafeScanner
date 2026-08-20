import 'package:intl/intl.dart';

abstract final class BalanceFormatter {
  static String format(String? value, {int maxDecimals = 8}) {
    if (value == null || value.trim().isEmpty) {
      return '0';
    }

    final numericValue = double.tryParse(value.trim());
    if (numericValue == null) {
      return value;
    }

    final formatter = NumberFormat.decimalPattern()
      ..maximumFractionDigits = maxDecimals;

    return formatter.format(numericValue);
  }
}
