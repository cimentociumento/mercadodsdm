// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/widgets/empty_state.dart
// CAMADA    : Presentation
// PROPÓSITO : Placeholder visual para listas vazias.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Widget dedicado quando não há dados para exibir.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    this.title = 'Nada por aqui',
    this.subtitle = 'Toque no + para começar',
    this.icon = Icons.shopping_basket_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const Gap(12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const Gap(4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
