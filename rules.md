# RULES.MD — Diretrizes de Engenharia de Software para Composer 2.5-fast
## Projeto: Aplicação Flutter + SQLite

---

> **LEIA ESTE DOCUMENTO ANTES DE QUALQUER AÇÃO.**
> Este documento define o contrato de trabalho entre o assistente de IA e o projeto. Toda modificação, sugestão ou correção de código deve respeitar INTEGRALMENTE as diretrizes aqui descritas. Ignorar qualquer seção é considerado uma falha crítica de execução.

---

## 1. FILOSOFIA DE TRABALHO

### 1.1 Princípio da Compreensão Antes da Ação
- **NUNCA** modifique código sem antes ler e entender completamente o arquivo afetado.
- **SEMPRE** trace o fluxo de dados completo antes de propor qualquer alteração.
- Se houver dúvida sobre a intenção de um bloco de código, **pergunte** antes de assumir.
- Prefira **análise cirúrgica** a refatorações amplas e não solicitadas.

### 1.2 Princípio do Mínimo Impacto
- Corrija **apenas** o que foi solicitado.
- Não altere código funcional ao redor do problema.
- Cada mudança deve ter **justificativa explícita**.
- Toda linha removida deve ser justificada; toda linha adicionada deve ser necessária.

### 1.3 Princípio da Rastreabilidade
- Ao identificar um bug, descreva: **O que está errado → Por que está errado → Como corrigir**.
- Após qualquer correção, descreva exatamente o que foi alterado e por quê.
- Documente side effects potenciais de cada mudança.

---

## 2. PILARES DA ENGENHARIA DE SOFTWARE APLICADOS AO PROJETO

### 2.1 SOLID

| Princípio | Aplicação no Projeto |
|-----------|----------------------|
| **S** – Single Responsibility | Cada classe/widget tem uma única responsabilidade. `AudioRecorder` só grava. `ListRepository` só persiste. |
| **O** – Open/Closed | Use abstrações e interfaces para extensão sem modificação. |
| **L** – Liskov Substitution | Subclasses e implementações devem ser substituíveis sem quebrar o contrato. |
| **I** – Interface Segregation | Interfaces pequenas e específicas. Nunca force uma classe a implementar o que não usa. |
| **D** – Dependency Inversion | Dependa de abstrações, não de implementações concretas. Use injeção de dependência. |

### 2.2 DRY, KISS, YAGNI

