// =============================================================================
// ARQUIVO   : lib/features/voice/domain/voice_parser.dart
// CAMADA    : Domain
// PROPÓSITO : Converter texto livre em ShoppingItem estruturado.
// VERSÃO    : 0.1.0
// =============================================================================

import '../../shopping_list/domain/entities/shopping_item.dart';

/// Parser puro de domínio — sem dependências de Flutter.
class VoiceParser {
  // Mapa de aliases de unidades → unidade canônica
  static const Map<String, String> _unitAliases = {
    'quilo': 'kg',
    'quilos': 'kg',
    'kg': 'kg',
    'grama': 'g',
    'gramas': 'g',
    'g': 'g',
    'litro': 'L',
    'litros': 'L',
    'l': 'L',
    'unidade': 'un',
    'unidades': 'un',
    'un': 'un',
    'caixa': 'cx',
    'caixas': 'cx',
    'pacote': 'pct',
    'pacotes': 'pct',
  };

  // RegExp captura: (quantidade opcional)(unidade opcional)(nome do item)
  static final RegExp _pattern = RegExp(
    r'^(\d+(?:[.,]\d+)?)?\s*([a-záéíóúãõâêîôûç]+)?\s+(?:de\s+)?(.+)$',
    caseSensitive: false,
    unicode: true,
  );

  /// Retorna null se o texto não for interpretável como item de compra.
  static ShoppingItem? parse(String rawText, {required int listId}) {
    final String cleaned = rawText.trim().toLowerCase();
    if (cleaned.isEmpty) return null;

    final RegExpMatch? match = _pattern.firstMatch(cleaned);

    if (match == null) {
      return ShoppingItem(
        listId: listId,
        name: cleaned,
        addedByVoice: true,
        createdAt: DateTime.now(),
      );
    }

    final String? rawQty = match.group(1);
    final String? rawUnit = match.group(2);
    final String? rawName = match.group(3);

    final double qty = rawQty != null
        ? double.tryParse(rawQty.replaceAll(',', '.')) ?? 1.0
        : 1.0;

    final String? unit = rawUnit != null
        ? _unitAliases[rawUnit.toLowerCase()]
        : null;

    return ShoppingItem(
      listId: listId,
      name: rawName ?? cleaned,
      quantity: qty,
      unit: unit,
      addedByVoice: true,
      createdAt: DateTime.now(),
    );
  }
}
