import 'package:expense_tracker/core/utils/month.dart';
import 'package:expense_tracker/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:expense_tracker/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_type.dart';
import 'package:expense_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_data.dart';

void main() {
  const oct = Month(2026, 10);

  Future<ProviderContainer> makeContainer(FakeTransactionRepository repo) async {
    final container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    container.read(selectedMonthProvider.notifier).select(oct);
    await container.read(transactionsProvider.future);
    return container;
  }

  test('adding, editing and deleting updates derived totals', () async {
    final repo = FakeTransactionRepository();
    final c = await makeContainer(repo);
    final notifier = c.read(transactionsProvider.notifier);

    final income = makeTx(id: 'i', type: TransactionType.income, amount: 100000, categoryId: 'salary');
    final expense = makeTx(id: 'e', amount: 30000);
    await notifier.add(income);
    await notifier.add(expense);

    expect(c.read(allTimeBalanceProvider), 70000);
    expect(c.read(monthSummaryProvider).income, 100000);
    expect(c.read(monthSummaryProvider).expenses, 30000);
    expect(c.read(categorySpendingProvider).single.categoryId, 'food');

    await notifier.edit(expense.copyWith(amountInMinorUnits: 40000));
    expect(c.read(allTimeBalanceProvider), 60000);

    await notifier.remove('e');
    expect(c.read(allTimeBalanceProvider), 100000);
    expect(c.read(categorySpendingProvider), isEmpty);
  });

  test('balance ignores the selected month but monthly totals do not', () async {
    final repo = FakeTransactionRepository([
      makeTx(id: 'a', amount: 1000, date: DateTime(2026, 10, 5)),
      makeTx(id: 'b', amount: 2000, date: DateTime(2026, 9, 5)),
    ]);
    final c = await makeContainer(repo);

    expect(c.read(allTimeBalanceProvider), -3000);
    expect(c.read(monthSummaryProvider).expenses, 1000);

    c.read(selectedMonthProvider.notifier).select(const Month(2026, 9));
    expect(c.read(allTimeBalanceProvider), -3000);
    expect(c.read(monthSummaryProvider).expenses, 2000);
  });

  test('month comparison looks at the previous month', () async {
    final repo = FakeTransactionRepository([
      makeTx(id: 'a', amount: 1000, date: DateTime(2026, 10, 5)),
      makeTx(id: 'b', amount: 2000, date: DateTime(2026, 9, 5)),
    ]);
    final c = await makeContainer(repo);
    final comparison = c.read(monthComparisonProvider);
    expect(comparison.current.expenses, 1000);
    expect(comparison.previous.expenses, 2000);
  });

  test('filters combine and picking a type drops a mismatched category', () async {
    final repo = FakeTransactionRepository([
      makeTx(id: 'a', title: 'Lunch', categoryId: 'food'),
      makeTx(id: 'b', title: 'Salary', type: TransactionType.income, categoryId: 'salary'),
    ]);
    final c = await makeContainer(repo);
    final filter = c.read(transactionFilterProvider.notifier);

    filter.setCategory('food');
    expect(c.read(filteredTransactionsProvider).map((t) => t.id), ['a']);

    filter.setType(TransactionType.income);
    expect(c.read(transactionFilterProvider).categoryId, isNull);
    expect(c.read(filteredTransactionsProvider).map((t) => t.id), ['b']);

    filter.reset();
    filter.setQuery('lunch');
    expect(c.read(filteredTransactionsProvider).map((t) => t.id), ['a']);
  });

  test('a failed write throws and leaves state unchanged', () async {
    final repo = FakeTransactionRepository();
    final c = await makeContainer(repo);
    final notifier = c.read(transactionsProvider.notifier);

    repo.failNextWrite = true;
    await expectLater(notifier.add(makeTx(id: 'x')), throwsA(isA<RepositoryException>()));
    expect(c.read(transactionListProvider), isEmpty);
  });
}
