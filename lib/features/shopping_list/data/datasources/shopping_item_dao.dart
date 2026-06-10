// =============================================================================
// ARQUIVO   : lib/features/shopping_list/data/datasources/shopping_item_dao.dart
// CAMADA    : Data
// PROPÓSITO : Acesso SQL à tabela shopping_items.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:sqflite/sqflite.dart';

import '../../domain/entities/shopping_item.dart';
import '../models/shopping_item_model.dart';

/// DAO responsável por operações CRUD em shopping_items.
class ShoppingItemDao {
  final Database _db;

  const ShoppingItemDao(this._db);

  Future<List<ShoppingItem>> getByListId(int listId) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'shopping_items',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'position ASC, created_at ASC',
    );

    return rows.map(ShoppingItemModel.fromMap).toList();
  }

  Future<int> insert(ShoppingItem item) async {
    // Calcula próxima posição se não informada explicitamente
    var position = item.position;
    if (position == 0) {
      final List<Map<String, Object?>> result = await _db.rawQuery(
        'SELECT MAX(position) as max_pos FROM shopping_items WHERE list_id = ?',
        [item.listId],
      );
      final Object? maxPos = result.first['max_pos'];
      position = (maxPos as int? ?? -1) + 1;
    }

    final Map<String, Object?> data = ShoppingItemModel.toMap(
      item.copyWith(position: position),
    );
    data.remove('id');

    return _db.insert('shopping_items', data);
  }

  Future<void> update(ShoppingItem item) async {
    if (item.id == null) return;

    await _db.update(
      'shopping_items',
      ShoppingItemModel.toMap(item),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(int itemId) async {
    await _db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> reorder(int listId, int oldIndex, int newIndex) async {
    final List<ShoppingItem> items = await getByListId(listId);
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= items.length ||
        newIndex >= items.length) {
      return;
    }

    final ShoppingItem moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);

    final Batch batch = _db.batch();
    for (var i = 0; i < items.length; i++) {
      final ShoppingItem updated = items[i].copyWith(position: i);
      batch.update(
        'shopping_items',
        {'position': i},
        where: 'id = ?',
        whereArgs: [updated.id],
      );
    }
    await batch.commit(noResult: true);
  }
}
