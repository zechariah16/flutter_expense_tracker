/// Strips the time part so a transaction date is a pure calendar day.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Database representation of a calendar day: 'YYYY-MM-DD'.
/// ISO strings sort correctly as text, which keeps SQL ordering simple.
String toDbDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

DateTime fromDbDate(String value) {
  final parts = value.split('-');
  if (parts.length != 3) {
    throw FormatException('Invalid date value', value);
  }
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}
