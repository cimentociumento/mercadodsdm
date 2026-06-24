import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/providers.dart';
import '../widgets/empty_state.dart';

class ArchivedScreen extends ConsumerWidget {
  const ArchivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Arquivadas')),
      body: archivedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (lists) {
          if (lists.isEmpty) {
            return const EmptyState(
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
              final list = lists[index];
              return ListTile(
                leading: const Icon(Icons.archive),
                title: Text(list.name),
                trailing: TextButton(
                  onPressed: () async {
                    await ref
                        .read(archivedListsProvider.notifier)
                        .restoreList(list.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lista "${list.name}" restaurada')),
                      );
                    }
                  },
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
