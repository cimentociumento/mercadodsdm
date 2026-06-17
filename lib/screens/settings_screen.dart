import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
              ref.read(themeModeProvider.notifier).setMode(selection.first);
            },
          ),
          const Gap(24),
          Text('Armazenamento', style: Theme.of(context).textTheme.titleMedium),
          const Gap(8),
          const ListTile(
            leading: Icon(Icons.storage),
            title: Text('SQLite local'),
            subtitle: Text('Todos os dados ficam no seu aparelho'),
          ),
        ],
      ),
    );
  }
}
