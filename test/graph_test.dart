import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/model/impl/in_memory_graph.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryGraph', () {
    late Graph graph;
    final s1 = Iri('http://example.org/s1');
    final p1 = Iri('http://example.org/p1');
    final o1 = Literal(
      'o1',
      datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#string'),
    );
    final t1 = Triple(subject: s1, predicate: p1, object: o1);

    final s2 = Iri('http://example.org/s2');
    final t2 = Triple(subject: s2, predicate: p1, object: o1);

    setUp(() {
      graph = InMemoryGraph();
    });

    test('starts empty', () {
      expect(graph.length, 0);
      expect(graph.triples, isEmpty);
    });

    test('add triple', () {
      expect(graph.add(t1), isTrue);
      expect(graph.length, 1);
      expect(graph.contains(t1), isTrue);
    });

    test('add duplicate triple', () {
      graph.add(t1);
      expect(graph.add(t1), isFalse);
      expect(graph.length, 1);
    });

    test('remove triple', () {
      graph.add(t1);
      expect(graph.remove(t1), isTrue);
      expect(graph.length, 0);
      expect(graph.contains(t1), isFalse);
    });

    test('remove non-existent triple', () {
      expect(graph.remove(t1), isFalse);
    });

    test('match triples', () {
      graph.add(t1);
      graph.add(t2);

      // Match all
      expect(graph.match(), hasLength(2));

      // Match by subject
      expect(graph.match(subject: s1), unorderedEquals([t1]));

      // Match by predicate
      expect(graph.match(predicate: p1), hasLength(2));

      // Match by object
      expect(graph.match(object: o1), hasLength(2));

      // No match
      expect(graph.match(subject: Iri('http://example.org/none')), isEmpty);
    });
  });
}
