// =============================================================================
// ARQUIVO   : lib/main.dart
// CAMADA    : Entry point
// PROPÓSITO : Inicialização do app com ProviderScope.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/database_initializer.dart';

Future<void> main() async {
  // Bindings obrigatórios antes de sqflite e permission_handler
  WidgetsFlutterBinding.ensureInitialized();

  // Desktop (Windows/Linux/macOS) exige databaseFactoryFfi antes do openDatabase
  await initializeDatabase();

  runApp(const ProviderScope(child: SmartListApp()));
}