- **DRY** (Don't Repeat Yourself): Se o mesmo código aparece em dois lugares, crie uma abstração.
- **KISS** (Keep It Simple, Stupid): A solução mais simples que funciona corretamente é a correta.
- **YAGNI** (You Aren't Gonna Need It): Não implemente funcionalidades "para o futuro" sem necessidade real hoje.

### 2.3 Separação de Camadas (Clean Architecture)

```
lib/
├── data/
│   ├── datasources/        # SQLite, APIs, Microfone (acesso bruto a dados)
│   ├── models/             # Modelos de dados com serialização/desserialização
│   └── repositories/       # Implementações concretas dos repositórios
├── domain/
│   ├── entities/           # Entidades de negócio puras (sem dependência de framework)
│   ├── repositories/       # Contratos (interfaces/abstract classes) dos repositórios
│   └── usecases/           # Regras de negócio isoladas
├── presentation/
│   ├── controllers/        # Estado e lógica de apresentação (Provider/Bloc/Riverpod)
│   ├── pages/              # Telas completas
│   └── widgets/            # Componentes reutilizáveis
└── core/
    ├── errors/             # Classes de exceção e falha tipadas
    ├── constants/          # Constantes do app
    └── utils/              # Utilitários genéricos
```

**REGRA DE OURO:** Camadas internas (`domain`) **nunca** importam camadas externas (`data`, `presentation`). O fluxo de dependência é sempre de fora para dentro.

---

## 3. REGRAS ESPECÍFICAS: SQLITE E PERSISTÊNCIA DE LISTAS

### 3.1 Problemas Conhecidos a Evitar

#### ❌ ANTI-PADRÃO: Abrir conexão sem fechar
```dart
// ERRADO
final db = await openDatabase('app.db');
await db.insert('items', data);
// Conexão nunca fechada = vazamento de recurso
```

#### ✅ PADRÃO CORRETO: Singleton com gerenciamento de ciclo de vida
```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
```

### 3.2 Regras de Schema e Migrations

- **SEMPRE** defina `version` no `openDatabase`.
- **SEMPRE** implemente `onUpgrade` com lógica de migração versionada.
- **NUNCA** use `DROP TABLE` em produção sem migrar os dados primeiro.
- Toda tabela deve ter uma coluna `id INTEGER PRIMARY KEY AUTOINCREMENT`.
- Colunas de data devem ser armazenadas como `TEXT` no formato ISO 8601 (`DateTime.toIso8601String()`).

```dart
Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS lists (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      description TEXT,
      is_archived INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE IF NOT EXISTS list_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      list_id INTEGER NOT NULL,
      content TEXT NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0,
      position INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL,
      FOREIGN KEY (list_id) REFERENCES lists (id) ON DELETE CASCADE
    )
  ''');
}
```

### 3.3 Arquivamento de Listas — Lógica de Negócio Obrigatória

O arquivamento **NÃO É** exclusão. Seguir este contrato estritamente:

```dart
// Entidade
class ListEntity {
  final int? id;
  final String title;
  final bool isArchived;       // false = ativa, true = arquivada
  final DateTime createdAt;
  final DateTime updatedAt;
  // ...
}

// Repositório — Contrato (domain/repositories)
abstract class ListRepository {
  Future<List<ListEntity>> getActiveLists();
  Future<List<ListEntity>> getArchivedLists();
  Future<void> archiveList(int id);
  Future<void> unarchiveList(int id);
  Future<void> deleteListPermanently(int id);
}

// Implementação (data/repositories)
class ListRepositoryImpl implements ListRepository {
  final DatabaseHelper _db;

  @override
  Future<void> archiveList(int id) async {
    final db = await _db.database;
    await db.update(
      'lists',
      {
        'is_archived': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<ListEntity>> getActiveLists() async {
    final db = await _db.database;
    final maps = await db.query(
      'lists',
      where: 'is_archived = ?',
      whereArgs: [0],
      orderBy: 'updated_at DESC',
    );
    return maps.map(ListModel.fromMap).toList();
  }
}
```

### 3.4 Serialização de Modelos

```dart
class ListModel extends ListEntity {
  const ListModel({required super.id, required super.title, ...});

  factory ListModel.fromMap(Map<String, dynamic> map) {
    return ListModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      isArchived: (map['is_archived'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'is_archived': isArchived ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

### 3.5 Transações — Uso Obrigatório em Operações Compostas

```dart
// Para operações que afetam múltiplas tabelas, use transação
Future<void> archiveListWithItems(int listId) async {
  final db = await _database.database;
  await db.transaction((txn) async {
    await txn.update('lists', {'is_archived': 1}, where: 'id = ?', whereArgs: [listId]);
    await txn.update('list_items', {'is_archived': 1}, where: 'list_id = ?', whereArgs: [listId]);
  });
}
```

---

## 4. REGRAS ESPECÍFICAS: MICROFONE E ÁUDIO

### 4.1 Diagnóstico do Erro "Busy"

O erro `busy` no microfone em Flutter ocorre por **uma das causas a seguir**. Verifique nesta ordem:

1. **Recurso não liberado**: A instância de gravação anterior não foi corretamente `stop()`ada e `dispose()`ada.
2. **Permissão não verificada antes do acesso**: O app tenta acessar o microfone antes de ter permissão concedida.
3. **Múltiplas instâncias simultâneas**: Mais de um objeto `AudioRecorder` / `Recorder` instanciado ao mesmo tempo.
4. **Hot Reload em desenvolvimento**: O estado do recurso se corrompe durante hot reload; sempre teste reiniciando o app.
5. **Stream não cancelado**: Um `StreamSubscription` de áudio aberto que nunca foi `cancel()`ado.

### 4.2 Ciclo de Vida Obrigatório do Microfone

```dart
class AudioService {
  AudioRecorder? _recorder;
  StreamSubscription? _amplitudeSubscription;
  bool _isRecording = false;

  /// Inicializa uma nova sessão de gravação.
  /// SEMPRE chame dispose() antes de criar nova instância.
  Future<void> startRecording(String outputPath) async {
    // 1. Garantir que não há sessão ativa
    await _safeDispose();

    // 2. Verificar permissão ANTES de instanciar
    final hasPermission = await _checkMicrophonePermission();
    if (!hasPermission) {
      throw AudioPermissionException('Permissão de microfone negada.');
    }

    // 3. Criar nova instância
    _recorder = AudioRecorder();

    // 4. Iniciar gravação
    await _recorder!.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: outputPath,
    );

    _isRecording = true;
  }

  Future<String?> stopRecording() async {
    if (!_isRecording || _recorder == null) return null;

    final path = await _recorder!.stop();
    _isRecording = false;
    await _safeDispose();
    return path;
  }

  Future<void> _safeDispose() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;

    if (_recorder != null) {
      if (await _recorder!.isRecording()) {
        await _recorder!.stop();
      }
      await _recorder!.dispose();
      _recorder = null;
    }
    _isRecording = false;
  }

  Future<bool> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  /// Chame este método no dispose() do widget/controller
  Future<void> dispose() async {
    await _safeDispose();
  }
}
```

### 4.3 Integração com Widget — Ciclo de Vida do Flutter

```dart
class RecorderController extends ChangeNotifier {
  final AudioService _audioService;
  RecordingState _state = RecordingState.idle;

