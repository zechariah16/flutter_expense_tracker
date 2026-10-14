import 'package:expense_tracker/features/transactions/data/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/domain/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_type.dart';

int _counter = 0;

MoneyTransaction makeTx({
  String? id,
  String title = 'Test',
  int amount = 1000,
  TransactionType type = TransactionType.expense,
  String categoryId = 'food',
  DateTime? date,
  DateTime? createdAt,
}) {
  _counter++;
  final created = createdAt ?? DateTime(2026, 1, 1, 12, 0, _counter % 60);
  return MoneyTransaction(
    id: id ?? 'tx-$_counter',
    title: title,
    amountInMinorUnits: amount,
    type: type,
    categoryId: categoryId,
    date: date ?? DateTime(2026, 10, 15),
    createdAt: created,
    updatedAt: created,
  );
}

/// In-memory repository for provider and widget tests.
class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository([Iterable<MoneyTransaction> seed = const []]) {
    for (final t in seed) {
      _items[t.id] = t;
    }
  }

  final Map<String, MoneyTransaction> _items = {};

  /// When true, the next write throws, to test error handling.
  bool failNextWrite = false;

  void _maybeFail() {
    if (failNextWrite) {
      failNextWrite = false;
      throw RepositoryException('Simulated failure');
    }
  }

  @override
  Future<List<MoneyTransaction>> getAll() async => _items.values.toList();

  @override
  Future<MoneyTransaction?> getById(String id) async => _items[id];

  @override
  Future<void> insert(MoneyTransaction transaction) async {
    _maybeFail();
    _items[transaction.id] = transaction;
  }

  @override
  Future<void> insertAll(List<MoneyTransaction> transactions) async {
    _maybeFail();
    for (final t in transactions) {
      _items[t.id] = t;
    }
  }

  @override
  Future<void> update(MoneyTransaction transaction) async {
    _maybeFail();
    _items[transaction.id] = transaction;
  }

  @override
  Future<void> delete(String id) async {
    _maybeFail();
    _items.remove(id);
  }
}
