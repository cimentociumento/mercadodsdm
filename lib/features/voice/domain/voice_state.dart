// =============================================================================
// ARQUIVO   : lib/features/voice/domain/voice_state.dart
// CAMADA    : Domain
// PROPÓSITO : Estados do módulo de reconhecimento de voz.
// VERSÃO    : 0.1.0
// =============================================================================

import '../../shopping_list/domain/entities/shopping_item.dart';

/// Hierarquia de estados para o VoiceNotifier e widgets de UI.
sealed class VoiceState {
  const VoiceState();

  bool get isListening => this is VoiceStateListening;
}

final class VoiceStateIdle extends VoiceState {
  const VoiceStateIdle();
}

final class VoiceStateListening extends VoiceState {
  const VoiceStateListening();
}

final class VoiceStatePermissionDenied extends VoiceState {
  const VoiceStatePermissionDenied();
}

final class VoiceStateRecognized extends VoiceState {
  final String text;
  const VoiceStateRecognized(this.text);
}

final class VoiceStateItemReady extends VoiceState {
  final ShoppingItem item;
  const VoiceStateItemReady(this.item);
}

final class VoiceStateUnrecognized extends VoiceState {
  final String text;
  const VoiceStateUnrecognized(this.text);
}

final class VoiceStateError extends VoiceState {
  final String message;
  const VoiceStateError(this.message);
}
