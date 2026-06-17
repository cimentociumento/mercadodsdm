import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/shopping_item.dart';
import '../providers/providers.dart';

class ItemTile extends ConsumerWidget {
  const ItemTile({super.key, required this.item, required this.listId});

  final ShoppingItem item;
  final int listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(listItemsProvider(listId).notifier);

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
        onChanged: (_) => notifier.toggleItem(item),
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
