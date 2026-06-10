// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shoppingListNotifierHash() =>
    r'3d51eb322347b12ba1499a8af5eaccc3aa2ef9dc';

/// Gerencia CRUD de listas de compras via AsyncNotifier.
///
/// Copied from [ShoppingListNotifier].
@ProviderFor(ShoppingListNotifier)
final shoppingListNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ShoppingListNotifier, List<ShoppingList>>.internal(
  ShoppingListNotifier.new,
  name: r'shoppingListNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shoppingListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShoppingListNotifier = AutoDisposeAsyncNotifier<List<ShoppingList>>;
String _$archivedListsNotifierHash() =>
    r'b4b4580621846cf59f561e8416e1d9e253f38d57';

/// Listas arquivadas — provider separado para a tela ArchivedScreen.
///
/// Copied from [ArchivedListsNotifier].
@ProviderFor(ArchivedListsNotifier)
final archivedListsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ArchivedListsNotifier, List<ShoppingList>>.internal(
  ArchivedListsNotifier.new,
  name: r'archivedListsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivedListsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ArchivedListsNotifier = AutoDisposeAsyncNotifier<List<ShoppingList>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
