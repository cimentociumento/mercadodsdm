// =============================================================================
// ARQUIVO   : lib/features/shopping_list/domain/entities/shopping_item.dart
// CAMADA    : Domain
// PROPÓSITO : Entidade pura de item de compra.
// VERSÃO    : 0.1.0
// =============================================================================

/// Entidade de domínio — sem dependências de Flutter ou sqflite.
class ShoppingItem {
  final int? id;
  final int listId;
  final String name;
  final double quantity;
  final String? unit;
  final bool isChecked;
  final bool addedByVoice;
  final String? category;
  final int position;
  final DateTime createdAt;

  const ShoppingItem({
    this.id,
    this.listId = 0,
    required this.name,
    this.quantity = 1.0,
    this.unit,
    this.isChecked = false,
    this.addedByVoice = false,
    this.category,
    this.position = 0,
    required this.createdAt,
  });

  /// copyWith retorna nova instância imutável com campos alterados.
  ShoppingItem copyWith({
    int? id,
    int? listId,
    String? name,
    double? quantity,
    String? unit,
    bool? isChecked,
    bool? addedByVoice,
    String? category,
    int? position,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      addedByVoice: addedByVoice ?? this.addedByVoice,
      category: category ?? this.category,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Regra de negócio: quantidade muito baixa indica alerta visual.
  bool get isLowQuantity => quantity < 0.1;
}
