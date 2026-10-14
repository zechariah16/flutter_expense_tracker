import '../../../core/utils/date_utils.dart';
import 'transaction_type.dart';

/// Named MoneyTransaction because sqflite exports its own `Transaction` class.
///
/// Immutable. The constructor rejects invalid states (blank title, amount <= 0),
/// so a MoneyTransaction in memory is always valid.
class MoneyTransaction {
  MoneyTransaction({
    required this.id,
    required String title,
    required this.amountInMinorUnits,
    required this.type,
    required this.categoryId,
    required DateTime date,
    required this.createdAt,
    required this.updatedAt,
  })  : title = title.trim(),
        date = dateOnly(date) {
    if (id.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (this.title.isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be blank');
    }
    if (amountInMinorUnits <= 0) {
      throw ArgumentError.value(
        amountInMinorUnits,
        'amountInMinorUnits',
        'must be greater than zero',
      );
    }
  }

  final String id;
  final String title;

  /// Always > 0. Kobo for NGN (₦1,500.50 -> 150050).
  final int amountInMinorUnits;
  final TransactionType type;
  final String categoryId;

  /// Calendar day, normalized to local midnight.
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isIncome => type == TransactionType.income;

  MoneyTransaction copyWith({
    String? title,
    int? amountInMinorUnits,
    TransactionType? type,
    String? categoryId,
    DateTime? date,
    DateTime? updatedAt,
  }) {
    return MoneyTransaction(
      id: id,
      title: title ?? this.title,
      amountInMinorUnits: amountInMinorUnits ?? this.amountInMinorUnits,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'amount_minor': amountInMinorUnits,
        'type': type.dbValue,
        'category_id': categoryId,
        'date': toDbDate(date),
        'created_at': createdAt.millisecondsSinceEpoch,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory MoneyTransaction.fromMap(Map<String, Object?> map) {
    return MoneyTransaction(
      id: map['id'] as String,
      title: map['title'] as String,
      amountInMinorUnits: map['amount_minor'] as int,
      type: TransactionType.fromDb(map['type'] as String),
      categoryId: map['category_id'] as String,
      date: fromDbDate(map['date'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MoneyTransaction &&
      other.id == id &&
      other.title == title &&
      other.amountInMinorUnits == amountInMinorUnits &&
      other.type == type &&
      other.categoryId == categoryId &&
      other.date == date &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        amountInMinorUnits,
        type,
        categoryId,
        date,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'MoneyTransaction($id, $title, ${type.name}, $amountInMinorUnits, $categoryId, $date)';
}
