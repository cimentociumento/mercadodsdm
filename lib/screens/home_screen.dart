import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../models/shopping_list.dart';
import '../providers/providers.dart';
import '../router/app_router.dart';
import '../widgets/empty_state.dart';
import '../widgets/list_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(listsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartList'),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(Routes.archived),
            icon: const Icon(Icons.archive_outlined),
          ),
          IconButton(
            onPressed: () => context.pushNamed(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (lists) => _Body(lists: lists),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createList(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createList(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova lista'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Ex: Compras da semana'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref.read(listsProvider.notifier).addList(name);
    }
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.lists});

  final List<ShoppingList> lists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (lists.isEmpty) {
      return const EmptyState(
        title: 'Nenhuma lista ainda',
        subtitle: 'Toque no + para criar sua primeira lista',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Minhas Listas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text('${lists.length} lista(s) ativa(s)'),
        const Gap(16),
        for (final list in lists)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ListCard(
              list: list,
              onTap: () => context.pushNamed(
                Routes.listDetail,
                pathParameters: {'listId': '${list.id}'},
              ),
              onArchive: () =>
                  ref.read(listsProvider.notifier).archiveList(list.id!),
            ),
          ),
      ],
    );
  }
}
