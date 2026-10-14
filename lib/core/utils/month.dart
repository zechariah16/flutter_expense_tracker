/// A calendar month (e.g. October 2026).
///
/// Month membership uses a half-open range [start, nextStart), so the
/// last day of the month is included and the first day of the next month
/// is not. `DateTime(year, month + 1)` rolls December into January safely.
class Month implements Comparable<Month> {
  const Month(this.year, this.month);

  factory Month.fromDate(DateTime date) => Month(date.year, date.month);

  factory Month.now() => Month.fromDate(DateTime.now());

  final int year;
  final int month;

  DateTime get start => DateTime(year, month);
  DateTime get nextStart => DateTime(year, month + 1);

  Month get next => Month.fromDate(nextStart);
  Month get previous => Month.fromDate(DateTime(year, month - 1));

  bool contains(DateTime date) =>
      !date.isBefore(start) && date.isBefore(nextStart);

  bool isAfter(Month other) => compareTo(other) > 0;

  @override
  int compareTo(Month other) =>
      year != other.year ? year.compareTo(other.year) : month.compareTo(other.month);

  @override
  bool operator ==(Object other) =>
      other is Month && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'Month($year-$month)';
}
