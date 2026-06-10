// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/widgets/list_card.dart
// CAMADA    : Presentation
// PROPÓSITO : Card de lista na HomeScreen.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../domain/entities/shopping_list.dart';

/// Card clicável que representa uma ShoppingList.
class ListCard extends StatelessWidget {
  final ShoppingList list;
  final VoidCallback onTap;
  final VoidCallback? onArchive;

  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.list_alt,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Criada em ${_formatDate(list.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onArchive != null)
                IconButton(
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: 'Arquivar',
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
