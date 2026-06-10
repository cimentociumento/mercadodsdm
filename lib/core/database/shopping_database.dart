// =============================================================================
// ARQUIVO   : lib/core/database/shopping_database.dart
// CAMADA    : Core / Data
// PROPÓSITO : Gerencia o ciclo de vida do banco SQLite via sqflite.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

/// Singleton que abre e mantém a instância única do SQLite.
class ShoppingDatabase {
  // Instância privada — impede que código externo crie um segundo banco
  static final ShoppingDatabase _instance = ShoppingDatabase._internal();

  // Factory retorna sempre a mesma instância (Singleton pattern)
  factory ShoppingDatabase() => _instance;
  ShoppingDatabase._internal();

  // '_db' é nullable porque só é inicializado na primeira chamada a 'database'
  Database? _db;

  /// Getter lazy: abre/cria o banco apenas quando for necessário pela 1ª vez.
  Future<Database> get database async {
    // Se já inicializado, retorna direto — evita abrir o arquivo duas vezes
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // getDatabasesPath() retorna o diretório persistente do sistema operacional
    final String path = join(
      await getDatabasesPath(),
      DATABASE_FILE_NAME,
    );

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Cria as tabelas na primeira vez que o app é instalado.
  Future<void> _onCreate(Database db, int version) async {
    // Usa batch para executar múltiplos SQL atomicamente (tudo ou nada)
    final Batch batch = db.batch();

    batch.execute('''
      CREATE TABLE shopping_lists (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        name        TEXT    NOT NULL,
        created_at  INTEGER NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    batch.execute('''
      CREATE TABLE shopping_items (
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id        INTEGER NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
        name           TEXT    NOT NULL,
        quantity       REAL    NOT NULL DEFAULT 1.0,
        unit           TEXT,
        is_checked     INTEGER NOT NULL DEFAULT 0,
        added_by_voice INTEGER NOT NULL DEFAULT 0,
        category       TEXT,
        position       INTEGER NOT NULL DEFAULT 0,
        created_at     INTEGER NOT NULL
      )
    ''');

    // Índice acelera queries por list_id (checklist do pré-projeto)
    batch.execute('''
      CREATE INDEX idx_shopping_items_list_id ON shopping_items(list_id)
    ''');

    await batch.commit(noResult: true);
  }

  // TODO(dev): adicionar lógica de migração quando version chegar em 2
  Future<void> _onUpgrade(Database db, int oldV, int newV) async {}
}
