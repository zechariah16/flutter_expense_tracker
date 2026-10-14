import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Money helpers. All amounts are integer minor units (kobo for NGN).
///
/// Parsing works on the *string*, never through `double`, so there are no
/// floating-point rounding errors anywhere in the money path.
class Money {
  Money._();

  static final RegExp _pattern = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$');
  static const int _maxWholeDigits = 12;
  static final NumberFormat _wholeFormat = NumberFormat('#,##0', 'en_US');

  /// Parses user input like "1,500.50" into 150050.
  /// Returns null when the text is not a valid amount (at most 2 decimals).
  static int? parseToMinorUnits(String input) {
    final cleaned = input
        .replaceAll(',', '')
        .replaceAll(AppConstants.currencySymbol, '')
        .replaceAll(RegExp(r'\s'), '');
    final match = _pattern.firstMatch(cleaned);
    if (match == null) return null;

    final whole = match.group(1)!;
    if (whole.length > _maxWholeDigits) return null;

    final fraction = (match.group(2) ?? '').padRight(2, '0');
    return int.parse(whole) * 100 + int.parse(fraction);
  }

  /// Formats 150050 as "₦1,500.50". Negative values become "-₦2.50".
  static String format(int minorUnits) {
    final negative = minorUnits < 0;
    final abs = minorUnits.abs();
    final whole = _wholeFormat.format(abs ~/ 100);
    final fraction = (abs % 100).toString().padLeft(2, '0');
    return '${negative ? '-' : ''}${AppConstants.currencySymbol}$whole.$fraction';
  }

  /// Formats with an explicit +/- sign, used in transaction lists.
  static String formatSigned(int minorUnits, {required bool isIncome}) =>
      '${isIncome ? '+' : '-'}${format(minorUnits)}';

  /// Converts minor units back to plain input text for editing: 150050 -> "1500.50".
  static String toInputString(int minorUnits) {
    final whole = minorUnits ~/ 100;
    final fraction = minorUnits % 100;
    if (fraction == 0) return '$whole';
    return '$whole.${fraction.toString().padLeft(2, '0')}';
  }
}