  RecorderController(this._audioService);

  RecordingState get state => _state;

  Future<void> toggleRecording() async {
    try {
      if (_state == RecordingState.idle) {
        await _audioService.startRecording(_generatePath());
        _state = RecordingState.recording;
      } else if (_state == RecordingState.recording) {
        final path = await _audioService.stopRecording();
        _state = RecordingState.idle;
        // Notificar com o caminho do arquivo gerado
        notifyListeners();
        return;
      }
      notifyListeners();
    } on AudioPermissionException catch (e) {
      _state = RecordingState.error;
      notifyListeners();
      // Propagar para a UI de forma controlada
      rethrow;
    } catch (e, stack) {
      _state = RecordingState.error;
      notifyListeners();
      debugPrint('Erro ao gravar: $e\n$stack');
      rethrow;
    }
  }

  String _generatePath() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${Directory.systemTemp.path}/audio_$timestamp.aac';
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}

enum RecordingState { idle, recording, processing, error }
```

### 4.4 Permissões — AndroidManifest e Info.plist

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Este app usa o microfone para gravar áudios nas listas.</string>
```

---

## 5. GERENCIAMENTO DE ESTADO

### 5.1 Regras Gerais

- **NUNCA** coloque lógica de negócio diretamente em widgets.
- Widgets são **apenas** responsáveis por renderizar e capturar eventos de UI.
- O estado deve ser **imutável** sempre que possível; crie novos objetos em vez de mutar os existentes.

### 5.2 Estrutura de Estado Recomendada

```dart
// Estado tipado e imutável
class ListState {
  final List<ListEntity> activeLists;
  final List<ListEntity> archivedLists;
  final bool isLoading;
  final String? errorMessage;

  const ListState({
    this.activeLists = const [],
    this.archivedLists = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  // copyWith para imutabilidade
  ListState copyWith({
    List<ListEntity>? activeLists,
    List<ListEntity>? archivedLists,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ListState(
      activeLists: activeLists ?? this.activeLists,
      archivedLists: archivedLists ?? this.archivedLists,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
```

---

## 6. TRATAMENTO DE ERROS

### 6.1 Hierarquia de Exceções do Projeto

```dart
// core/errors/exceptions.dart
abstract class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class AudioPermissionException extends AppException {
  const AudioPermissionException(super.message);
}

class AudioBusyException extends AppException {
  const AudioBusyException() : super('O microfone está em uso. Aguarde ou reinicie a gravação.');
}

class ListNotFoundException extends AppException {
  const ListNotFoundException(int id) : super('Lista com ID $id não encontrada.');
}
```

