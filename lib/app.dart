// =============================================================================
// ARQUIVO   : lib/app.dart
// CAMADA    : Presentation
// PROPÓSITO : MaterialApp + GoRouter + temas.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers/core_providers.dart';
import 'core/theme/app_theme.dart';

/// Widget raiz do SmartList.
class SmartListApp extends ConsumerWidget {
  const SmartListApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'SmartList',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
