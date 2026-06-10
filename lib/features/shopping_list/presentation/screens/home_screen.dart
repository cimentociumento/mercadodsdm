// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/screens/home_screen.dart
// CAMADA    : Presentation
// PROPÓSITO : Tela principal com todas as listas ativas.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../domain/entities/shopping_list.dart';
import '../notifiers/shopping_list_notifier.dart';
import '../widgets/empty_state.dart';
import '../widgets/list_card.dart';
import '../widgets/list_header_delegate.dart';

/// Home com CustomScrollView + SliverPersistentHeader.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ShoppingList>> listsAsync =
        ref.watch(shoppingListNotifierProvider);

    return Scaffold(
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _buildError(context, ref, err),
        data: (lists) => _buildContent(context, ref, lists),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Erro ao carregar listas: $err'),
          const Gap(8),
          ElevatedButton(
            onPressed: () => ref.invalidate(shoppingListNotifierProvider),
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<ShoppingList> lists,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('SmartList'),
          actions: [
            IconButton(
              onPressed: () => context.pushNamed(RouteNames.archived),
              icon: const Icon(Icons.archive_outlined),
            ),
            IconButton(
              onPressed: () => context.pushNamed(RouteNames.settings),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        SliverPersistentHeader(
          pinned: false,
          delegate: ListHeaderDelegate(
            minH: 72,
            maxH: 120,
            title: 'Minhas Listas',
            subtitle: '${lists.length} lista(s) ativa(s)',
          ),
        ),
        if (lists.isEmpty)
          const SliverFillRemaining(child: EmptyStateWidget(
            title: 'Nenhuma lista ainda',
            subtitle: 'Toque no + para criar sua primeira lista',
          ))
        else
          SliverList.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final ShoppingList list = lists[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListCard(
                  key: ValueKey(list.id),
                  list: list,
                  onTap: () => context.pushNamed(
                    RouteNames.listDetail,
                    pathParameters: {'listId': '${list.id}'},
                  ),
                  onArchive: () => ref
                      .read(shoppingListNotifierProvider.notifier)
                      .archiveList(list.id!),
                ),
              );
            },
          ),
        const SliverGap(80),
      ],
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ex: Compras da semana'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      await ref.read(shoppingListNotifierProvider.notifier).addList(name);
    }
  }
}
