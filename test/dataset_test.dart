import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/model/impl/in_memory_dataset.dart';
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
  });
}
