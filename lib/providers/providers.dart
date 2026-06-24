import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../database/shopping_db.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';
import '../router/app_router.dart';
import '../voice/voice_parser.dart';

final shoppingDbProvider = Provider((_) => ShoppingDb.instance);

final appRouterProvider = Provider((_) => createAppRouter());

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}

final listsProvider =
    AsyncNotifierProvider<ListsNotifier, List<ShoppingList>>(ListsNotifier.new);

class ListsNotifier extends AsyncNotifier<List<ShoppingList>> {
  @override
  Future<List<ShoppingList>> build() =>
      ref.read(shoppingDbProvider).getLists(archived: false);

  Future<void> addList(String name) async {
    await ref.read(shoppingDbProvider).createList(name);
    ref.invalidateSelf();
  }

  Future<void> archiveList(int listId) async {
    await ref.read(shoppingDbProvider).setArchived(listId, archived: true);
    ref.invalidateSelf();
    // Lista saiu das ativas e deve aparecer imediatamente em arquivadas
    ref.invalidate(archivedListsProvider);
  }
}

final archivedListsProvider =
    AsyncNotifierProvider<ArchivedListsNotifier, List<ShoppingList>>(
  ArchivedListsNotifier.new,
);

class ArchivedListsNotifier extends AsyncNotifier<List<ShoppingList>> {
  @override
  Future<List<ShoppingList>> build() =>
      ref.read(shoppingDbProvider).getLists(archived: true);

  Future<void> restoreList(int listId) async {
    await ref.read(shoppingDbProvider).setArchived(listId, archived: false);
    ref.invalidateSelf();
    // Lista restaurada deve voltar para a Home sem precisar recarregar manualmente
    ref.invalidate(listsProvider);
  }
}

final listItemsProvider = AsyncNotifierProvider.family<ListItemsNotifier,
    List<ShoppingItem>, int>(ListItemsNotifier.new);

class ListItemsNotifier extends FamilyAsyncNotifier<List<ShoppingItem>, int> {
  ShoppingDb get _db => ref.read(shoppingDbProvider);

  @override
  Future<List<ShoppingItem>> build(int listId) => _db.getItems(listId);

  Future<void> addItem(ShoppingItem item) async {
    final id = await _db.addItem(item);
    final current = state.value ?? [];
    state = AsyncData([...current, item.copyWith(id: id)]);
  }

  Future<void> toggleItem(ShoppingItem item) async {
    final updated = item.copyWith(isChecked: !item.isChecked);
    await _db.updateItem(updated);
    final current = state.value ?? [];
    state = AsyncData([
      for (final i in current) i.id == updated.id ? updated : i,
    ]);
  }

  Future<void> removeItem(int itemId) async {
    await _db.removeItem(itemId);
    final current = state.value ?? [];
    state = AsyncData(current.where((i) => i.id != itemId).toList());
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    await _db.reorderItems(arg, oldIndex, newIndex);
    state = AsyncData(await _db.getItems(arg));
  }
}

class VoiceUiState {
  final bool isListening;
  final String liveText;
  final List<String> addedNames;
  final String? error;

  const VoiceUiState({
    this.isListening = false,
    this.liveText = '',
    this.addedNames = const [],
    this.error,
  });

