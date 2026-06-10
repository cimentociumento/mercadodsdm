// =============================================================================
// ARQUIVO   : lib/features/voice/presentation/widgets/mic_animated_icon.dart
// CAMADA    : Presentation
// PROPÓSITO : Ícone de microfone com animação pulsante isolada.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';

/// Animação do microfone envolvida em RepaintBoundary na tela pai.
class MicAnimatedIcon extends StatefulWidget {
  final bool isListening;

  const MicAnimatedIcon({super.key, required this.isListening});

  @override
  State<MicAnimatedIcon> createState() => _MicAnimatedIconState();
}

class _MicAnimatedIconState extends State<MicAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isListening) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant MicAnimatedIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isListening) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Icon(
        widget.isListening ? Icons.mic : Icons.mic_none,
        size: 72,
        color: widget.isListening ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
