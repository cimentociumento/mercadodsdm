import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 400),
      builder: (_, value, __) {
        return LinearProgressIndicator(
          value: value,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          color: Color.lerp(ColorTokens.amber500, ColorTokens.emerald500, value),
          backgroundColor: Colors.grey.shade200,
        );
      },
    );
  }
}
