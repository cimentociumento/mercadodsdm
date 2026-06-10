// =============================================================================
// ARQUIVO   : lib/features/shopping_list/presentation/screens/settings_screen.dart
// CAMADA    : Presentation
// PROPÓSITO : Configurações de tema e preferências.
// VERSÃO    : 0.1.0
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/providers/core_providers.dart';

/// Tela de configurações com themeProvider.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Aparência', style: Theme.of(context).textTheme.titleMedium),
          const Gap(8),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Escuro')),
              ButtonSegment(value: ThemeMode.system, label: Text('Sistema')),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) {
              ref
                  .read(themeModeNotifierProvider.notifier)
                  .setMode(selection.first);
            },
          ),
          const Gap(24),
          Text('Voz', style: Theme.of(context).textTheme.titleMedium),
          const Gap(8),
          const ListTile(
            leading: Icon(Icons.record_voice_over),
            title: Text('Idioma primário'),
            subtitle: Text('pt-BR (fallback: en-US)'),
          ),
        ],
      ),
    );
  }
}
