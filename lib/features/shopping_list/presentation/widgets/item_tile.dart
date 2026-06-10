// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/widgets/item_tile.dart
// CAMADA    : Presentation
// PROPÓSITO : Tile de item com swipe para deletar.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../domain/entities/shopping_item.dart';
import '../notifiers/active_list_items_notifier.dart';

/// Apresentação de um ShoppingItem com ações de toggle e delete.
class ItemTile extends ConsumerWidget {
  final ShoppingItem item;
  final int listId;

  const ItemTile({
    required super.key,
    required this.item,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(activeListItemsNotifierProvider(listId).notifier);

    return Slidable(
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) {
              if (item.id != null) notifier.removeItem(item.id!);
            },
            backgroundColor: Colors.red,
            icon: Icons.delete_outline,
            label: 'Remover',
          ),
        ],
      ),
      child: CheckboxListTile(
        value: item.isChecked,
        onChanged: (_) => notifier.toggleItem(
          item.copyWith(isChecked: !item.isChecked),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked ? Colors.grey : null,
          ),
        ),
        subtitle: item.unit != null ? Text('${item.quantity} ${item.unit}') : null,
        secondary: item.addedByVoice
            ? const Tooltip(
                message: 'Adicionado por voz',
                child: Icon(Icons.mic, size: 16, color: Colors.indigo),
              )
            : null,
      ),
    );
  }
}
