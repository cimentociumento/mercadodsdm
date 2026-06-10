// =============================================================================
// ARQUIVO   : lib/features/voice/presentation/notifiers/voice_notifier.dart
// CAMADA    : Presentation
// PROPÓSITO : Ciclo de vida do Speech-to-Text.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/voice_parser.dart';
import '../../domain/voice_state.dart';

part 'voice_notifier.g.dart';

/// Encapsula STT, permissões e parsing de voz.
@riverpod
class VoiceNotifier extends _$VoiceNotifier {
  final SpeechToText _speech = SpeechToText();
  int _activeListId = 0;

  @override
  VoiceState build() => const VoiceStateIdle();

  /// Define a lista alvo para itens reconhecidos por voz.
  void setListId(int listId) => _activeListId = listId;

  Future<void> startListening() async {
    // Solicita permissão se ainda não concedida
    var status = await ref.read(permissionProvider.future);
    if (status != PermissionStatus.granted) {
      status = await Permission.microphone.request();
      ref.invalidate(permissionProvider);
    }

    if (status != PermissionStatus.granted) {
      state = const VoiceStatePermissionDenied();
      return;
    }

    final bool isAvailable = await _speech.initialize(
      onError: (error) => state = VoiceStateError(error.errorMsg),
      onStatus: _onSpeechStatus,
    );

    if (!isAvailable) {
      state = const VoiceStateError('STT não disponível neste dispositivo');
      return;
    }

    await SystemSound.play(SystemSoundType.click);
    state = const VoiceStateListening();

    await _speech.listen(
      onResult: (result) {
        state = VoiceStateRecognized(result.recognizedWords);
        if (result.finalResult) {
          _handleFinalResult(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        localeId: 'pt_BR',
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    await SystemSound.play(SystemSoundType.click);
    state = const VoiceStateIdle();
  }

  void _handleFinalResult(String rawText) {
    final item = VoiceParser.parse(rawText, listId: _activeListId);
    if (item != null) {
      state = VoiceStateItemReady(item);
    } else {
      state = VoiceStateUnrecognized(rawText);
    }
  }

  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      if (state is! VoiceStateItemReady && state is! VoiceStateError) {
        state = const VoiceStateIdle();
      }
    }
  }

  void reset() => state = const VoiceStateIdle();
}
