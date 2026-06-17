import 'package:go_router/go_router.dart';

import '../screens/archived_screen.dart';
import '../screens/home_screen.dart';
import '../screens/list_detail_screen.dart';
import '../screens/settings_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const listDetail = 'listDetail';
  static const settings = 'settings';
  static const archived = 'archived';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        name: Routes.home,
        builder: (_, __) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'list/:listId',
            name: Routes.listDetail,
            builder: (_, state) {
              final listId = int.parse(state.pathParameters['listId']!);
              return ListDetailScreen(listId: listId);
            },
          ),
          GoRoute(
            path: 'settings',
            name: Routes.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'archived',
            name: Routes.archived,
            builder: (_, __) => const ArchivedScreen(),
          ),
        ],
      ),
    ],
  );
}
