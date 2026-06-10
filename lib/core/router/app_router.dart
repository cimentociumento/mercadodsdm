// =============================================================================
// ARQUIVO   : lib/core/router/app_router.dart
// CAMADA    : Core
// PROPÓSITO : Rotas go_router centralizadas.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:go_router/go_router.dart';

import '../../features/shopping_list/presentation/screens/archived_screen.dart';
import '../../features/shopping_list/presentation/screens/home_screen.dart';
import '../../features/shopping_list/presentation/screens/list_detail_screen.dart';
import '../../features/shopping_list/presentation/screens/settings_screen.dart';
import '../constants/route_names.dart';

/// Factory do GoRouter — facilita testes e injeção via Riverpod.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: RouteNames.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.home,
        builder: (ctx, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'list/:listId',
            name: RouteNames.listDetail,
            builder: (ctx, state) {
              final int listId = int.parse(state.pathParameters['listId']!);
              return ListDetailScreen(listId: listId);
            },
          ),
          GoRoute(
            path: 'settings',
            name: RouteNames.settings,
            builder: (ctx, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'archived',
            name: RouteNames.archived,
            builder: (ctx, state) => const ArchivedScreen(),
          ),
        ],
      ),
    ],
  );
}
