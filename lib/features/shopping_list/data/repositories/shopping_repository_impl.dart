// =============================================================================
// ARQUIVO   : lib/features/shopping_list/data/repositories/shopping_repository_impl.dart
// CAMADA    : Data
// PROPÓSITO : Implementação concreta de IShoppingRepository.
// VERSÃO    : 0.1.0
// =============================================================================

import '../../../../core/database/shopping_database.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/repositories/i_shopping_repository.dart';
import '../datasources/shopping_item_dao.dart';
import '../datasources/shopping_list_dao.dart';

/// Repositório que orquestra DAOs e o singleton do banco.
class ShoppingRepositoryImpl implements IShoppingRepository {
  final ShoppingDatabase _database;

  const ShoppingRepositoryImpl(this._database);

  Future<ShoppingListDao> get _listDao async {
    final db = await _database.database;
    return ShoppingListDao(db);
  }

  Future<ShoppingItemDao> get _itemDao async {
    final db = await _database.database;
    return ShoppingItemDao(db);
  }

  @override
  Future<List<ShoppingList>> getAllLists({bool archived = false}) async {
    return (await _listDao).getAll(archived: archived);
  }

  @override
  Future<ShoppingList?> getListById(int listId) async {
    return (await _listDao).getById(listId);
  }

  @override
  Future<int> createList(String name) async {
    return (await _listDao).insert(name);
  }

  @override
  Future<void> deleteList(int listId) async {
    await (await _listDao).delete(listId);
  }

  @override
  Future<void> archiveList(int listId, {required bool archived}) async {
    await (await _listDao).setArchived(listId, archived: archived);
  }

  @override
  Future<List<ShoppingItem>> getItemsByListId(int listId) async {
    return (await _itemDao).getByListId(listId);
  }

  @override
  Future<int> addItem(ShoppingItem item) async {
    return (await _itemDao).insert(item);
  }

  @override
  Future<void> updateItem(ShoppingItem item) async {
    await (await _itemDao).update(item);
  }

  @override
  Future<void> removeItem(int itemId) async {
    await (await _itemDao).delete(itemId);
  }

  @override
  Future<void> reorderItems(int listId, int oldIndex, int newIndex) async {
    await (await _itemDao).reorder(listId, oldIndex, newIndex);
  }
}