### 6.2 Resultado Tipado (Either Pattern)

```dart
// Para operações que podem falhar de forma controlada
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

// Uso:
Future<Result<List<ListEntity>>> getLists() async {
  try {
    final lists = await _repository.getActiveLists();
    return Success(lists);
  } on DatabaseException catch (e) {
    return Failure(e);
  }
}
```

### 6.3 Regras de Logging

- **NUNCA** use `print()` em produção. Use `debugPrint()` para debug ou um logger estruturado.
- Todo `catch` deve logar `exception` E `stackTrace`.
- Nunca swallow exceptions silenciosamente (`catch (_) {}`).

```dart
// ERRADO
} catch (e) {
  // silêncio total — nunca faça isso
}

// CORRETO
} catch (e, stack) {
  debugPrint('Erro em [NomeDoMetodo]: $e');
  debugPrintStack(stackTrace: stack);
  // Propague ou converta para AppException
}
```

---

## 7. PROCESSO DE ANÁLISE E CORREÇÃO DE BUGS

### 7.1 Protocolo de Investigação Obrigatório

Ao receber um relato de bug, siga SEMPRE esta sequência:

```
PASSO 1 — REPRODUÇÃO
  → Identifique as condições exatas que reproduzem o bug.
  → Documente: "O bug ocorre quando [ação] em [estado/condição]."

PASSO 2 — LOCALIZAÇÃO
  → Encontre o arquivo, classe e método responsável.
  → Trace o call stack até a origem real do problema.
  → Não confunda sintoma com causa.

PASSO 3 — HIPÓTESE
  → Formule a hipótese da causa raiz.
  → Valide a hipótese lendo o código, não assumindo.

PASSO 4 — SOLUÇÃO MÍNIMA
  → Proponha a menor mudança que corrige o problema.
  → Considere side effects na camada de dados, estado e UI.

PASSO 5 — VERIFICAÇÃO
  → Descreva como verificar que o bug foi corrigido.
  → Aponte casos de borda que devem ser testados.
```

### 7.2 Checklist de Code Review

Antes de propor qualquer código, verifique:

- [ ] O código compila sem erros e sem warnings?
- [ ] Todos os recursos (DB connection, Stream, Recorder) têm `dispose()` garantido?
- [ ] Toda operação assíncrona tem tratamento de erro?
- [ ] O estado nunca é mutado diretamente (apenas via `copyWith` ou setState explícito)?
- [ ] Permissões de microfone são verificadas antes do acesso?
- [ ] Não há múltiplas instâncias do `AudioRecorder` ativas?
- [ ] Queries SQLite usam `whereArgs` (nunca interpolação de string — prevenção de SQL Injection)?
- [ ] Foreign keys estão habilitadas no SQLite? (`PRAGMA foreign_keys = ON`)?

---

## 8. BOAS PRÁTICAS DE CÓDIGO FLUTTER

### 8.1 Widgets

```dart
// PREFERIR StatelessWidget sempre que possível
// PREFERIR const constructors
const MyWidget({super.key});

// NUNCA fazer operações pesadas no build()
// ERRADO:
Widget build(BuildContext context) {
  final sorted = items.sort(...); // computação no build
  return ListView(...);
}

// CORRETO: computar no controller/state
```

### 8.2 Async/Await e BuildContext

```dart
// NUNCA use BuildContext após await sem verificar mounted
Future<void> saveAndNavigate() async {
  await _repository.save(item);

  if (!mounted) return; // OBRIGATÓRIO após qualquer await

  Navigator.of(context).pop();
}
```

### 8.3 Gestão de Recursos

- Todo `StreamSubscription` declarado deve ser `cancel()`ado no `dispose()`.
- Todo `TextEditingController` deve ser `dispose()`ado.
- Todo `AnimationController` deve ser `dispose()`ado.
- Todo `AudioRecorder` deve ser `dispose()`ado.
- Todo `DatabaseHelper` deve ser fechado quando o app encerra.

---

## 9. PADRÕES DE NOMENCLATURA

