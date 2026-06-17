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
}
