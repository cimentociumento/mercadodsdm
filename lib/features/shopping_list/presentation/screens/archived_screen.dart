// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/screens/archived_screen.dart
// CAMADA    : Presentation
// PROPÓSITO : Listas arquivadas com opção de restaurar.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../domain/entities/shopping_list.dart';
import '../notifiers/shopping_list_notifier.dart';
import '../widgets/empty_state.dart';

/// Exibe listas arquivadas e permite restauração.
class ArchivedScreen extends ConsumerWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ShoppingList>> archivedAsync =
        ref.watch(archivedListsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Arquivadas')),
      body: archivedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (lists) {
          if (lists.isEmpty) {
            return const EmptyStateWidget(
              title: 'Nenhuma lista arquivada',
              subtitle: 'Listas arquivadas aparecerão aqui',
              icon: Icons.archive_outlined,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final ShoppingList list = lists[index];
              return ListTile(
                key: ValueKey(list.id),
                leading: const Icon(Icons.archive),
                title: Text(list.name),
                trailing: TextButton(
                  onPressed: () => ref
                      .read(archivedListsNotifierProvider.notifier)
                      .restoreList(list.id!),
                  child: const Text('Restaurar'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
