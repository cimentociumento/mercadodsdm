// =============================================================================
// ARQUIVO   : lib/features/shopping_list/domain/entities/shopping_list.dart
// CAMADA    : Domain
// PROPÓSITO : Entidade de lista de compras do usuário.
// VERSÃO    : 0.1.0
// =============================================================================

/// Representa uma lista de compras persistida localmente.
class ShoppingList {
  final int? id;
  final String name;
  final DateTime createdAt;
  final bool isArchived;

  const ShoppingList({
    this.id,
    required this.name,
    required this.createdAt,
    this.isArchived = false,
  });

  ShoppingList copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
