import 'package:intl/intl.dart';

import 'month.dart';

/// Display formatting for dates. Used only at the UI boundary.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _day = DateFormat.yMMMd();
  static final DateFormat _month = DateFormat.yMMMM();
  static final DateFormat _dateTime = DateFormat.yMMMd().add_jm();

  static String day(DateTime date) => _day.format(date);
  static String month(Month month) => _month.format(month.start);
  static String dateTime(DateTime date) => _dateTime.format(date);
}
