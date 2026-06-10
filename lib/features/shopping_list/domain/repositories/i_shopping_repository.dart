// =============================================================================
// ARQUIVO   : lib/features/shopping_list/domain/repositories/i_shopping_repository.dart
// CAMADA    : Domain
// PROPÓSITO : Contrato do repositório de listas e itens.
// VERSÃO    : 0.1.0
// =============================================================================

import '../entities/shopping_item.dart';
import '../entities/shopping_list.dart';

/// Interface que a camada Data implementa — Domain não conhece SQLite.
abstract interface class IShoppingRepository {
  Future<List<ShoppingList>> getAllLists({bool archived = false});

  Future<ShoppingList?> getListById(int listId);

  Future<int> createList(String name);

  Future<void> deleteList(int listId);

  Future<void> archiveList(int listId, {required bool archived});

  Future<List<ShoppingItem>> getItemsByListId(int listId);

  Future<int> addItem(ShoppingItem item);

  Future<void> updateItem(ShoppingItem item);

  Future<void> removeItem(int itemId);

  Future<void> reorderItems(int listId, int oldIndex, int newIndex);
}
