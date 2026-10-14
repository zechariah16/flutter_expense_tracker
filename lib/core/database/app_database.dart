import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

/// Opens the SQLite database and owns the schema + migrations.
class AppDatabase {
  AppDatabase._();

  /// Bump this when the schema changes and add a step to [_migrations].
  static const int version = 1;

  /// Pass [path] (e.g. inMemoryDatabasePath) in tests.
  static Future<Database> open({String? path}) async {
    final dbPath =
        path ?? p.join(await getDatabasesPath(), AppConstants.databaseName);
    return openDatabase(
      dbPath,
      version: version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute('''
      CREATE TABLE transactions (
        id            TEXT    PRIMARY KEY,
        title         TEXT    NOT NULL CHECK (length(trim(title)) > 0),
        amount_minor  INTEGER NOT NULL CHECK (amount_minor > 0),
        type          TEXT    NOT NULL CHECK (type IN ('income', 'expense')),
        category_id   TEXT    NOT NULL,
        date          TEXT    NOT NULL,
        created_at    INTEGER NOT NULL,
        updated_at    INTEGER NOT NULL
      )
    ''');
    batch.execute('CREATE INDEX idx_transactions_date ON transactions (date)');
    batch.execute(
      'CREATE INDEX idx_transactions_type_date ON transactions (type, date)',
    );
    await batch.commit(noResult: true);
  }

  /// One entry per schema version, keyed by the version it migrates TO.
  /// Example for a future v2:
  ///   2: (db) => db.execute('ALTER TABLE transactions ADD COLUMN note TEXT'),
  static final Map<int, Future<void> Function(Database db)> _migrations = {};

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (var v = oldVersion + 1; v <= newVersion; v++) {
      final migrate = _migrations[v];
      if (migrate == null) {
        throw StateError('Missing database migration to version $v');
      }
      await migrate(db);
    }
  }
}
