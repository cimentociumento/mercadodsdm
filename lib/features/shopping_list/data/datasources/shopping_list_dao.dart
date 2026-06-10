// =============================================================================
// ARQUIVO   : lib/features/shopping_list/data/datasources/shopping_list_dao.dart
// CAMADA    : Data
// PROPÓSITO : Acesso SQL à tabela shopping_lists.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:sqflite/sqflite.dart';

import '../../domain/entities/shopping_list.dart';
import '../models/shopping_list_model.dart';

/// DAO responsável por operações CRUD em shopping_lists.
class ShoppingListDao {
  final Database _db;

  const ShoppingListDao(this._db);

  Future<List<ShoppingList>> getAll({required bool archived}) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'shopping_lists',
      where: 'is_archived = ?',
      whereArgs: [archived ? 1 : 0],
      orderBy: 'created_at DESC',
    );

    return rows.map(ShoppingListModel.fromMap).toList();
  }

  Future<ShoppingList?> getById(int id) async {
    final List<Map<String, Object?>> rows = await _db.query(
      'shopping_lists',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return ShoppingListModel.fromMap(rows.first);
  }

  Future<int> insert(String name) async {
    return _db.insert('shopping_lists', {
      'name': name,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'is_archived': 0,
    });
  }

  Future<void> delete(int listId) async {
    await _db.delete(
      'shopping_lists',
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  Future<void> setArchived(int listId, {required bool archived}) async {
    await _db.update(
      'shopping_lists',
      {'is_archived': archived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [listId],
    );
  }
}
