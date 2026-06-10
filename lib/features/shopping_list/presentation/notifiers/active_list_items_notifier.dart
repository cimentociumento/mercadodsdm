// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/notifiers/active_list_items_notifier.dart
// CAMADA    : Presentation
// PROPÓSITO : Itens da lista atualmente aberta na ListDetailScreen.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/shopping_item.dart';

part 'active_list_items_notifier.g.dart';

/// Família de providers indexada por listId.
@riverpod
class ActiveListItemsNotifier extends _$ActiveListItemsNotifier {
  @override
  Future<List<ShoppingItem>> build(int listId) async {
    final repo = ref.read(shoppingRepositoryProvider);
    return repo.getItemsByListId(listId);
  }

  Future<void> addItem(ShoppingItem item) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shoppingRepositoryProvider);
      await repo.addItem(item);
      return repo.getItemsByListId(listId);
    });
  }

  Future<void> toggleItem(ShoppingItem item) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shoppingRepositoryProvider);
      await repo.updateItem(item);
      return repo.getItemsByListId(listId);
    });
  }

  Future<void> removeItem(int itemId) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shoppingRepositoryProvider);
      await repo.removeItem(itemId);
      return repo.getItemsByListId(listId);
    });
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    state = await AsyncValue.guard(() async {
      final repo = ref.read(shoppingRepositoryProvider);
      await repo.reorderItems(listId, oldIndex, newIndex);
      return repo.getItemsByListId(listId);
    });
  }
}
