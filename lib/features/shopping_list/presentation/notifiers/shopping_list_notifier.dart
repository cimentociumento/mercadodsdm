// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/notifiers/shopping_list_notifier.dart
// CAMADA    : Presentation
// PROPÓSITO : Estado assíncrono de todas as listas ativas.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/shopping_list.dart';

part 'shopping_list_notifier.g.dart';

/// Gerencia CRUD de listas de compras via AsyncNotifier.
@riverpod
class ShoppingListNotifier extends _$ShoppingListNotifier {
  @override
  Future<List<ShoppingList>> build() async {
    final repo = ref.read(shoppingRepositoryProvider);
    return repo.getAllLists(archived: false);
  }

  /// Adiciona nova lista e recarrega do banco.
  Future<void> addList(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shoppingRepositoryProvider);
      await repo.createList(name);
      return repo.getAllLists(archived: false);
    });
  }

  /// Remove lista (CASCADE apaga itens no SQLite).
  Future<void> removeList(int listId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shoppingRepositoryProvider);
      await repo.deleteList(listId);
      return repo.getAllLists(archived: false);
    });
  }

  /// Arquiva lista sem deletar.
  Future<void> archiveList(int listId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shoppingRepositoryProvider);
      await repo.archiveList(listId, archived: true);
      return repo.getAllLists(archived: false);
    });
  }
}

/// Listas arquivadas — provider separado para a tela ArchivedScreen.
@riverpod
class ArchivedListsNotifier extends _$ArchivedListsNotifier {
  @override
  Future<List<ShoppingList>> build() async {
    final repo = ref.read(shoppingRepositoryProvider);
    return repo.getAllLists(archived: true);
  }

  Future<void> restoreList(int listId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shoppingRepositoryProvider);
      await repo.archiveList(listId, archived: false);
      return repo.getAllLists(archived: true);
    });
  }
}
