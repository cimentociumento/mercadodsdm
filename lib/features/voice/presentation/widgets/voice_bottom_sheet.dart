// =============================================================================
// ARQUIVO   : lib/features/voice/presentation/widgets/voice_bottom_sheet.dart
// CAMADA    : Presentation
// PROPÓSITO : Bottom sheet arrastável com feedback de STT.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../shopping_list/presentation/notifiers/active_list_items_notifier.dart';
import '../../domain/voice_state.dart';
import '../notifiers/voice_notifier.dart';
import 'mic_animated_icon.dart';

/// Conteúdo do DraggableScrollableSheet de voz.
class VoiceBottomSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final int listId;

  const VoiceBottomSheetContent({
    super.key,
    required this.scrollController,
    required this.listId,
  });

  @override
  ConsumerState<VoiceBottomSheetContent> createState() =>
      _VoiceBottomSheetContentState();
}

class _VoiceBottomSheetContentState
    extends ConsumerState<VoiceBottomSheetContent> {
  @override
  void initState() {
    super.initState();
    ref.read(voiceNotifierProvider.notifier).setListId(widget.listId);
  }

  @override
  Widget build(BuildContext context) {
    final VoiceState voiceState = ref.watch(voiceNotifierProvider);
    final notifier = ref.read(voiceNotifierProvider.notifier);

    // Quando item está pronto, adiciona à lista e fecha feedback
    ref.listen(voiceNotifierProvider, (prev, next) async {
      if (next is VoiceStateItemReady) {
        await ref
            .read(activeListItemsNotifierProvider(widget.listId).notifier)
            .addItem(next.item);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Adicionado: ${next.item.name}')),
        );
        notifier.reset();
      }
    });

    return Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),
          const Text(
            'Fale o item que deseja adicionar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Gap(16),
          Center(
            child: RepaintBoundary(
              child: MicAnimatedIcon(isListening: voiceState.isListening),
            ),
          ),
          const Gap(16),
          _buildStatusText(voiceState),
          const Gap(24),
          _buildMicButton(voiceState, notifier),
        ],
      ),
    );
  }

  Widget _buildStatusText(VoiceState state) {
    final String text = switch (state) {
      VoiceStateListening() => 'Ouvindo... fale agora',
      VoiceStateRecognized(:final text) => 'Reconhecido: $text',
      VoiceStateUnrecognized(:final text) => 'Não entendi: $text',
      VoiceStatePermissionDenied() => 'Permissão de microfone negada',
      VoiceStateError(:final message) => 'Erro: $message',
      VoiceStateItemReady(:final item) => 'Item pronto: ${item.name}',
      _ => 'Toque no botão para começar',
    };

    return Text(text, textAlign: TextAlign.center);
  }

  Widget _buildMicButton(VoiceState state, VoiceNotifier notifier) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: switch (state) {
          VoiceStateListening() => FilledButton.icon(
              key: const ValueKey('stop'),
              onPressed: notifier.stopListening,
              icon: const Icon(Icons.stop),
              label: const Text('Parar'),
            ),
          _ => FilledButton.icon(
              key: const ValueKey('start'),
              onPressed: notifier.startListening,
              icon: const Icon(Icons.mic),
              label: const Text('Iniciar voz'),
            ),
        },
      ),
    );
  }
}

/// Abre o bottom sheet com DraggableScrollableSheet.
void showVoiceBottomSheet(BuildContext context, {required int listId}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [0.35, 0.75],
      builder: (ctx, scrollController) {
        return VoiceBottomSheetContent(
          scrollController: scrollController,
          listId: listId,
        );
      },
    ),
  );
}
