import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RDF Terms', () {
    test('Iri', () {
      final node = Iri('http://example.org/foo');
      expect(node.toString(), 'http://example.org/foo');
      expect(node, equals(Iri('http://example.org/foo')));
      expect(node.isGround, isTrue);
    });

    test('BlankNode', () {
      final node1 = BlankNode('b1');
      final node2 = BlankNode('b1');
      final node3 = BlankNode('b2');
      expect(node1.id, 'b1');
      expect(node1.toString(), '_:b1');
      expect(node1, equals(node2));
      expect(node1, isNot(equals(node3)));
      expect(node1.isGround, isFalse);
    });

    test('Literal', () {
      final stringType = Iri('http://www.w3.org/2001/XMLSchema#string');
      final lit = Literal('foo', datatypeIri: stringType);
      expect(lit.lexicalForm, 'foo');
      expect(lit.datatypeIri, stringType);
      expect(
        lit.toString(),
        '"foo"^^<http://www.w3.org/2001/XMLSchema#string>',
      );
      expect(lit.isGround, isTrue);
    });

    test('Literal with language', () {
      final langString = Iri(
        'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
      );
      final lit = Literal('foo', datatypeIri: langString, languageTag: 'en');
      expect(lit.lexicalForm, 'foo');
      expect(lit.languageTag, 'en');
      expect(lit.toString(), '"foo"@en');
    });
  });

  group('Triples and Quads', () {
    final s = Iri('http://example.org/s');
    final p = Iri('http://example.org/p');
    final o = Iri('http://example.org/o');
    final g = Iri('http://example.org/g');

    test('Quad default graph', () {
      final triple = Triple(subject: s, predicate: p, object: o);
      final quad = Quad(triple);
      expect(quad.graphName, isNull);
      expect(quad.toString(), triple.toString());
    });

    test('isGround', () {
      final s = Iri('http://example.org/s');
      final p = Iri('http://example.org/p');
      final o = Iri('http://example.org/o');
      final b = BlankNode('b1');

      final groundTriple = Triple(subject: s, predicate: p, object: o);
      expect(groundTriple.isGround, isTrue);

      final ungroundTriple = Triple(subject: b, predicate: p, object: o);
      expect(ungroundTriple.isGround, isFalse);

      final groundTT = TripleTerm(groundTriple);
      expect(groundTT.isGround, isTrue);

      final ungroundTT = TripleTerm(ungroundTriple);
      expect(ungroundTT.isGround, isFalse);

      // Recursive check
      final recursiveTriple = Triple(
        subject: s,
        predicate: p,
        object: groundTT,
      );
      expect(recursiveTriple.isGround, isTrue);

      final recursiveUngroundTriple = Triple(
        subject: s,
        predicate: p,
        object: ungroundTT,
      );
      expect(recursiveUngroundTriple.isGround, isFalse);
    });
  });
}
