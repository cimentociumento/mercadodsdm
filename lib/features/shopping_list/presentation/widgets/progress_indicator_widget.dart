// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/widgets/progress_indicator_widget.dart
// CAMADA    : Presentation
// PROPÓSITO : Barra de progresso animada com TweenAnimationBuilder.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Indicador de progresso (itens comprados / total).
class ListProgressIndicator extends StatelessWidget {
  final double progress;

  const ListProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: progress),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return LinearProgressIndicator(
          value: value,
          color: Color.lerp(ColorTokens.amber500, ColorTokens.emerald500, value),
          backgroundColor: Colors.grey.shade200,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        );
      },
    );
  }
}
