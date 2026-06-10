# SmartList

Lista de supermercado inteligente com reconhecimento de voz, persistência local (SQLite) e interface Flutter multiplataforma.

**Versão:** 0.1.0

## Como rodar

```bash
cd smartlist
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Widgets customizados (projeto)

Widgets criados especificamente para o SmartList, organizados por camada.

| Widget | Arquivo | Função |
|--------|---------|--------|
| `SmartListApp` | `lib/app.dart` | Widget raiz do app. Configura `MaterialApp.router`, temas claro/escuro e navegação via GoRouter. |
| `HomeScreen` | `lib/features/shopping_list/presentation/screens/home_screen.dart` | Tela principal. Exibe todas as listas ativas, permite criar nova lista e navegar para detalhes, arquivadas e configurações. |
| `ListDetailScreen` | `lib/features/shopping_list/presentation/screens/list_detail_screen.dart` | Tela de itens de uma lista. Mostra progresso de compras, busca em tempo real, adição manual/por voz e reordenação por drag. |
| `SettingsScreen` | `lib/features/shopping_list/presentation/screens/settings_screen.dart` | Tela de configurações. Permite alternar tema (claro, escuro, sistema) e exibe preferências de voz. |
| `ArchivedScreen` | `lib/features/shopping_list/presentation/screens/archived_screen.dart` | Tela de listas arquivadas. Permite restaurar listas previamente arquivadas. |
| `EmptyStateWidget` | `lib/features/shopping_list/presentation/widgets/empty_state.dart` | Placeholder visual quando não há dados (listas vazias, itens vazios, arquivadas vazias). |
| `ListCard` | `lib/features/shopping_list/presentation/widgets/list_card.dart` | Card clicável que representa uma `ShoppingList` na Home, com nome, data de criação e botão de arquivar. |
| `ItemTile` | `lib/features/shopping_list/presentation/widgets/item_tile.dart` | Tile de um item de compra. Marca como comprado, exibe quantidade/unidade, badge de voz e swipe para remover. |
| `AddItemSheet` | `lib/features/shopping_list/presentation/widgets/add_item_sheet.dart` | Bottom sheet para adicionar item manualmente (campo de texto) ou abrir entrada por voz. |
| `VoiceBottomSheetContent` | `lib/features/voice/presentation/widgets/voice_bottom_sheet.dart` | Conteúdo do painel de voz. Exibe status do STT, ícone animado do microfone e botões iniciar/parar escuta. |
| `MicAnimatedIcon` | `lib/features/voice/presentation/widgets/mic_animated_icon.dart` | Ícone de microfone com animação pulsante (scale) enquanto o app está ouvindo. |
| `ListProgressIndicator` | `lib/features/shopping_list/presentation/widgets/progress_indicator_widget.dart` | Barra de progresso animada indicando quantos itens já foram comprados em relação ao total. |
| `ListHeaderDelegate` | `lib/features/shopping_list/presentation/widgets/list_header_delegate.dart` | Delegate do `SliverPersistentHeader`. Cabeçalho colapsável da Home com título e subtítulo que desaparecem ao rolar. |

---

## Widgets do Flutter (Material)

Widgets nativos do Flutter utilizados no projeto, agrupados por função.

### Estrutura e navegação

| Widget | Onde é usado | Função |
|--------|--------------|--------|
| `MaterialApp.router` | `SmartListApp` | Shell do app com roteamento declarativo (GoRouter). |
| `Scaffold` | Todas as telas | Estrutura base de tela (body, AppBar, FAB). |
| `AppBar` | `HomeScreen`, `ListDetailScreen`, `SettingsScreen`, `ArchivedScreen` | Barra superior com título e ações. |
| `ProviderScope` | `main.dart` | Container Riverpod que injeta providers em toda a árvore de widgets. |

### Scroll e Slivers

| Widget | Onde é usado | Função |
|--------|--------------|--------|
| `CustomScrollView` | `HomeScreen` | Scroll unificado com múltiplos slivers (AppBar, header, lista). |
| `SliverAppBar` | `HomeScreen` | AppBar fixa (`pinned`) que permanece visível ao rolar. |
| `SliverPersistentHeader` | `HomeScreen` | Header expansível/colapsável controlado por `ListHeaderDelegate`. |
| `SliverList.builder` | `HomeScreen` | Lista lazy de cards de listas — só constrói itens visíveis. |
| `SliverFillRemaining` | `HomeScreen` | Preenche o espaço restante com `EmptyStateWidget` quando não há listas. |
| `SliverGap` | `HomeScreen` | Espaçamento inferior para não sobrepor o FAB. |
| `ListView` | `VoiceBottomSheetContent` | Lista scrollável dentro do bottom sheet de voz. |
| `ListView.separated` | `ArchivedScreen` | Lista de arquivadas com separador entre itens. |

### Listas e animações avançadas

| Widget | Onde é usado | Função |
|--------|--------------|--------|
| `AnimatedList` | `ListDetailScreen` | Anima inserção de novos itens com slide da direita para a esquerda. |
| `SlideTransition` | `ListDetailScreen` | Animação de entrada dos itens no `AnimatedList`. |
| `ReorderableListView.builder` | `ListDetailScreen` | Modo de reordenação — arrastar itens para mudar a ordem (persiste no SQLite). |
| `ValueListenableBuilder` | `ListDetailScreen` | Reage à query de busca em tempo real sem rebuildar a tela inteira. |
| `ValueNotifier` | `ListDetailScreen` | Estado local efêmero da busca (`_searchQuery`). |
| `GlobalKey<AnimatedListState>` | `ListDetailScreen` | Controla inserções animadas no `AnimatedList` externamente. |
| `TweenAnimationBuilder` | `ListProgressIndicator` | Anima suavemente a transição do valor de progresso (0% → N%). |
| `AnimatedSwitcher` | `VoiceBottomSheetContent` | Troca suave entre botões "Iniciar voz" e "Parar" com fade/scale. |
| `ScaleTransition` | `MicAnimatedIcon`, `VoiceBottomSheetContent` | Animação de escala do microfone pulsante e transição do botão de voz. |
| `AnimationController` | `MicAnimatedIcon` | Controla o loop da animação pulsante do ícone de microfone. |

### Performance

| Widget | Onde é usado | Função |
|--------|--------------|--------|
| `RepaintBoundary` | `VoiceBottomSheetContent` | Isola o repaint da animação do microfone, evitando redesenhar a tela inteira a cada frame. |

### Modais e bottom sheets

| Widget | Onde é usado | Função |
|--------|--------------|--------|
| `showModalBottomSheet` | `AddItemSheet`, `VoiceBottomSheetContent` | Abre painéis modais na parte inferior da tela. |
| `DraggableScrollableSheet` | `VoiceBottomSheetContent` | Painel de voz arrastável (25%–75% da tela) com snap em posições fixas. |
| `AlertDialog` | `HomeScreen` | Diálogo para criar nova lista de compras. |

### Entrada de dados e botões

| Widget | Onde é usado | Função |
|--------|--------------|--------|
| `TextField` | `HomeScreen`, `ListDetailScreen`, `AddItemSheet` | Campo de texto para criar lista, buscar item ou adicionar item manualmente. |
| `FloatingActionButton` | `HomeScreen`, `ListDetailScreen` | Botão principal de ação (+ criar lista, + adicionar item). |
| `FloatingActionButton.small` | `ListDetailScreen` | FAB secundário para abrir entrada por voz. |
| `FilledButton` / `FilledButton.icon` | `HomeScreen`, `AddItemSheet`, `VoiceBottomSheetContent` | Botões de ação primária (Criar, Adicionar, Iniciar/Parar voz). |
| `OutlinedButton.icon` | `AddItemSheet` | Botão secundário para abrir entrada por voz. |
| `TextButton` | `HomeScreen`, `ArchivedScreen` | Ações secundárias (Cancelar, Restaurar). |
| `ElevatedButton` | `HomeScreen` | Botão "Tentar novamente" em estado de erro. |
| `IconButton` | `HomeScreen`, `ListDetailScreen`, `ListCard` | Ações compactas (arquivar, configurações, reordenar). |
| `SegmentedButton` / `ButtonSegment` | `SettingsScreen` | Seletor de tema (Claro / Escuro / Sistema). |

### Exibição de conteúdo

| Widget | Onde é usado | Função |
|--------|--------------|--------|
| `Text` | Todas as telas | Exibição de títulos, subtítulos, labels e mensagens de status. |
| `Icon` | Todas as telas | Ícones visuais (add, mic, archive, settings, search, etc.). |
| `Card` | `ListCard` | Container visual para cada lista na Home. |
| `InkWell` | `ListCard` | Feedback de toque (ripple) ao clicar no card. |
| `CheckboxListTile` | `ItemTile` | Item com checkbox para marcar como comprado, com título tachado. |
| `ListTile` | `SettingsScreen`, `ArchivedScreen` | Linha padrão de lista com leading, title e trailing. |
| `LinearProgressIndicator` | `ListProgressIndicator` | Barra visual de progresso de itens comprados. |
| `CircularProgressIndicator` | `HomeScreen`, `ListDetailScreen`, `ArchivedScreen` | Indicador de carregamento assíncrono (loading). |
| `Tooltip` | `ItemTile` | Dica ao passar sobre o badge de item adicionado por voz. |
| `SnackBar` | `VoiceBottomSheetContent` | Feedback temporário após adicionar item por voz. |

### Layout e utilitários

| Widget | Onde é usado | Função |
|--------|--------------|--------|
| `Column` / `Row` | Várias telas | Organização vertical/horizontal de filhos. |
| `Center` | Várias telas | Centraliza conteúdo (loading, empty state, erros). |
| `Padding` | Várias telas | Espaçamento interno consistente. |
| `Expanded` | `ListCard`, `AddItemSheet` | Ocupa espaço flexível disponível em `Row`. |
| `Material` | `VoiceBottomSheetContent` | Superfície Material com bordas arredondadas no bottom sheet. |
| `Container` | `VoiceBottomSheetContent` | Handle visual (barra cinza) para arrastar o bottom sheet. |

---

## Widgets de pacotes externos

| Widget / Pacote | Onde é usado | Função |
|-----------------|--------------|--------|
| `Gap` (`gap`) | Várias telas | Substituto semântico de `SizedBox` para espaçamento entre widgets. |
| `Slidable` (`flutter_slidable`) | `ItemTile` | Habilita gesto de swipe horizontal no item. |
| `ActionPane` (`flutter_slidable`) | `ItemTile` | Painel de ações revelado ao deslizar o item. |
| `SlidableAction` (`flutter_slidable`) | `ItemTile` | Botão de ação "Remover" no swipe (fundo vermelho). |
| `BehindMotion` (`flutter_slidable`) | `ItemTile` | Animação do painel de ações aparecendo por trás do tile. |
| `ConsumerWidget` / `ConsumerStatefulWidget` (`flutter_riverpod`) | Telas e widgets | Conecta widgets ao estado reativo dos providers Riverpod. |

---

## Mapa widget → tela

| Tela | Widgets principais |
|------|-------------------|
| **Home** | `CustomScrollView`, `SliverAppBar`, `SliverPersistentHeader`, `SliverList.builder`, `ListCard`, `EmptyStateWidget`, `FloatingActionButton`, `AlertDialog` |
| **Detalhe da lista** | `AnimatedList`, `ReorderableListView.builder`, `ValueListenableBuilder`, `ListProgressIndicator`, `ItemTile`, `TextField`, `FloatingActionButton` |
| **Voz (modal)** | `DraggableScrollableSheet`, `RepaintBoundary`, `MicAnimatedIcon`, `AnimatedSwitcher`, `SnackBar` |
| **Adicionar item (modal)** | `TextField`, `OutlinedButton`, `FilledButton` |
| **Configurações** | `SegmentedButton`, `ListTile` |
| **Arquivadas** | `ListView.separated`, `ListTile`, `EmptyStateWidget` |
"# mercadodsdm" 
