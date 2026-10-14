import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../core/utils/month.dart';
import '../../../categories/domain/category_catalog.dart';
import '../../data/transaction_repository.dart';
import '../../data/transaction_repository_impl.dart';
import '../../domain/transaction.dart';
import '../../domain/transaction_calculator.dart';
import '../../domain/transaction_filter.dart';
import '../../domain/transaction_type.dart';

// ---------------------------------------------------------------------------
// Dependencies
// ---------------------------------------------------------------------------

/// The open database. Overridden in main() after it has been opened, so the
/// rest of the app never has to deal with an async database.
final appDatabaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in main()');
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return SqfliteTransactionRepository(ref.watch(appDatabaseProvider));
});

// ---------------------------------------------------------------------------
// Source of truth: all transactions
// ---------------------------------------------------------------------------

/// Loads every transaction and exposes write operations.
/// Each write talks to the repository first; only when it succeeds do we
/// reload, so a failed write leaves the visible state untouched.
class TransactionsNotifier extends AsyncNotifier<List<MoneyTransaction>> {
  TransactionRepository get _repo => ref.read(transactionRepositoryProvider);

  @override
  Future<List<MoneyTransaction>> build() =>
      ref.watch(transactionRepositoryProvider).getAll();

  Future<void> add(MoneyTransaction transaction) async {
    await _repo.insert(transaction);
    await _reload();
  }

  Future<void> edit(MoneyTransaction transaction) async {
    await _repo.update(transaction);
    await _reload();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await _reload();
  }

  Future<void> _reload() async {
    state = AsyncData(await _repo.getAll());
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<MoneyTransaction>>(
  TransactionsNotifier.new,
);

/// Plain list for derived providers. Screens wrap their content in a
/// TransactionsGate, which handles the loading/error states of the
/// provider above, so derived providers can safely use a simple list.
final transactionListProvider = Provider<List<MoneyTransaction>>((ref) {
  final async = ref.watch(transactionsProvider);
  return async.hasValue ? async.requireValue : const <MoneyTransaction>[];
});

final transactionByIdProvider =
    Provider.family<MoneyTransaction?, String>((ref, id) {
  for (final t in ref.watch(transactionListProvider)) {
    if (t.id == id) return t;
  }
  return null;
});

// ---------------------------------------------------------------------------
// Selected month (Dashboard + Statistics)
// ---------------------------------------------------------------------------

class SelectedMonthNotifier extends Notifier<Month> {
  @override
  Month build() => Month.now();

  void select(Month month) => state = month;
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, Month>(SelectedMonthNotifier.new);

final monthSummaryProvider = Provider<MonthSummary>((ref) {
  return TransactionCalculator.summarize(
    ref.watch(transactionListProvider),
    ref.watch(selectedMonthProvider),
  );
});

// ---------------------------------------------------------------------------
// History filters
// ---------------------------------------------------------------------------

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setType(TransactionType? type) {
    var next = type == null
        ? state.copyWith(clearType: true)
        : state.copyWith(type: type);
    // Drop a category that no longer matches the chosen type.
    final categoryId = state.categoryId;
    if (type != null &&
        categoryId != null &&
        CategoryCatalog.byId(categoryId).type != type) {
      next = next.copyWith(clearCategory: true);
    }
    state = next;
  }

  void setCategory(String? categoryId) => state = categoryId == null
      ? state.copyWith(clearCategory: true)
      : state.copyWith(categoryId: categoryId);

  void setMonth(Month? month) => state =
      month == null ? state.copyWith(clearMonth: true) : state.copyWith(month: month);

  void toggleSort() => state = state.copyWith(
        sortOrder: state.sortOrder == SortOrder.newestFirst
            ? SortOrder.oldestFirst
            : SortOrder.newestFirst,
      );

  void reset() => state = const TransactionFilter();
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
  TransactionFilterNotifier.new,
);

final filteredTransactionsProvider = Provider<List<MoneyTransaction>>((ref) {
  return ref
      .watch(transactionFilterProvider)
      .apply(ref.watch(transactionListProvider));
});

/// Months that actually contain data, newest first (for the month filter).
final availableMonthsProvider = Provider<List<Month>>((ref) {
  final months = {
    for (final t in ref.watch(transactionListProvider)) Month.fromDate(t.date),
  }.toList()
    ..sort((a, b) => b.compareTo(a));
  return months;
});
