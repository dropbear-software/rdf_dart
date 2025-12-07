import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/model/impl/in_memory_graph.dart';
import 'package:test/test.dart';

void main() {
  group('Graph Isomorphism', () {
    group('RDF 1.1', () {
      test('Empty graphs are isomorphic', () {
        final g1 = InMemoryGraph();
        final g2 = InMemoryGraph();
        expect(g1.isomorphic(g2), isTrue);
      });

      test('Ground graphs identity', () {
        final g = InMemoryGraph();
        g.add(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
        );
        expect(g.isomorphic(g), isTrue);
      });

      test('Permutation of triples does not affect isomorphism', () {
        final t1 = Triple(
          subject: Iri('s'),
          predicate: Iri('p'),
          object: Iri('o1'),
        );
        final t2 = Triple(
          subject: Iri('s'),
          predicate: Iri('p'),
          object: Iri('o2'),
        );

        final g1 = InMemoryGraph();
        g1.add(t1);
        g1.add(t2);

        final g2 = InMemoryGraph();
        g2.add(t2);
        g2.add(t1);

        expect(g1.isomorphic(g2), isTrue);
      });

      test('Blank Node Bijections', () {
        // g1: _:a -> p -> _:b
        final g1 = InMemoryGraph();
        g1.add(
          Triple(
            subject: BlankNode('a'),
            predicate: Iri('p'),
            object: BlankNode('b'),
          ),
        );

        // g2: _:x -> p -> _:y
        final g2 = InMemoryGraph();
        g2.add(
          Triple(
            subject: BlankNode('x'),
            predicate: Iri('p'),
            object: BlankNode('y'),
          ),
        );

        expect(g1.isomorphic(g2), isTrue);
      });

      test('Structure Mismatch', () {
        // g1: s -> p -> _:b1
        final g1 = InMemoryGraph();
        g1.add(
          Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: BlankNode('b1'),
          ),
        );

        // g2: _:b2 -> p -> o
        final g2 = InMemoryGraph();
        g2.add(
          Triple(
            subject: BlankNode('b2'),
            predicate: Iri('p'),
            object: Iri('o'),
          ),
        );

        expect(g1.isomorphic(g2), isFalse);
      });

      test('Complex Cycle', () {
        // g1: _:a -> p -> _:b -> p -> _:a
        final g1 = InMemoryGraph();
        final a = BlankNode('a');
        final b = BlankNode('b');
        final p = Iri('p');
        g1.add(Triple(subject: a, predicate: p, object: b));
        g1.add(Triple(subject: b, predicate: p, object: a));

        // g2: _:x -> p -> _:y -> p -> _:x
        final g2 = InMemoryGraph();
        final x = BlankNode('x');
        final y = BlankNode('y');
        g2.add(Triple(subject: x, predicate: p, object: y));
        g2.add(Triple(subject: y, predicate: p, object: x));

        expect(g1.isomorphic(g2), isTrue);
      });
    });

    group('RDF 1.2', () {
      test('TripleTerm Recursion', () {
        // s -> p -> <<( _:b p o )>>
        final g1 = InMemoryGraph();
        final b1 = BlankNode('b1');
        final tt1 = TripleTerm(
          Triple(subject: b1, predicate: Iri('p'), object: Iri('o')),
        );
        g1.add(Triple(subject: Iri('s'), predicate: Iri('p'), object: tt1));

        // s -> p -> <<( _:b2 p o )>>
        final g2 = InMemoryGraph();
        final b2 = BlankNode('b2');
        final tt2 = TripleTerm(
          Triple(subject: b2, predicate: Iri('p'), object: Iri('o')),
        );
        g2.add(Triple(subject: Iri('s'), predicate: Iri('p'), object: tt2));

        expect(g1.isomorphic(g2), isTrue);
      });

      test('TripleTerm Recursion Mismatch', () {
        // s -> p -> <<( _:b1 p o )>>
        final g1 = InMemoryGraph();
        final b1 = BlankNode('b1');
        final tt1 = TripleTerm(
          Triple(subject: b1, predicate: Iri('p'), object: Iri('o')),
        );
        g1.add(Triple(subject: Iri('s'), predicate: Iri('p'), object: tt1));

        // s -> p -> <<( s p _:b2 )>>  (Object BNode instead of Subject BNode)
        final g2 = InMemoryGraph();
        final b2 = BlankNode('b2');
        final tt2 = TripleTerm(
          Triple(subject: Iri('s'), predicate: Iri('p'), object: b2),
        );
        g2.add(Triple(subject: Iri('s'), predicate: Iri('p'), object: tt2));

        expect(g1.isomorphic(g2), isFalse);
      });
    });
  });
}
