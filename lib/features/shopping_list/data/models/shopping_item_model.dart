// =============================================================================
// ARQUIVO   : lib/features/shopping_list/data/models/shopping_item_model.dart
// CAMADA    : Data
// PROPÓSITO : Mapeamento SQL ↔ entidade ShoppingItem.
// VERSÃO    : 0.1.0
// =============================================================================

import '../../domain/entities/shopping_item.dart';

/// Model de persistência — converte linhas do SQLite em entidades.
class ShoppingItemModel {
  static ShoppingItem fromMap(Map<String, Object?> map) {
    return ShoppingItem(
      id: map['id'] as int?,
      listId: map['list_id'] as int,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String?,
      isChecked: (map['is_checked'] as int) == 1,
      addedByVoice: (map['added_by_voice'] as int) == 1,
      category: map['category'] as String?,
      position: map['position'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  static Map<String, Object?> toMap(ShoppingItem item) {
    return {
      if (item.id != null) 'id': item.id,
      'list_id': item.listId,
      'name': item.name,
      'quantity': item.quantity,
      'unit': item.unit,
      'is_checked': item.isChecked ? 1 : 0,
      'added_by_voice': item.addedByVoice ? 1 : 0,
      'category': item.category,
      'position': item.position,
      'created_at': item.createdAt.millisecondsSinceEpoch,
    };
  }
}
