import 'package:expense_tracker/features/transactions/domain/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_data.dart';

void main() {
  group('MoneyTransaction', () {
    test('rejects zero or negative amounts', () {
      expect(() => makeTx(amount: 0), throwsArgumentError);
      expect(() => makeTx(amount: -5), throwsArgumentError);
    });

    test('rejects blank titles and trims whitespace', () {
      expect(() => makeTx(title: '   '), throwsArgumentError);
      expect(makeTx(title: '  Lunch  ').title, 'Lunch');
    });

    test('normalizes date to midnight', () {
      final t = makeTx(date: DateTime(2026, 3, 5, 18, 45));
      expect(t.date, DateTime(2026, 3, 5));
    });

    test('toMap uses expected database representation', () {
      final t = makeTx(
        id: 'a',
        amount: 150050,
        type: TransactionType.income,
        date: DateTime(2026, 3, 5),
      );
      final map = t.toMap();
      expect(map['amount_minor'], 150050);
      expect(map['type'], 'income');
      expect(map['date'], '2026-03-05');
    });

    test('toMap/fromMap round trip keeps equality', () {
      final t = makeTx(id: 'round', amount: 999);
      expect(MoneyTransaction.fromMap(t.toMap()), t);
    });

    test('fromMap fails loudly on unknown type', () {
      final map = makeTx().toMap()..['type'] = 'transfer';
      expect(() => MoneyTransaction.fromMap(map), throwsFormatException);
    });

    test('copyWith keeps id and createdAt', () {
      final t = makeTx(id: 'keep');
      final updated = t.copyWith(title: 'New', amountInMinorUnits: 5);
      expect(updated.id, 'keep');
      expect(updated.createdAt, t.createdAt);
      expect(updated.title, 'New');
      expect(updated.amountInMinorUnits, 5);
    });
  });
}
