import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../models/shopping_item.dart';
import '../providers/providers.dart';
import 'voice_sheet.dart';

class AddItemSheet extends ConsumerStatefulWidget {
  const AddItemSheet({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    await ref.read(listItemsProvider(widget.listId).notifier).addItem(
          ShoppingItem(
            listId: widget.listId,
            name: name,
            createdAt: DateTime.now(),
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Nome do item',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showVoiceSheet(context, listId: widget.listId);
                  },
                  icon: const Icon(Icons.mic),
                  label: const Text('Por voz'),
                ),
              ),
              const Gap(8),
              Expanded(
                child: FilledButton(onPressed: _submit, child: const Text('Adicionar')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showAddItemSheet(BuildContext context, {required int listId}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AddItemSheet(listId: listId),
  );
}
