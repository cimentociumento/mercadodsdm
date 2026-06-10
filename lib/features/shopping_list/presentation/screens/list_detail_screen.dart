// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/screens/list_detail_screen.dart
// CAMADA    : Presentation
// PROPÓSITO : Detalhe da lista com AnimatedList e busca em tempo real.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../domain/entities/shopping_item.dart';
import '../notifiers/active_list_items_notifier.dart';
import '../widgets/add_item_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_tile.dart';
import '../widgets/progress_indicator_widget.dart';
import '../../../voice/presentation/widgets/voice_bottom_sheet.dart';

/// Tela de itens com AnimatedList, busca e modo reordenar.
class ListDetailScreen extends ConsumerStatefulWidget {
  final int listId;

  const ListDetailScreen({super.key, required this.listId});

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final ValueNotifier<String> _searchQuery = ValueNotifier('');
  var _reorderMode = false;
  List<ShoppingItem> _cachedItems = [];

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ShoppingItem>> itemsAsync =
        ref.watch(activeListItemsNotifierProvider(widget.listId));

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
        data: (items) {
          _syncAnimatedList(items);
          return _buildBody(items);
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'voice',
            onPressed: () =>
                showVoiceBottomSheet(context, listId: widget.listId),
            child: const Icon(Icons.mic),
          ),
          const Gap(8),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () =>
                showAddItemSheet(context, listId: widget.listId),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _syncAnimatedList(List<ShoppingItem> items) {
    // Detecta inserções para animar via AnimatedList
    if (items.length > _cachedItems.length) {
      final ShoppingItem? newItem = items.cast<ShoppingItem?>().firstWhere(
            (i) => !_cachedItems.any((c) => c.id == i?.id),
            orElse: () => null,
          );
      if (newItem != null) {
        _listKey.currentState?.insertItem(
          0,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
    _cachedItems = List.of(items);
  }

  Widget _buildBody(List<ShoppingItem> items) {
    final int checked = items.where((i) => i.isChecked).length;
    final double progress = items.isEmpty ? 0 : checked / items.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListProgressIndicator(progress: progress),
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
            onChanged: (value) => _searchQuery.value = value,
          ),
        ),
        const Gap(8),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: _searchQuery,
            builder: (context, query, _) {
              final List<ShoppingItem> filtered = items
                  .where((i) =>
                      i.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();

              if (filtered.isEmpty) {
                return const EmptyStateWidget(
                  title: 'Lista vazia',
                  subtitle: 'Adicione itens manualmente ou por voz',
                  icon: Icons.shopping_cart_outlined,
                );
              }

              if (_reorderMode) {
                return _buildReorderableList(filtered);
              }

              return _buildAnimatedList(filtered);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedList(List<ShoppingItem> items) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: items.length,
      itemBuilder: (context, index, animation) {
        return SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
              CurveTween(curve: Curves.easeOutCubic),
            ),
          ),
          child: ItemTile(
            key: ValueKey(items[index].id),
            item: items[index],
            listId: widget.listId,
          ),
        );
      },
    );
  }

  Widget _buildReorderableList(List<ShoppingItem> items) {
    return ReorderableListView.builder(
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        final int adjustedNew =
            newIndex > oldIndex ? newIndex - 1 : newIndex;
        ref
            .read(activeListItemsNotifierProvider(widget.listId).notifier)
            .reorder(oldIndex, adjustedNew);
      },
      itemBuilder: (context, index) {
        final ShoppingItem item = items[index];
        return ItemTile(
          key: ValueKey(item.id),
          item: item,
          listId: widget.listId,
        );
      },
    );
  }
}