  VoiceUiState copyWith({
    bool? isListening,
    String? liveText,
    List<String>? addedNames,
    String? error,
    bool clearError = false,
  }) {
    return VoiceUiState(
      isListening: isListening ?? this.isListening,
      liveText: liveText ?? this.liveText,
      addedNames: addedNames ?? this.addedNames,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final voiceProvider =
    NotifierProvider<VoiceNotifier, VoiceUiState>(VoiceNotifier.new);

class VoiceNotifier extends Notifier<VoiceUiState> {
  final _speech = SpeechToText();
  var _initialized = false;
  var _active = false;
  var _listenInProgress = false;
  var _listId = 0;
  final _addedKeys = <String>{};

  @override
  VoiceUiState build() {
    ref.onDispose(() {
      _active = false;
      _safeStop();
    });
    return const VoiceUiState();
  }

  /// Libera o recurso de STT antes de iniciar nova sessão (evita erro "busy").
  Future<void> _safeStop() async {
    try {
      final wasListening = _speech.isListening;
      await _speech.cancel(); // Interrompe imediatamente
      if (wasListening) {
        // Aguarda a liberação nativa (Android) para evitar error_busy/client
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e, stack) {
      debugPrint('VoiceNotifier._safeStop: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      _listenInProgress = false;
    }
  }

  Future<void> start(int listId) async {
    await _safeStop();

    _listId = listId;
    _addedKeys.clear();
    _active = true;
    state = const VoiceUiState(isListening: true);

    var permission = await Permission.microphone.status;
    if (!permission.isGranted) {
      permission = await Permission.microphone.request();
    }
    if (!permission.isGranted) {
      _active = false;
      state = const VoiceUiState(error: 'Permissão de microfone negada');
      return;
    }

    if (!_initialized) {
      _initialized = await _speech.initialize(
        onError: _handleSpeechError,
        onStatus: _onStatus,
      );
    }

    if (!_initialized || !_speech.isAvailable) {
      _active = false;
      state = const VoiceUiState(error: 'Reconhecimento de voz indisponível');
      return;
    }

    await _listen();
  }

  Future<void> _listen() async {
    if (!_active || _listenInProgress) return;

    _listenInProgress = true;
    try {
      // Garante que não há sessão anterior ativa (regra 4.1 / 4.2 do rules.md)
      if (_speech.isListening) {
        await _speech.cancel();
        await Future.delayed(const Duration(milliseconds: 300));
      }

      state = state.copyWith(isListening: true, clearError: true);

      await _speech.listen(
        onResult: _onResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.dictation,
          localeId: 'pt_BR',
          listenFor: const Duration(seconds: 120),
          pauseFor: const Duration(seconds: 3), // Aumentado de 800ms para evitar timeout imediato
          cancelOnError: false,
        ),
      );
    } catch (e, stack) {
      debugPrint('VoiceNotifier._listen: $e');
      debugPrintStack(stackTrace: stack);
      if (_active) {
        state = state.copyWith(
          isListening: false,
          error: 'Erro ao iniciar microfone. Toque em Ouvir novamente.',
        );
      }
    } finally {
      _listenInProgress = false;
    }
  }

  void _handleSpeechError(dynamic error) {
    if (!_active) return;

    final String message = error.errorMsg ?? error.toString();
    debugPrint('VoiceNotifier._handleSpeechError: $message');

    final bool isTransient = message == 'error_no_match' || 
                             message == 'error_speech_timeout';

    if (isTransient) {
      // Ignora o encerramento do microfone para erros de ausência de fala e mantém isListening
      // para permitir o reinício automático pelo _onStatus (regra de ciclo de vida do rules.md).
      state = state.copyWith(
        error: message == 'error_no_match'
            ? 'Pausa detectada. Continue falando...'
            : 'Tempo limite atingido. Reconectando...',
      );
      return;
    }

    state = state.copyWith(error: message, isListening: false);

    // Erro "busy" exige parar tentativas automáticas de reinício
    if (message.toLowerCase().contains('busy')) {
      _active = false;
      _safeStop();
    }
  }

  void _onResult(dynamic result) {
    if (!_active) return;

    final text = result.recognizedWords.trim();
    if (text.isEmpty) return;

    state = state.copyWith(liveText: text);

    final items = VoiceParser.parseAll(
      text,
      listId: _listId,
      excludeLastWord: !result.finalResult,
    );

    for (final item in items) {
      final key = item.name.toLowerCase();
      if (_addedKeys.contains(key)) continue;

      _addedKeys.add(key);
      ref.read(listItemsProvider(_listId).notifier).addItem(item);
      state = state.copyWith(addedNames: [...state.addedNames, item.name]);
    }
  }

  void _onStatus(String status) {
    if (!_active || !state.isListening) return;

    if (status == 'done' || status == 'notListening') {
      // Reinicia apenas se o usuário ainda quer ouvir e não há outra sessão em andamento
      // Tempo de espera aumentado para garantir liberação nativa antes de reconectar
      Future<void>.delayed(const Duration(milliseconds: 500), () async {
        if (_active && state.isListening && !_listenInProgress) {
          await _listen();
        }
      });
    }
  }

  Future<void> stop() async {
    _active = false;
    await _safeStop();
    state = state.copyWith(isListening: false);
  }

  void reset() => state = const VoiceUiState();
}
