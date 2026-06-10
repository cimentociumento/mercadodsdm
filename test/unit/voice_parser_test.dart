import 'package:flutter_test/flutter_test.dart';
import 'package:smartlist/features/voice/domain/voice_parser.dart';

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

    test('parse "3 litros de leite"', () {
      final item = VoiceParser.parse('3 litros de leite', listId: 1);

      expect(item, isNotNull);
      expect(item!.name, 'leite');
      expect(item.quantity, 3.0);
      expect(item.unit, 'L');
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
