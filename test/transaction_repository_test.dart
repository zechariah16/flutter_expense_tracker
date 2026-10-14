import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/data/transaction_repository_impl.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/test_data.dart';

void main() {
  // Runs SQLite on the desktop test host instead of a phone/emulator.
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late SqfliteTransactionRepository repo;

  setUp(() async {
    db = await AppDatabase.open(path: inMemoryDatabasePath);
    repo = SqfliteTransactionRepository(db);
  });

  tearDown(() async => db.close());

  test('insert then getAll returns the transaction', () async {
    final t = makeTx(id: 'a', amount: 150050, title: 'Rent');
    await repo.insert(t);
    expect(await repo.getAll(), [t]);
  });

  test('getAll orders by date then creation time, newest first', () async {
    final older = makeTx(id: 'old', date: DateTime(2026, 10, 1));
    final newer = makeTx(id: 'new', date: DateTime(2026, 10, 20));
    await repo.insertAll([older, newer]);
    final ids = (await repo.getAll()).map((t) => t.id);
    expect(ids, ['new', 'old']);
  });

  test('getById returns null for unknown ids', () async {
    expect(await repo.getById('missing'), isNull);
    final t = makeTx(id: 'a');
    await repo.insert(t);
    expect(await repo.getById('a'), t);
  });

  test('update persists changes', () async {
    final t = makeTx(id: 'a', title: 'Before');
    await repo.insert(t);
    final updated = t.copyWith(
      title: 'After',
      amountInMinorUnits: 4200,
      type: TransactionType.income,
      categoryId: 'salary',
    );
    await repo.update(updated);
    expect(await repo.getById('a'), updated);
  });

  test('update of a missing transaction throws', () async {
    expect(() => repo.update(makeTx(id: 'ghost')), throwsA(isA<RepositoryException>()));
  });

  test('delete removes the row and missing delete throws', () async {
    await repo.insert(makeTx(id: 'a'));
    await repo.delete('a');
    expect(await repo.getAll(), isEmpty);
    expect(() => repo.delete('a'), throwsA(isA<RepositoryException>()));
  });

  test('duplicate id is reported as a RepositoryException', () async {
    await repo.insert(makeTx(id: 'dup'));
    expect(() => repo.insert(makeTx(id: 'dup')), throwsA(isA<RepositoryException>()));
  });

  test('insertAll is all-or-nothing', () async {
    final a = makeTx(id: 'same');
    final b = makeTx(id: 'same');
    await expectLater(repo.insertAll([a, b]), throwsA(isA<RepositoryException>()));
    expect(await repo.getAll(), isEmpty);
  });

  test('database CHECK constraint rejects non-positive amounts', () async {
    final row = makeTx(id: 'raw').toMap()..['amount_minor'] = 0;
    await expectLater(db.insert('transactions', row), throwsA(isA<DatabaseException>()));
  });
}
