// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/widgets/add_item_sheet.dart
// CAMADA    : Presentation
// PROPÓSITO : Modal para adicionar item manualmente ou por voz.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../domain/entities/shopping_item.dart';
import '../../../voice/presentation/widgets/voice_bottom_sheet.dart';
import '../notifiers/active_list_items_notifier.dart';

/// Bottom sheet com campo de texto para adicionar item.
class AddItemSheet extends ConsumerStatefulWidget {
  final int listId;

  const AddItemSheet({super.key, required this.listId});

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String name = _controller.text.trim();
    if (name.isEmpty) return;

    await ref.read(activeListItemsNotifierProvider(widget.listId).notifier).addItem(
          ShoppingItem(
            listId: widget.listId,
            name: name,
            createdAt: DateTime.now(),
          ),
        );

    if (mounted) Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
                    showVoiceBottomSheet(context, listId: widget.listId);
                  },
                  icon: const Icon(Icons.mic),
                  label: const Text('Por voz'),
                ),
              ),
              const Gap(8),
              Expanded(
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('Adicionar'),
                ),
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
