// =============================================================================
// ARQUIVO   : lib/core/providers/core_providers.dart
// CAMADA    : Core
// PROPÓSITO : Providers globais (database, repositório, tema, permissões).
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/shopping_list/data/repositories/shopping_repository_impl.dart';
import '../../features/shopping_list/domain/repositories/i_shopping_repository.dart';
import '../database/shopping_database.dart';
import '../router/app_router.dart';

part 'core_providers.g.dart';

/// Instância singleton do banco SQLite.
@riverpod
ShoppingDatabase database(DatabaseRef ref) {
  return ShoppingDatabase();
}

/// Implementação concreta do repositório de compras.
@riverpod
IShoppingRepository shoppingRepository(ShoppingRepositoryRef ref) {
  return ShoppingRepositoryImpl(ref.watch(databaseProvider));
}

/// Status da permissão de microfone.
@riverpod
Future<PermissionStatus> permission(PermissionRef ref) async {
  return Permission.microphone.status;
}

/// Modo de tema (claro / escuro / sistema).
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}

/// Router declarativo do app.
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return createAppRouter();
}
