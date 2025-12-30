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
      expect(
        output,
        contains('<http://example.org/p1> <http://example.org/o1> ,'),
      );
      expect(output, contains('    <http://example.org/o2> ;'));
      expect(
        output,
        contains('<http://example.org/p2> <http://example.org/o3> .'),
      );
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

      expect(
        output,
        contains(
          '<< ( <http://example.org/sub> <http://example.org/pred> "obj" ) >>',
        ),
      );
    });

    test('Directional Literals', () {
      final s = Iri('http://example.org/s');
      final p = Iri('http://example.org/p');
      final o = Literal(
        'hello',
        languageTag: 'en',
        baseDirection: TextDirection.LTR,
      );

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

    test('Prefix support', () {
      final s = Iri('http://example.org/s');

      final p = Iri('http://example.org/p');

      final o = Iri('http://example.org/o');

      final triples = [Triple(subject: s, predicate: p, object: o)];

      final encoder = TurtleEncoder(prefixes: {'ex': 'http://example.org/'});

      final output = encoder.convert(triples);

      expect(output, contains('PREFIX ex: <http://example.org/>'));

      expect(output, contains('ex:s\n    ex:p ex:o .'));
    });

    test('Base URI support', () {
      final s = Iri('http://example.org/s');

      final p = Iri('http://example.org/p');

      final o = Iri('http://example.org/o');

      final triples = [Triple(subject: s, predicate: p, object: o)];

      final encoder = TurtleEncoder(baseUri: 'http://example.org/');

      final output = encoder.convert(triples);

      expect(output, contains('BASE <http://example.org/>'));

      expect(output, contains('<s>\n    <p> <o> .'));
    });

    test('Blank Node inlining', () {
      final s = Iri('http://example.org/s');

      final p = Iri('http://example.org/p');

      final b = BlankNode('b1');

      final p2 = Iri('http://example.org/p2');

      final o2 = Literal('nested');

      final triples = [
        Triple(subject: s, predicate: p, object: b),

        Triple(subject: b, predicate: p2, object: o2),
      ];

      final output = const TurtleEncoder().convert(triples);

      expect(output, contains('<http://example.org/s>'));

      expect(output, contains('<http://example.org/p> ['));

      expect(output, contains('<http://example.org/p2> "nested"'));

      expect(output, isNot(contains('_:b1')));
    });

    test('Collections support', () {
      final s = Iri('http://example.org/s');

      final p = Iri('http://example.org/p');

      final b1 = BlankNode('b1');

      final b2 = BlankNode('b2');

      final rdfFirst = Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#first');

      final rdfRest = Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#rest');

      final rdfNil = Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#nil');

      final triples = [
        Triple(subject: s, predicate: p, object: b1),

        Triple(subject: b1, predicate: rdfFirst, object: Literal('item1')),

        Triple(subject: b1, predicate: rdfRest, object: b2),

        Triple(subject: b2, predicate: rdfFirst, object: Literal('item2')),

        Triple(subject: b2, predicate: rdfRest, object: rdfNil),
      ];

      final output = const TurtleEncoder().convert(triples);

      expect(output, contains('( "item1" "item2" )'));

      expect(output, isNot(contains('_:b1')));

      expect(output, isNot(contains('_:b2')));
    });

    test('RDF 1.2 Annotations', () {
      final s = Iri('http://example.org/s');

      final p = Iri('http://example.org/p');

      final o = Iri('http://example.org/o');

      final r = BlankNode('r1');

      final rdfReifies = Iri(
        'http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies',
      );

      final ap = Iri('http://example.org/ap');

      final ao = Literal('annotation');

      final triples = [
        Triple(subject: s, predicate: p, object: o),

        Triple(
          subject: r,
          predicate: rdfReifies,
          object: TripleTerm(Triple(subject: s, predicate: p, object: o)),
        ),

        Triple(subject: r, predicate: ap, object: ao),
      ];

      final output = const TurtleEncoder().convert(triples);

      expect(output, contains('<http://example.org/s>'));

      expect(
        output,
        contains('<http://example.org/p> <http://example.org/o> {|'),
      );

      expect(output, contains('<http://example.org/ap> "annotation" |}'));
    });
  });
}
