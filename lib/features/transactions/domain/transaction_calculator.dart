import '../../../core/utils/month.dart';
import 'transaction.dart';
import 'transaction_type.dart';

/// Income and expense totals for one month, in minor units.
class MonthSummary {
  const MonthSummary({required this.income, required this.expenses});

  static const MonthSummary empty = MonthSummary(income: 0, expenses: 0);

  final int income;
  final int expenses;

  /// Net cash flow = income - expenses (can be negative).
  int get net => income - expenses;

  @override
  bool operator ==(Object other) =>
      other is MonthSummary && other.income == income && other.expenses == expenses;

  @override
  int get hashCode => Object.hash(income, expenses);
}

class CategorySpend {
  const CategorySpend({required this.categoryId, required this.amountInMinorUnits});

  final String categoryId;
  final int amountInMinorUnits;
}

class MonthComparison {
  const MonthComparison({required this.current, required this.previous});

  final MonthSummary current;
  final MonthSummary previous;
}

/// Pure financial calculations: no Flutter, Riverpod or SQL imports.
///
/// Rules (applied everywhere):
///  * Balance = all-time income - all-time expenses (ignores the month selector).
///  * Monthly figures only count transactions whose date is inside the month.
class TransactionCalculator {
  TransactionCalculator._();

  static int balance(Iterable<MoneyTransaction> transactions) {
    var total = 0;
    for (final t in transactions) {
      total += t.type == TransactionType.income
          ? t.amountInMinorUnits
          : -t.amountInMinorUnits;
    }
    return total;
  }

  static MonthSummary summarize(Iterable<MoneyTransaction> transactions, Month month) {
    var income = 0;
    var expenses = 0;
    for (final t in transactions) {
      if (!month.contains(t.date)) continue;
      if (t.type == TransactionType.income) {
        income += t.amountInMinorUnits;
      } else {
        expenses += t.amountInMinorUnits;
      }
    }
    return MonthSummary(income: income, expenses: expenses);
  }

  /// Expense totals per category for [month], largest first.
  static List<CategorySpend> expenseByCategory(
    Iterable<MoneyTransaction> transactions,
    Month month,
  ) {
    final totals = <String, int>{};
    for (final t in transactions) {
      if (t.type != TransactionType.expense || !month.contains(t.date)) continue;
      totals.update(
        t.categoryId,
        (value) => value + t.amountInMinorUnits,
        ifAbsent: () => t.amountInMinorUnits,
      );
    }
    final result = [
      for (final e in totals.entries)
        CategorySpend(categoryId: e.key, amountInMinorUnits: e.value),
    ];
    result.sort((a, b) {
      final byAmount = b.amountInMinorUnits.compareTo(a.amountInMinorUnits);
      return byAmount != 0 ? byAmount : a.categoryId.compareTo(b.categoryId);
    });
    return result;
  }

  /// Percentage change from [previous] to [current], or null if previous is 0.
  /// Display-only; money itself never goes through floating point.
  static int? percentChange(int current, int previous) {
    if (previous == 0) return null;
    return ((current - previous) * 100 / previous).round();
  }
}
