import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/graph.dart';
import 'package:rdf_dart/src/model/impl/in_memory_graph.dart';
import 'package:rdf_dart/src/model/iri.dart';
import 'package:rdf_dart/src/model/literal.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';
import 'package:test/test.dart';

void main() {
  group('Graph', () {
    late Graph graph;

    setUp(() {
      graph = InMemoryGraph();
    });

    group('RDF 1.1 Features', () {
      group('Modification', () {
        test('Starts empty', () {
          expect(graph.length, 0);
          expect(graph.triples, isEmpty);
        });

        test('Add triple', () {
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: Iri('o'),
          );
          expect(graph.add(t), isTrue);
          expect(graph.length, 1);
          expect(graph.contains(t), isTrue);
        });

        test('Add duplicate triple', () {
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: Iri('o'),
          );
          graph.add(t);
          expect(graph.add(t), isFalse);
          expect(graph.length, 1);
        });

        test('Remove triple', () {
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: Iri('o'),
          );
          graph.add(t);
          expect(graph.remove(t), isTrue);
          expect(graph.length, 0);
          expect(graph.contains(t), isFalse);
        });

        test('Remove non-existent triple', () {
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: Iri('o'),
          );
          expect(graph.remove(t), isFalse);
        });

        test('Remove matches', () {
          final s = Iri('s');
          final p = Iri('p');
          graph.add(Triple(subject: s, predicate: p, object: Iri('o1')));
          graph.add(Triple(subject: s, predicate: p, object: Iri('o2')));
          graph.add(
            Triple(subject: Iri('s2'), predicate: p, object: Iri('o2')),
          );

          graph.removeMatches(s, null, null);
          expect(graph.length, 1);
          expect(
            graph.contains(
              Triple(subject: Iri('s2'), predicate: p, object: Iri('o2')),
            ),
            isTrue,
          );
        });
      });

      group('Querying', () {
        final s1 = Iri('s1');
        final p1 = Iri('p1');
        final o1 = Iri('o1');
        final t1 = Triple(subject: s1, predicate: p1, object: o1);

        final s2 = Iri('s2');
        final t2 = Triple(subject: s2, predicate: p1, object: o1);

        setUp(() {
          graph.add(t1);
          graph.add(t2);
        });

        test('Match all', () {
          expect(graph.match(), hasLength(2));
        });

        test('Match by subject', () {
          expect(graph.match(subject: s1), unorderedEquals([t1]));
        });

        test('Match by predicate', () {
          expect(graph.match(predicate: p1), unorderedEquals([t1, t2]));
        });

        test('Match by object', () {
          expect(graph.match(object: o1), unorderedEquals([t1, t2]));
        });

        test('No match', () {
          expect(graph.match(subject: Iri('none')), isEmpty);
        });

        test('Nodes', () {
          expect(graph.nodes, unorderedEquals([s1, o1, s2]));
        });
      });

      group('Properties', () {
        test('isGround is true for empty graph', () {
          expect(graph.isGround, isTrue);
        });

        test('isGround is true for graph with ground triples', () {
          graph.add(
            Triple(
              subject: Iri('s'),
              predicate: Iri('p'),
              object: Literal('o'),
            ),
          );
          expect(graph.isGround, isTrue);
        });

        test('isGround is false for graph with blank nodes', () {
          graph.add(
            Triple(
              subject: BlankNode('b'),
              predicate: Iri('p'),
              object: Iri('o'),
            ),
          );
          expect(graph.isGround, isFalse);
        });

        test('isGround is false for mixed graph', () {
          graph.add(
            Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o')),
          );
          graph.add(
            Triple(
              subject: BlankNode('b'),
              predicate: Iri('p'),
              object: Iri('o'),
            ),
          );
          expect(graph.isGround, isFalse);
        });
      });
    });

    group('RDF 1.2 Features', () {
      group('TripleTerm Integration', () {
        late TripleTerm tt;
        late Triple containerTriple;

        setUp(() {
          tt = TripleTerm(
            Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o')),
          );
          containerTriple = Triple(
            subject: Iri('s2'),
            predicate: Iri('p2'),
            object: tt,
          );
        });

        test('Add Triple with TripleTerm', () {
          expect(graph.add(containerTriple), isTrue);
          expect(graph.length, 1);
        });

        test('Match Triple with TripleTerm', () {
          graph.add(containerTriple);
          expect(graph.match(object: tt), contains(containerTriple));
        });

        test('Recursive isGround check', () {
          graph.add(containerTriple);
          expect(graph.isGround, isTrue);
        });

        test('Recursive isGround check with blank node in TripleTerm', () {
          final ttUnground = TripleTerm(
            Triple(
              subject: BlankNode('b'),
              predicate: Iri('p'),
              object: Iri('o'),
            ),
          );
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: ttUnground,
          );
          graph.add(t);
          expect(graph.isGround, isFalse);
        });
      });
    });
    group('Isomorphism', () {
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
  });
}
