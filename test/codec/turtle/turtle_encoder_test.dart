import 'package:test/test.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:intl/intl.dart';

void main() {
  group('TurtleEncoder', () {
    test('Basic grouping by subject and predicate', () {
      final s = Iri('http://example.org/s');
      final p1 = Iri('http://example.org/p1');
      final p2 = Iri('http://example.org/p2');
      final o1 = Iri('http://example.org/o1');
      final o2 = Iri('http://example.org/o2');
      final o3 = Iri('http://example.org/o3');

      final triples = [
        Triple(subject: s, predicate: p1, object: o1),
        Triple(subject: s, predicate: p1, object: o2),
        Triple(subject: s, predicate: p2, object: o3),
      ];

      final output = const TurtleEncoder().convert(triples);

      expect(output, contains('<http://example.org/s>'));
      expect(output, contains('<http://example.org/p1> <http://example.org/o1> ,'));
      expect(output, contains('    <http://example.org/o2> ;'));
      expect(output, contains('<http://example.org/p2> <http://example.org/o3> .'));
    });

    test('RDF 1.2 Triple Terms', () {
      final s = Iri('http://example.org/s');
      final p = Iri('http://example.org/p');
      final innerT = Triple(
        subject: Iri('http://example.org/sub'),
        predicate: Iri('http://example.org/pred'),
        object: Literal('obj'),
      );
      final o = TripleTerm(innerT);

      final triples = [Triple(subject: s, predicate: p, object: o)];
      final output = const TurtleEncoder().convert(triples);

      expect(output, contains('<< ( <http://example.org/sub> <http://example.org/pred> "obj" ) >>'));
    });

    test('Directional Literals', () {
      final s = Iri('http://example.org/s');
      final p = Iri('http://example.org/p');
      final o = Literal('hello', languageTag: 'en', baseDirection: TextDirection.LTR);

      final triples = [Triple(subject: s, predicate: p, object: o)];
      final output = const TurtleEncoder().convert(triples);

      expect(output, contains('"hello"@en--ltr'));
    });
    
    test('rdf:type shorthand "a"', () {
      final s = Iri('http://example.org/s');
      final p = Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#type');
      final o = Iri('http://example.org/Class');

      final triples = [Triple(subject: s, predicate: p, object: o)];
      final output = const TurtleEncoder().convert(triples);

      expect(output, contains('a <http://example.org/Class>'));
    });
  });
}