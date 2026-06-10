// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/widgets/list_header_delegate.dart
// CAMADA    : Presentation
// PROPÓSITO : SliverPersistentHeader colapsável da HomeScreen.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';

/// Delegate obrigatório para SliverPersistentHeader com animação de colapso.
class ListHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minH;
  final double maxH;
  final String title;
  final String subtitle;

  const ListHeaderDelegate({
    required this.minH,
    required this.maxH,
    required this.title,
    required this.subtitle,
  });

  @override
  double get minExtent => minH;

  @override
  double get maxExtent => maxH;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final double progress = shrinkOffset / (maxH - minH);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Opacity(
          opacity: (1.0 - progress).clamp(0.0, 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ListHeaderDelegate old) {
    return old.minH != minH || old.maxH != maxH || old.title != title;
  }
}
