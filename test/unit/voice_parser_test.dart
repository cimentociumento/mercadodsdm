import 'package:flutter_test/flutter_test.dart';
import 'package:smartlist/voice/voice_parser.dart';

void main() {
  group('VoiceParser', () {
    test('parse "2 quilos de arroz"', () {
      final item = VoiceParser.parse('2 quilos de arroz', listId: 1);

      expect(item, isNotNull);
      expect(item!.name, 'arroz');
      expect(item.quantity, 2.0);
      expect(item.unit, 'kg');
      expect(item.addedByVoice, isTrue);
    });

    test('parseAll com vírgulas', () {
      final items = VoiceParser.parseAll('leite, arroz e feijão', listId: 1);

      expect(items.length, 3);
      expect(items.map((i) => i.name), ['leite', 'arroz', 'feijão']);
    });

    test('parseAll com palavras separadas', () {
      final items = VoiceParser.parseAll('leite arroz feijão', listId: 1);

      expect(items.length, 3);
    });

    test('parse "ovos" como item simples', () {
      final item = VoiceParser.parse('ovos', listId: 1);

      expect(item, isNotNull);
      expect(item!.name, 'ovos');
      expect(item.quantity, 1.0);
      expect(item.unit, isNull);
    });
  });
}