| Elemento | Convenção | Exemplo |
|----------|-----------|---------|
| Classes | PascalCase | `ListRepository`, `AudioService` |
| Variáveis e métodos | camelCase | `isRecording`, `archiveList()` |
| Constantes | camelCase com `k` ou SCREAMING_SNAKE | `kMaxAudioDuration`, `MAX_RETRIES` |
| Arquivos | snake_case | `list_repository.dart`, `audio_service.dart` |
| Diretórios | snake_case | `data/repositories/` |
| Tabelas SQLite | snake_case | `list_items`, `audio_records` |
| Colunas SQLite | snake_case | `is_archived`, `created_at` |

---

## 10. REGRAS DE COMUNICAÇÃO DO ASSISTENTE

### 10.1 Antes de Modificar Código

O assistente DEVE:
1. Informar **qual arquivo** será modificado.
2. Descrever **o que** será mudado e **por quê**.
3. Alertar sobre **possíveis impactos** em outros arquivos.

### 10.2 Ao Apresentar Código

- Sempre apresentar o arquivo **completo** quando a mudança afeta a estrutura geral.
- Para mudanças pontuais, indicar claramente as linhas substituídas com contexto suficiente.
- Nunca omitir imports necessários.
- Nunca apresentar código com `// TODO` sem explicar o que deve ser implementado.

### 10.3 Ao Identificar Problemas Adicionais

- Se durante a análise forem encontrados outros bugs, **liste-os separadamente** sem corrigi-los automaticamente.
- Priorize o que foi solicitado; informe os demais como "problemas identificados secundários".

### 10.4 Frases Proibidas

O assistente **nunca** deve dizer:
- ❌ "Isso deve funcionar agora" — sem justificativa técnica.
- ❌ "Tente isso e veja se funciona" — propõe código sem análise.
- ❌ "O erro pode ser X ou Y ou Z" — sem investigar a causa real.
- ❌ "Refatorei o código para ficar melhor" — sem ter sido solicitado.

---

## 11. HABILITANDO FOREIGN KEYS E CONFIGURAÇÃO INICIAL DO BANCO

```dart
Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'app_database.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: _onCreate,
    onUpgrade: _onUpgrade,
    onConfigure: (db) async {
      // OBRIGATÓRIO: habilitar foreign keys e WAL mode para performance
      await db.execute('PRAGMA foreign_keys = ON');
      await db.execute('PRAGMA journal_mode = WAL');
    },
  );
}
```

---

## 12. DEPENDÊNCIAS RECOMENDADAS PARA O PROJETO

```yaml
dependencies:
  # Banco de dados
  sqflite: ^2.3.0
  path: ^1.9.0

  # Áudio / Microfone
  record: ^5.1.0          # Preferir sobre flutter_sound para simplicidade
  permission_handler: ^11.3.0
  path_provider: ^2.1.2

  # Estado (escolha um)
  provider: ^6.1.2         # Simples, adequado para a maioria dos casos
  # flutter_bloc: ^8.1.5  # Para lógica mais complexa

dev_dependencies:
  flutter_lints: ^4.0.0
  # mocktail: ^1.0.0      # Para testes
```

---

## 13. ANÁLISE DE CÓDIGO — ROTEIRO DE LIMPEZA

Ao realizar limpeza de código, siga esta ordem:

1. **Dead Code**: Remova variáveis, métodos e imports não utilizados.
2. **Duplicações**: Identifique e consolide lógica repetida.
3. **Responsabilidades misturadas**: Separe lógica de negócio de lógica de UI.
4. **Magic numbers/strings**: Extraia para constantes nomeadas.
5. **Null Safety**: Garanta que o código usa null safety corretamente (sem `!` desnecessário).
6. **Async gaps**: Verifique todos os `await` sem verificação de `mounted`.
7. **Resource leaks**: Audite todos os `dispose()` e `cancel()`.
8. **Error swallowing**: Encontre e corrija todos os `catch` silenciosos.

---

*Este documento é vivo. Atualize-o sempre que novos padrões, bugs recorrentes ou decisões arquiteturais forem estabelecidos no projeto.*

**Versão:** 1.0.0 | **Última atualização:** Junho/2026
