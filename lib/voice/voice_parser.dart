import '../models/shopping_item.dart';

class VoiceParser {
  static const _unitAliases = {
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
  };

  static final _qtyPattern = RegExp(
    r'^(\d+(?:[.,]\d+)?)?\s*([a-záéíóúãõâêîôûç]+)?\s+(?:de\s+)?(.+)$',
    caseSensitive: false,
    unicode: true,
  );

  /// Extrai vários itens de uma frase falada.
  /// Ex.: "leite, arroz e feijão" ou "leite arroz feijão"
  static List<ShoppingItem> parseAll(
    String rawText, {
    required int listId,
    bool excludeLastWord = false,
  }) {
    final cleaned = rawText.trim();
    if (cleaned.isEmpty) return [];

    List<String> segments;
    if (cleaned.contains(',') ||
        RegExp(r'\s+e\s+', caseSensitive: false).hasMatch(cleaned)) {
      segments = cleaned.split(RegExp(r'\s*,\s*|\s+e\s+', caseSensitive: false));
    } else if (RegExp(r'^\d').hasMatch(cleaned)) {
      segments = [cleaned];
    } else {
      segments = cleaned.split(RegExp(r'\s+'));
    }

    if (excludeLastWord && segments.length > 1) {
      segments = segments.sublist(0, segments.length - 1);
    } else if (excludeLastWord && segments.length == 1) {
      return [];
    }

    final items = <ShoppingItem>[];
    for (final segment in segments) {
      final item = parse(segment.trim(), listId: listId);
      if (item != null) items.add(item);
    }
    return items;
  }

  static ShoppingItem? parse(String rawText, {required int listId}) {
    final cleaned = rawText.trim();
    if (cleaned.length < 2) return null;

    final lower = cleaned.toLowerCase();
    final match = _qtyPattern.firstMatch(lower);

    if (match == null) {
      return ShoppingItem(
        listId: listId,
        name: cleaned,
        addedByVoice: true,
        createdAt: DateTime.now(),
      );
    }

    final rawQty = match.group(1);
    final rawUnit = match.group(2);
    final rawName = match.group(3);

    final qty = rawQty != null
        ? double.tryParse(rawQty.replaceAll(',', '.')) ?? 1.0
        : 1.0;
    final unit =
        rawUnit != null ? _unitAliases[rawUnit.toLowerCase()] : null;

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
