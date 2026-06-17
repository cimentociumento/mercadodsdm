import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../models/shopping_item.dart';
import '../providers/providers.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/progress_bar.dart';
import '../widgets/voice_sheet.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  const ListDetailScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  var _search = '';
  var _reorderMode = false;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(listItemsProvider(widget.listId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itens da lista'),
        actions: [
          IconButton(
            onPressed: () => setState(() => _reorderMode = !_reorderMode),
            icon: Icon(_reorderMode ? Icons.check : Icons.swap_vert),
            tooltip: _reorderMode ? 'Concluir' : 'Reordenar',
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (items) => _buildBody(items),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'voice',
            onPressed: () => showVoiceSheet(context, listId: widget.listId),
            child: const Icon(Icons.mic),
          ),
          const Gap(8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => showAddItemSheet(context, listId: widget.listId),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<ShoppingItem> items) {
    final checked = items.where((i) => i.isChecked).length;
    final progress = items.isEmpty ? 0.0 : checked / items.length;
    final filtered = items
        .where((i) => i.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ProgressBar(progress: progress),
              const Gap(8),
              Text('$checked de ${items.length} comprados'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar item...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _search = value),
          ),
        ),
        const Gap(8),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  title: 'Lista vazia',
                  subtitle: 'Adicione itens manualmente ou por voz',
                  icon: Icons.shopping_cart_outlined,
                )
              : _reorderMode
                  ? ReorderableListView.builder(
                      itemCount: filtered.length,
                      onReorder: (oldIndex, newIndex) {
                        final adjusted =
                            newIndex > oldIndex ? newIndex - 1 : newIndex;
                        ref
                            .read(listItemsProvider(widget.listId).notifier)
                            .reorder(oldIndex, adjusted);
                      },
                      itemBuilder: (_, index) => ItemTile(
                        key: ValueKey(filtered[index].id),
                        item: filtered[index],
                        listId: widget.listId,
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, index) => ItemTile(
                        item: filtered[index],
                        listId: widget.listId,
                      ),
                    ),
        ),
      ],
    );
  }
}
