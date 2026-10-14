import 'package:expense_tracker/core/utils/month.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_calculator.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_data.dart';

void main() {
  const oct = Month(2026, 10);

  group('Month', () {
    test('rolls December into January', () {
      expect(const Month(2026, 12).next, const Month(2027, 1));
      expect(const Month(2027, 1).previous, const Month(2026, 12));
    });

    test('contains uses a half-open range', () {
      expect(oct.contains(DateTime(2026, 10, 1)), isTrue);
      expect(oct.contains(DateTime(2026, 10, 31)), isTrue);
      expect(oct.contains(DateTime(2026, 11, 1)), isFalse);
      expect(oct.contains(DateTime(2026, 9, 30)), isFalse);
    });

    test('handles leap-year February', () {
      expect(const Month(2028, 2).contains(DateTime(2028, 2, 29)), isTrue);
      expect(const Month(2027, 2).nextStart, DateTime(2027, 3, 1));
    });
  });

  group('TransactionCalculator', () {
    final txs = [
      makeTx(type: TransactionType.income, amount: 500000, categoryId: 'salary', date: DateTime(2026, 10, 1)),
      makeTx(type: TransactionType.expense, amount: 120000, categoryId: 'food', date: DateTime(2026, 10, 31)),
      makeTx(type: TransactionType.expense, amount: 30000, categoryId: 'transport', date: DateTime(2026, 10, 10)),
      makeTx(type: TransactionType.expense, amount: 50000, categoryId: 'food', date: DateTime(2026, 11, 1)),
      makeTx(type: TransactionType.income, amount: 100000, categoryId: 'gifts', date: DateTime(2026, 9, 30)),
    ];

    test('balance is all-time income minus expenses', () {
      expect(TransactionCalculator.balance(txs), 500000 + 100000 - 120000 - 30000 - 50000);
    });

    test('summarize only counts the selected month', () {
      final s = TransactionCalculator.summarize(txs, oct);
      expect(s.income, 500000);
      expect(s.expenses, 150000);
      expect(s.net, 350000);
    });

    test('summarize of an empty month is zero', () {
      expect(TransactionCalculator.summarize(txs, const Month(2020, 1)), MonthSummary.empty);
    });

    test('expenseByCategory ignores income and sorts largest first', () {
      final result = TransactionCalculator.expenseByCategory(txs, oct);
      expect(result.map((e) => e.categoryId), ['food', 'transport']);
      expect(result.first.amountInMinorUnits, 120000);
    });

    test('percentChange', () {
      expect(TransactionCalculator.percentChange(150, 100), 50);
      expect(TransactionCalculator.percentChange(50, 200), -75);
      expect(TransactionCalculator.percentChange(10, 0), isNull);
    });
  });

  group('TransactionFilter', () {
    final a = makeTx(title: 'Lunch at Mama Put', categoryId: 'food', date: DateTime(2026, 10, 5));
    final b = makeTx(title: 'Bus fare', categoryId: 'transport', date: DateTime(2026, 10, 6));
    final c = makeTx(title: 'Salary', type: TransactionType.income, categoryId: 'salary', date: DateTime(2026, 9, 25));
    final all = [a, b, c];

    test('empty filter returns everything, newest first', () {
      expect(const TransactionFilter().apply(all), [b, a, c]);
    });

    test('search is case-insensitive on the description', () {
      expect(const TransactionFilter(query: 'LUNCH').apply(all), [a]);
    });

    test('type, category and month filters combine', () {
      expect(const TransactionFilter(type: TransactionType.income).apply(all), [c]);
      expect(const TransactionFilter(categoryId: 'transport').apply(all), [b]);
      expect(const TransactionFilter(month: oct).apply(all), [b, a]);
      expect(
        const TransactionFilter(month: oct, categoryId: 'food', query: 'lun').apply(all),
        [a],
      );
      expect(
        const TransactionFilter(month: oct, type: TransactionType.income).apply(all),
        isEmpty,
      );
    });

    test('oldest first reverses the order', () {
      expect(
        const TransactionFilter(sortOrder: SortOrder.oldestFirst).apply(all),
        [c, a, b],
      );
    });

    test('isActive ignores sorting', () {
      expect(const TransactionFilter().isActive, isFalse);
      expect(const TransactionFilter(sortOrder: SortOrder.oldestFirst).isActive, isFalse);
      expect(const TransactionFilter(query: 'x').isActive, isTrue);
    });
  });
}
