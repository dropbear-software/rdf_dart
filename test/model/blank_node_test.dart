import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Blank Nodes', () {
    test('Blank Nodes implement value equality semantics', () {
      final b1 = BlankNode('b1');
      final b2 = BlankNode('b1');
      expect(b1, equals(b2));
      expect(b1.hashCode, equals(b2.hashCode));
    });

    test('Automatically generate an identifier if one is not provided', () {
      final b1 = BlankNode();
      expect(b1.id, isNotNull);
      expect(b1.id, isNotEmpty);
      expect(b1.id.length, equals(32));
    });

    test('Throw ArgumentError for empty string identifier', () {
      // N-Triples grammar: BLANK_NODE_LABEL requires at least one char after _:
      expect(() => BlankNode(''), throwsFormatException);
    });

    test('Throw ArgumentError for invalid characters or format', () {
      // Spaces not allowed
      expect(() => BlankNode('with space'), throwsFormatException);
      // Dot at start
      expect(() => BlankNode('.start'), throwsFormatException);
      // Dot at end
      expect(() => BlankNode('end.'), throwsFormatException);
      // Invalid symbols (not in PN_CHARS)
      expect(() => BlankNode('wrong@symbol'), throwsFormatException);
    });

    test('Accept valid N-Triples identifiers', () {
      expect(BlankNode('b1').id, equals('b1'));
      expect(BlankNode('B_1-2.3').id, equals('B_1-2.3')); // Dots in middle ok
      expect(BlankNode('123').id, equals('123')); // Digits start ok
    });

    test('Is not considered grounded', () {
      final b1 = BlankNode('b1');
      expect(b1.isGround, isFalse);
    });
  });
}
