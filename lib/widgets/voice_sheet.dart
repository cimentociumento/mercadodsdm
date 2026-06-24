import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/providers.dart';

class VoiceSheet extends ConsumerStatefulWidget {
  const VoiceSheet({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends ConsumerState<VoiceSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceProvider.notifier).start(widget.listId);
    });
  }

  @override
  void dispose() {
    // Encerra STT ao fechar o sheet — evita microfone preso em "busy"
    ref.read(voiceProvider.notifier).stop();
    super.dispose();
  }

  Future<void> _toggleListening(VoiceNotifier notifier) async {
    final voice = ref.read(voiceProvider);
    if (voice.isListening) {
      await notifier.stop();
    } else {
      await notifier.start(widget.listId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final voice = ref.watch(voiceProvider);
    final notifier = ref.read(voiceProvider.notifier);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(20),
          Text(
            voice.isListening ? 'Ouvindo...' : 'Voz pausada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(8),
          const Text(
            'Fale vários itens: "leite, arroz e feijão"\nou pause entre cada palavra',
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Icon(
            Icons.mic,
            size: 72,
            color: voice.isListening ? Colors.red : Colors.grey,
          ),
          const Gap(12),
          if (voice.liveText.isNotEmpty)
            Text('Ouvido: ${voice.liveText}', textAlign: TextAlign.center),
          if (voice.error != null) ...[
            const Gap(8),
            Text(voice.error!, style: const TextStyle(color: Colors.red)),
          ],
          if (voice.addedNames.isNotEmpty) ...[
            const Gap(12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final name in voice.addedNames)
                  Chip(
                    avatar: const Icon(Icons.check, size: 16),
                    label: Text(name),
                  ),
              ],
            ),
          ],
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await notifier.stop();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Fechar'),
                ),
              ),
              const Gap(8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _toggleListening(notifier),
                  icon: Icon(voice.isListening ? Icons.stop : Icons.mic),
                  label: Text(voice.isListening ? 'Parar' : 'Ouvir'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showVoiceSheet(BuildContext context, {required int listId}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => VoiceSheet(listId: listId),
  );
}
