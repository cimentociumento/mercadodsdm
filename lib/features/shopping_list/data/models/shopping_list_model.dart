// =============================================================================
// ARQUIVO   : lib/features/shopping_list/data/models/shopping_list_model.dart
// CAMADA    : Data
// PROPÓSITO : Mapeamento SQL ↔ entidade ShoppingList.
// VERSÃO    : 0.1.0
// =============================================================================

import '../../domain/entities/shopping_list.dart';

/// Model de persistência para shopping_lists.
class ShoppingListModel {
  static ShoppingList fromMap(Map<String, Object?> map) {
    return ShoppingList(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      isArchived: (map['is_archived'] as int) == 1,
    );
  }

  static Map<String, Object?> toMap(ShoppingList list) {
    return {
      if (list.id != null) 'id': list.id,
      'name': list.name,
      'created_at': list.createdAt.millisecondsSinceEpoch,
      'is_archived': list.isArchived ? 1 : 0,
    };
  }
}
