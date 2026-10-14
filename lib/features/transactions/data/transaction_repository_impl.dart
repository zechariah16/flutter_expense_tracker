import 'package:sqflite/sqflite.dart';

import '../domain/transaction.dart';
import 'transaction_repository.dart';

class SqfliteTransactionRepository implements TransactionRepository {
  SqfliteTransactionRepository(this._db);

  final Database _db;

  static const String _table = 'transactions';

  /// Converts low-level failures into a RepositoryException.
  /// All SQL uses `?` placeholders (parameterized), never string building.
  Future<T> _guard<T>(String message, Future<T> Function() action) async {
    try {
      return await action();
    } on DatabaseException catch (e) {
      throw RepositoryException(message, e);
    } on FormatException catch (e) {
      throw RepositoryException(message, e);
    } on TypeError catch (e) {
      throw RepositoryException(message, e);
    }
  }

  @override
  Future<List<MoneyTransaction>> getAll() => _guard(
        'Could not load transactions.',
        () async {
          final rows = await _db.query(
            _table,
            orderBy: 'date DESC, created_at DESC',
          );
          return rows.map(MoneyTransaction.fromMap).toList();
        },
      );

  @override
  Future<MoneyTransaction?> getById(String id) => _guard(
        'Could not load the transaction.',
        () async {
          final rows = await _db.query(
            _table,
            where: 'id = ?',
            whereArgs: [id],
            limit: 1,
          );
          return rows.isEmpty ? null : MoneyTransaction.fromMap(rows.first);
        },
      );

  @override
  Future<void> insert(MoneyTransaction transaction) => _guard(
        'Could not save the transaction.',
        () => _db.insert(
          _table,
          transaction.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        ),
      );

  @override
  Future<void> insertAll(List<MoneyTransaction> transactions) => _guard(
        'Could not save the transactions.',
        () => _db.transaction((txn) async {
          final batch = txn.batch();
          for (final t in transactions) {
            batch.insert(
              _table,
              t.toMap(),
              conflictAlgorithm: ConflictAlgorithm.abort,
            );
          }
          await batch.commit(noResult: true);
        }),
      );

  @override
  Future<void> update(MoneyTransaction transaction) => _guard(
        'Could not update the transaction.',
        () async {
          final values = transaction.toMap()..remove('id');
          final count = await _db.update(
            _table,
            values,
            where: 'id = ?',
            whereArgs: [transaction.id],
          );
          if (count == 0) {
            throw RepositoryException('That transaction no longer exists.');
          }
        },
      );

  @override
  Future<void> delete(String id) => _guard(
        'Could not delete the transaction.',
        () async {
          final count = await _db.delete(
            _table,
            where: 'id = ?',
            whereArgs: [id],
          );
          if (count == 0) {
            throw RepositoryException('That transaction no longer exists.');
          }
        },
      );
}
