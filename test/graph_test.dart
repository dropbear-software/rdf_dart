import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/model/impl/in_memory_graph.dart';
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
  });
}
