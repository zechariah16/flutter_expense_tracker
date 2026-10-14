/// Whether a transaction adds to or subtracts from the balance.
/// The amount itself is always positive; the type decides the sign.
enum TransactionType {
  income('Income'),
  expense('Expense');

  const TransactionType(this.label);

  final String label;

  /// Value stored in the database.
  String get dbValue => name;

  static TransactionType fromDb(String value) {
    for (final type in TransactionType.values) {
      if (type.dbValue == value) return type;
    }
    // Fail loudly: silently defaulting could corrupt financial totals.
    throw FormatException('Unknown transaction type', value);
  }
}
