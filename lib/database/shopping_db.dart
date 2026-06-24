import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/shopping_item.dart';
import '../models/shopping_list.dart';

const _dbFileName = 'smartlist.db';

/// Banco SQLite local — única camada de persistência do app.
class ShoppingDb {
  ShoppingDb._();
  static final ShoppingDb instance = ShoppingDb._();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbFileName);
    return openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, _) async {
        final batch = database.batch();
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
            list_id        INTEGER NOT NULL,
            name           TEXT    NOT NULL,
            quantity       REAL    NOT NULL DEFAULT 1.0,
            unit           TEXT,
            is_checked     INTEGER NOT NULL DEFAULT 0,
            added_by_voice INTEGER NOT NULL DEFAULT 0,
            position       INTEGER NOT NULL DEFAULT 0,
            created_at     INTEGER NOT NULL
          )
        ''');
        batch.execute(
          'CREATE INDEX idx_shopping_items_list_id ON shopping_items(list_id)',
        );
        await batch.commit(noResult: true);
      },
    );
  }

  // --- Listas ---

  Future<List<ShoppingList>> getLists({bool archived = false}) async {
    final database = await db;
    final rows = await database.query(
      'shopping_lists',
      where: 'is_archived = ?',
      whereArgs: [archived ? 1 : 0],
      orderBy: 'created_at DESC',
    );
    return rows.map(_listFromRow).toList();
  }

  Future<int> createList(String name) async {
    final database = await db;
    return database.insert('shopping_lists', {
      'name': name,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_archived': 0,
    });
  }

  Future<void> deleteList(int listId) async {
    final database = await db;
    await database.delete('shopping_items', where: 'list_id = ?', whereArgs: [listId]);
    await database.delete('shopping_lists', where: 'id = ?', whereArgs: [listId]);
  }

  Future<void> setArchived(int listId, {required bool archived}) async {
    final database = await db;
    await database.update(
      'shopping_lists',
      {'is_archived': archived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  // --- Itens ---

  Future<List<ShoppingItem>> getItems(int listId) async {
    final database = await db;
    final rows = await database.query(
      'shopping_items',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'position ASC, created_at ASC',
    );
    return rows.map(_itemFromRow).toList();
  }

  Future<int> addItem(ShoppingItem item) async {
    final database = await db;
    var position = item.position;
    if (position == 0) {
      final result = await database.rawQuery(
        'SELECT MAX(position) as max_pos FROM shopping_items WHERE list_id = ?',
        [item.listId],
      );
      position = ((result.first['max_pos'] as int?) ?? -1) + 1;
    }

    return database.insert('shopping_items', {
      'list_id': item.listId,
      'name': item.name,
      'quantity': item.quantity,
      'unit': item.unit,
      'is_checked': item.isChecked ? 1 : 0,
      'added_by_voice': item.addedByVoice ? 1 : 0,
      'position': position,
      'created_at': item.createdAt.millisecondsSinceEpoch,
    });
  }

  Future<void> updateItem(ShoppingItem item) async {
    if (item.id == null) return;
    final database = await db;
    await database.update(
      'shopping_items',
      {
        'name': item.name,
        'quantity': item.quantity,
        'unit': item.unit,
        'is_checked': item.isChecked ? 1 : 0,
        'added_by_voice': item.addedByVoice ? 1 : 0,
        'position': item.position,
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> removeItem(int itemId) async {
    final database = await db;
    await database.delete('shopping_items', where: 'id = ?', whereArgs: [itemId]);
  }

  Future<void> reorderItems(int listId, int oldIndex, int newIndex) async {
    final items = await getItems(listId);
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= items.length ||
        newIndex >= items.length) {
      return;
    }

    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);

    final database = await db;
    final batch = database.batch();
    for (var i = 0; i < items.length; i++) {
      batch.update(
        'shopping_items',
        {'position': i},
        where: 'id = ?',
        whereArgs: [items[i].id],
      );
    }
    await batch.commit(noResult: true);
  }

  ShoppingList _listFromRow(Map<String, Object?> row) {
    return ShoppingList(
      id: row['id'] as int,
      name: row['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      isArchived: (row['is_archived'] as int) == 1,
    );
  }

  ShoppingItem _itemFromRow(Map<String, Object?> row) {
    return ShoppingItem(
      id: row['id'] as int,
      listId: row['list_id'] as int,
      name: row['name'] as String,
      quantity: (row['quantity'] as num).toDouble(),
      unit: row['unit'] as String?,
      isChecked: (row['is_checked'] as int) == 1,
      addedByVoice: (row['added_by_voice'] as int) == 1,
      position: row['position'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    );
  }
}
