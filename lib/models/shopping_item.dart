class ShoppingItem {
  final int? id;
  final int listId;
  final String name;
  final double quantity;
  final String? unit;
  final bool isChecked;
  final bool addedByVoice;
  final int position;
  final DateTime createdAt;

  const ShoppingItem({
    this.id,
    required this.listId,
    required this.name,
    this.quantity = 1.0,
    this.unit,
    this.isChecked = false,
    this.addedByVoice = false,
    this.position = 0,
    required this.createdAt,
  });

  ShoppingItem copyWith({
    int? id,
    int? listId,
    String? name,
    double? quantity,
    String? unit,
    bool? isChecked,
    bool? addedByVoice,
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
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
