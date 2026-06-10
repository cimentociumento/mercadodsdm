// =============================================================================
// ARQUIVO   : lib/core/theme/app_theme.dart
// CAMADA    : Core
// PROPÓSITO : Temas claro e escuro do SmartList.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de cores alinhados ao pré-projeto (slate + indigo).
abstract final class ColorTokens {
  static const Color slate900 = Color(0xFF0F172A);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color amber500 = Color(0xFFF59E0B);
}

/// Configuração de tema Material 3 para o app.
abstract final class AppTheme {
  static ThemeData light() {
    // ColorScheme.fromSeed gera paleta coerente a partir da cor primária
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.indigo500,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ColorTokens.indigo500,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.indigo500,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ColorTokens.indigo500,
        foregroundColor: Colors.white,
      ),
    );
  }
}
