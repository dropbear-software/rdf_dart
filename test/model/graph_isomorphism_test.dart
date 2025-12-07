import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/model/impl/in_memory_graph.dart';
import 'package:test/test.dart';

void main() {
  group('Graph Isomorphism', () {
    test('Empty graphs are isomorphic', () {
      final g1 = InMemoryGraph();
      final g2 = InMemoryGraph();
      expect(g1.isomorphic(g2), isTrue);
    });

    test('Identical ground graphs are isomorphic', () {
      final g1 = InMemoryGraph();
      g1.add(
        Triple(
          subject: Iri('http://s'),
          predicate: Iri('http://p'),
          object: Iri('http://o'),
        ),
      );

      final g2 = InMemoryGraph();
      g2.add(
        Triple(
          subject: Iri('http://s'),
          predicate: Iri('http://p'),
          object: Iri('http://o'),
        ),
      );

      expect(g1.isomorphic(g2), isTrue);
    });

    test('Different ground graphs are not isomorphic', () {
      final g1 = InMemoryGraph();
      g1.add(
        Triple(
          subject: Iri('http://s'),
          predicate: Iri('http://p'),
          object: Iri('http://o1'),
        ),
      );

      final g2 = InMemoryGraph();
      g2.add(
        Triple(
          subject: Iri('http://s'),
          predicate: Iri('http://p'),
          object: Iri('http://o2'),
        ),
      );

      expect(g1.isomorphic(g2), isFalse);
    });

    test('Simple blank node mapping', () {
      // s p _:b1
      final g1 = InMemoryGraph();
      g1.add(
        Triple(
          subject: Iri('http://s'),
          predicate: Iri('http://p'),
          object: BlankNode('b1'),
        ),
      );

      // s p _:b2
      final g2 = InMemoryGraph();
      g2.add(
        Triple(
          subject: Iri('http://s'),
          predicate: Iri('http://p'),
          object: BlankNode('b2'),
        ),
      );

      expect(g1.isomorphic(g2), isTrue);
    });

    test('Complex blank node structure', () {
      // _:a p _:b . _:b p _:c
      final g1 = InMemoryGraph();
      final a = BlankNode('a');
      final b = BlankNode('b');
      final c = BlankNode('c');
      final p = Iri('http://p');
      g1.add(Triple(subject: a, predicate: p, object: b));
      g1.add(Triple(subject: b, predicate: p, object: c));

      // _:x p _:y . _:y p _:z
      final g2 = InMemoryGraph();
      final x = BlankNode('x');
      final y = BlankNode('y');
      final z = BlankNode('z');
      g2.add(Triple(subject: x, predicate: p, object: y));
      g2.add(Triple(subject: y, predicate: p, object: z));

      expect(g1.isomorphic(g2), isTrue);
    });

    test('Non-isomorphic blank node structure', () {
      // _:a p _:b . _:b p _:c (Line)
      final g1 = InMemoryGraph();
      final a = BlankNode('a');
      final b = BlankNode('b');
      final c = BlankNode('c');
      final p = Iri('http://p');
      g1.add(Triple(subject: a, predicate: p, object: b));
      g1.add(Triple(subject: b, predicate: p, object: c));

      // _:x p _:y . _:y p _:x (Loop) & isolated z (wait, graphs must be same size)
      // Let's make them same size (2 triples) but different shape.
      // _:x p _:y . _:x p _:z (Fork)
      final g2 = InMemoryGraph();
      final x = BlankNode('x');
      final y = BlankNode('y');
      final z = BlankNode('z');
      g2.add(Triple(subject: x, predicate: p, object: y));
      g2.add(Triple(subject: x, predicate: p, object: z));

      expect(g1.isomorphic(g2), isFalse);
    });

    test('Same bnode reused in subject and object', () {
      // _:b1 p _:b1
      final g1 = InMemoryGraph();
      final b1 = BlankNode('b1');
      final p = Iri('http://p');
      g1.add(Triple(subject: b1, predicate: p, object: b1));

      // _:b2 p _:b2
      final g2 = InMemoryGraph();
      final b2 = BlankNode('b2');
      g2.add(Triple(subject: b2, predicate: p, object: b2));

      expect(g1.isomorphic(g2), isTrue);

      // _:b3 p _:b4
      final g3 = InMemoryGraph();
      final b3 = BlankNode('b3');
      final b4 = BlankNode('b4');
      g3.add(Triple(subject: b3, predicate: p, object: b4));

      expect(g1.isomorphic(g3), isFalse);
    });

    test('TripleTerm with recursion', () {
      // s p <<( _:b1 p o )>>
      final s = Iri('http://s');
      final p = Iri('http://p');
      final o = Iri('http://o');

      final g1 = InMemoryGraph();
      final b1 = BlankNode('b1');
      final tt1 = TripleTerm(Triple(subject: b1, predicate: p, object: o));
      g1.add(Triple(subject: s, predicate: p, object: tt1));

      final g2 = InMemoryGraph();
      final b2 = BlankNode('b2');
      final tt2 = TripleTerm(Triple(subject: b2, predicate: p, object: o));
      g2.add(Triple(subject: s, predicate: p, object: tt2));

      expect(g1.isomorphic(g2), isTrue);
    });

    test('TripleTerm structure mismatch', () {
      // s p <<( _:b1 p o )>>
      final s = Iri('http://s');
      final p = Iri('http://p');
      final o = Iri('http://o');

      final g1 = InMemoryGraph();
      final b1 = BlankNode('b1');
      final tt1 = TripleTerm(Triple(subject: b1, predicate: p, object: o));
      g1.add(Triple(subject: s, predicate: p, object: tt1));

      // s p <<( s p _:b2 )>> (different position for bnode)
      final g2 = InMemoryGraph();
      final b2 = BlankNode('b2');
      final tt2 = TripleTerm(Triple(subject: s, predicate: p, object: b2));
      g2.add(Triple(subject: s, predicate: p, object: tt2));

      expect(g1.isomorphic(g2), isFalse);
    });
  });
}
