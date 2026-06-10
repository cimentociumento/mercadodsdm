// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'3548b050db221f21af7bd4a2f721e934e82ca4b0';

/// Instância singleton do banco SQLite.
///
/// Copied from [database].
@ProviderFor(database)
final databaseProvider = AutoDisposeProvider<ShoppingDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DatabaseRef = AutoDisposeProviderRef<ShoppingDatabase>;
String _$shoppingRepositoryHash() =>
    r'332726e49bf9cc6d4ef806b13c6b71dce275f1b8';

/// Implementação concreta do repositório de compras.
///
/// Copied from [shoppingRepository].
@ProviderFor(shoppingRepository)
final shoppingRepositoryProvider =
    AutoDisposeProvider<IShoppingRepository>.internal(
  shoppingRepository,
  name: r'shoppingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shoppingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ShoppingRepositoryRef = AutoDisposeProviderRef<IShoppingRepository>;
String _$permissionHash() => r'521ca3c3a2be66e64cf713918c3e0f9888106bdf';

/// Status da permissão de microfone.
///
/// Copied from [permission].
@ProviderFor(permission)
final permissionProvider = AutoDisposeFutureProvider<PermissionStatus>.internal(
  permission,
  name: r'permissionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$permissionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PermissionRef = AutoDisposeFutureProviderRef<PermissionStatus>;
String _$appRouterHash() => r'4d5dceb9eb529b80f5485febb2fcbf672eda5a28';

/// Router declarativo do app.
///
/// Copied from [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = AutoDisposeProvider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppRouterRef = AutoDisposeProviderRef<GoRouter>;
String _$themeModeNotifierHash() => r'2c9e3987c2ec07cbbd408bb4a652720ae512248a';

/// Modo de tema (claro / escuro / sistema).
///
/// Copied from [ThemeModeNotifier].
@ProviderFor(ThemeModeNotifier)
final themeModeNotifierProvider =
    AutoDisposeNotifierProvider<ThemeModeNotifier, ThemeMode>.internal(
  ThemeModeNotifier.new,
  name: r'themeModeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeModeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ThemeModeNotifier = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
