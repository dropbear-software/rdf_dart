import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RDF Terms', () {
    test('NamedNode', () {
      final node = NamedNode('http://example.org/foo');
      // No .value getter on Term or NamedNode anymore (for string val)
      // Use .iri.toString() or .toString()
      expect(node.iri.toString(), 'http://example.org/foo');
      expect(node.toString(), '<http://example.org/foo>');
      expect(node, equals(NamedNode('http://example.org/foo')));
    });

    test('BlankNode', () {
      final node1 = BlankNode('b1');
      final node2 = BlankNode('b1');
      final node3 = BlankNode('b2');
      expect(node1.id, 'b1');
      expect(node1.toString(), '_:b1');
      expect(node1, equals(node2));
      expect(node1, isNot(equals(node3)));
    });

    test('Literal', () {
      final stringType = NamedNode('http://www.w3.org/2001/XMLSchema#string');
      final lit = Literal('foo', datatype: stringType);
      expect(lit.lexicalForm, 'foo');
      expect(lit.datatype, stringType);
      expect(
        lit.toString(),
        '"foo"^^<http://www.w3.org/2001/XMLSchema#string>',
      );
    });

    test('Literal with language', () {
      final langString = NamedNode(
        'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
      );
      final lit = Literal('foo', datatype: langString, language: 'en');
      expect(lit.lexicalForm, 'foo');
      expect(lit.language, 'en');
      expect(lit.toString(), '"foo"@en');
    });
  });

  group('Triples and Quads', () {
    final s = NamedNode('http://example.org/s');
    final p = NamedNode('http://example.org/p');
    final o = NamedNode('http://example.org/o');
    final g = NamedNode('http://example.org/g');

    test('Triple', () {
      final triple = Triple(subject: s, predicate: p, object: o);
      expect(triple.subject, s);
      expect(triple.predicate, p);
      expect(triple.object, o);
      expect(
        triple.toString(),
        '<http://example.org/s> <http://example.org/p> <http://example.org/o> .',
      );
    });

    test('TripleTerm', () {
      final triple = Triple(subject: s, predicate: p, object: o);
      final tt = TripleTerm(triple);
      // TripleTerm is an Object, so it can be used in a triple
      final nestedTriple = Triple(subject: s, predicate: p, object: tt);
      expect(nestedTriple.object, tt);
      expect(
        tt.toString(),
        '<<( <http://example.org/s> <http://example.org/p> <http://example.org/o> . )>>',
      );
    });

    test('Quad', () {
      final triple = Triple(subject: s, predicate: p, object: o);
      final quad = Quad(triple, g);
      expect(quad.subject, s);
      expect(quad.graphName, g);
      expect(
        quad.toString(),
        '<http://example.org/s> <http://example.org/p> <http://example.org/o> <http://example.org/g> .',
      );
    });

    test('Quad default graph', () {
      final triple = Triple(subject: s, predicate: p, object: o);
      final quad = Quad(triple);
      expect(quad.graphName, isNull);
      expect(quad.toString(), triple.toString());
    });
  });
}
