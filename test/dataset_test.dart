import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Dataset', () {
    late Dataset dataset;

    setUp(() {
      dataset = InMemoryDataset();
    });

    group('RDF 1.1 Features', () {
      group('Modification', () {
        test('Starts empty', () {
          expect(dataset.quads, isEmpty);
          expect(dataset.defaultGraph.length, 0);
          expect(dataset.graphNames, isEmpty);
        });

        test('Add quad to default graph (implicitly)', () {
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: Iri('o'),
          );
          final q = Quad(t);
          expect(dataset.add(q), isTrue);
          expect(dataset.defaultGraph.length, 1);
          expect(dataset.defaultGraph.contains(t), isTrue);
          expect(dataset.graphNames, isEmpty);
        });

        test('Add quad to named graph', () {
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: Iri('o'),
          );
          final gName = Iri('g1');
          final q = Quad(t, gName);
          expect(dataset.add(q), isTrue);
          expect(dataset.defaultGraph.length, 0);
          expect(dataset.graphNames, contains(gName));
          expect(dataset.namedGraph(gName).contains(t), isTrue);
        });

        test('Remove quad', () {
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: Iri('o'),
          );
          final gName = Iri('g1');
          final q = Quad(t, gName);
          dataset.add(q);

          expect(dataset.remove(q), isTrue);
          expect(dataset.namedGraph(gName).length, 0);
        });
      });

      group('Querying', () {
        final g1 = Iri('g1');
        final t1 = Triple(
          subject: Iri('s1'),
          predicate: Iri('p'),
          object: Iri('o'),
        );
        final q1 = Quad(t1, g1);

        final t2 = Triple(
          subject: Iri('s2'),
          predicate: Iri('p'),
          object: Iri('o'),
        );
        final q2 = Quad(t2); // Default graph

        setUp(() {
          dataset.add(q1);
          dataset.add(q2);
        });

        test('Match all', () {
          expect(dataset.match(), hasLength(2));
        });

        test('Match specific graph', () {
          expect(dataset.match(graphName: g1), unorderedEquals([q1]));
        });

        test(
          'Match default graph only (implementation dependent, usually via null)',
          () {
            // Note: In some implementations, passing null might mean wildcard.
            // But traditionally match() on Dataset with graphName: null acts as wildcard for ALL graphs.
            // To access default graph specifically, we use dataset.defaultGraph.
            expect(dataset.defaultGraph.length, 1);
            expect(dataset.defaultGraph.contains(t2), isTrue);
          },
        );

        test('Match by subject across all graphs', () {
          expect(dataset.match(subject: Iri('s1')), unorderedEquals([q1]));
          expect(dataset.match(subject: Iri('s2')), unorderedEquals([q2]));
        });
      });

      group('Views', () {
        test('Named graph view creation', () {
          final gName = Iri('g1');
          final graph = dataset.namedGraph(gName);
          expect(graph, isNotNull);
          expect(graph.length, 0);
        });

        test('Named graph identity', () {
          final gName = Iri('g1');
          final g1 = dataset.namedGraph(gName);
          final g2 = dataset.namedGraph(gName);
          expect(g1, same(g2));
        });

        test('Modification via view affects dataset', () {
          final gName = Iri('g1');
          final graph = dataset.namedGraph(gName);
          final t = Triple(
            subject: Iri('s'),
            predicate: Iri('p'),
            object: Iri('o'),
          );
          graph.add(t);

          expect(dataset.match(graphName: gName), hasLength(1));
          expect(dataset.match(graphName: gName).first.triple, equals(t));
        });
      });
    });
    group('Isomorphism', () {
      test('Empty datasets are isomorphic', () {
        expect(InMemoryDataset().isomorphic(InMemoryDataset()), isTrue);
      });

      test('Permutation of quads', () {
        final q1 = Quad(
          Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o1')),
        );
        final q2 = Quad(
          Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o2')),
        );

        final d1 = InMemoryDataset();
        d1.add(q1);
        d1.add(q2);

        final d2 = InMemoryDataset();
        d2.add(q2);
        d2.add(q1);

        expect(d1.isomorphic(d2), isTrue);
      });

      test('Blank Node Scope Consistency (Same BNode in different graphs)', () {
        // BNode 'b1' used in Default Graph AND Named Graph 'g1'
        // effectively it's the same node across the dataset.
        final d1 = InMemoryDataset();
        final b1 = BlankNode('b1');
        d1.add(
          Quad(Triple(subject: b1, predicate: Iri('p'), object: Iri('o'))),
        );
        d1.add(
          Quad(
            Triple(subject: b1, predicate: Iri('p'), object: Iri('o2')),
            Iri('g1'),
          ),
        );

        final d2 = InMemoryDataset();
        final b2 = BlankNode('b2');
        d2.add(
          Quad(Triple(subject: b2, predicate: Iri('p'), object: Iri('o'))),
        );
        d2.add(
          Quad(
            Triple(subject: b2, predicate: Iri('p'), object: Iri('o2')),
            Iri('g1'),
          ),
        );

        expect(d1.isomorphic(d2), isTrue);
      });

      test('Blank Node Scope Broken (Different BNodes mapped to same)', () {
        // d1 uses same b1 for both
        final d1 = InMemoryDataset();
        final b1 = BlankNode('b1');
        d1.add(
          Quad(Triple(subject: b1, predicate: Iri('p'), object: Iri('o'))),
        );
        d1.add(
          Quad(
            Triple(subject: b1, predicate: Iri('p'), object: Iri('o2')),
            Iri('g1'),
          ),
        );

        // d3 uses b3 and b4 (distinct)
        final d3 = InMemoryDataset();
        final b3 = BlankNode('b3');
        final b4 = BlankNode('b4');
        d3.add(
          Quad(Triple(subject: b3, predicate: Iri('p'), object: Iri('o'))),
        );
        d3.add(
          Quad(
            Triple(subject: b4, predicate: Iri('p'), object: Iri('o2')),
            Iri('g1'),
          ),
        );

        expect(d1.isomorphic(d3), isFalse);
      });

      test('Blank Node as Graph Name', () {
        // _:g1 { s p o }
        final d1 = InMemoryDataset();
        final g1 = BlankNode('g1');
        d1.add(
          Quad(
            Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o')),
            g1,
          ),
        );

        // _:g2 { s p o }
        final d2 = InMemoryDataset();
        final g2 = BlankNode('g2');
        d2.add(
          Quad(
            Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o')),
            g2,
          ),
        );

        expect(d1.isomorphic(d2), isTrue);
      });

      test('Default Graph vs Named Graph Distinction', () {
        // Isomorphism must respect graph names.
        final d1 = InMemoryDataset();
        d1.add(
          Quad(
            Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o')),
          ),
        );

        final d2 = InMemoryDataset();
        d2.add(
          Quad(
            Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o')),
            Iri('g'),
          ),
        );

        expect(d1.isomorphic(d2), isFalse);
      });
    });
  });
}
