// =============================================================================
// ARQUIVO   : lib/core/database/database_initializer.dart
// CAMADA    : Core
// PROPÓSITO : Inicializa sqflite conforme a plataforma (mobile vs desktop).
// VERSÃO    : 0.1.0
// =============================================================================

import 'database_initializer_stub.dart'
    if (dart.library.io) 'database_initializer_io.dart' as impl;

/// Deve ser chamado em main() antes de qualquer acesso ao SQLite.
Future<void> initializeDatabase() => impl.initializeDatabase();
