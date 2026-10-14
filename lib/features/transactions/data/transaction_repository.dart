import '../domain/transaction.dart';

/// Thrown when a storage operation fails. The UI shows [message] to the user.
class RepositoryException implements Exception {
  RepositoryException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'RepositoryException: $message';
}

/// Storage contract. Providers depend on this, not on sqflite.
abstract class TransactionRepository {
  Future<List<MoneyTransaction>> getAll();
  Future<MoneyTransaction?> getById(String id);
  Future<void> insert(MoneyTransaction transaction);

  /// Inserts all or none (single database transaction).
  Future<void> insertAll(List<MoneyTransaction> transactions);
  Future<void> update(MoneyTransaction transaction);
  Future<void> delete(String id);
}
