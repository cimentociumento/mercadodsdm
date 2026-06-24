import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../models/shopping_list.dart';

class ListCard extends StatelessWidget {
  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.onArchive,
  });

  final ShoppingList list;
  final VoidCallback onTap;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.list_alt, color: Theme.of(context).colorScheme.primary),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(list.name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      'Criada em ${_formatDate(list.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (onArchive != null)
                IconButton(
                  onPressed: () {
                    // Evita que o toque no arquivar dispare o onTap do card
                    onArchive!();
                  },
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
