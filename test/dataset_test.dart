import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/model/impl/in_memory_dataset.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryDataset', () {
    late Dataset dataset;
    final s1 = NamedNode('http://example.org/s1');
    final p1 = NamedNode('http://example.org/p1');
    final o1 = Literal(
      'o1',
      datatype: NamedNode('http://www.w3.org/2001/XMLSchema#string'),
    );
    final t1 = Triple(subject: s1, predicate: p1, object: o1);

    final g1Name = NamedNode('http://example.org/g1');

    // Quad in default graph
    final qDefault = Quad(t1);
    // Quad in named graph
    final qNamed = Quad(t1, g1Name);

    setUp(() {
      dataset = InMemoryDataset();
    });

    test('starts empty', () {
      expect(dataset.quads, isEmpty);
      expect(dataset.defaultGraph.length, 0);
      expect(dataset.graphNames, isEmpty);
    });

    test('add quad to default graph', () {
      expect(dataset.add(qDefault), isTrue);
      expect(dataset.defaultGraph.length, 1);
      expect(dataset.defaultGraph.contains(t1), isTrue);
      expect(dataset.graphNames, isEmpty); // Default graph is not in graphNames
    });

    test('add quad to named graph', () {
      expect(dataset.add(qNamed), isTrue);
      expect(dataset.defaultGraph.length, 0);
      expect(dataset.graphNames, contains(g1Name));
      expect(dataset.namedGraph(g1Name).contains(t1), isTrue);
    });

    test('remove quad from default graph', () {
      dataset.add(qDefault);
      expect(dataset.remove(qDefault), isTrue);
      expect(dataset.defaultGraph.length, 0);
    });

    test('remove quad from named graph', () {
      dataset.add(qNamed);
      expect(dataset.remove(qNamed), isTrue);
      expect(dataset.namedGraph(g1Name).length, 0);
      // Graph might still exist but be empty, depending on implementation.
      // FastDataset keeps the graph object.
      expect(dataset.graphNames, contains(g1Name));
    });

    test('match quads', () {
      dataset.add(qDefault);
      dataset.add(qNamed);

      // Match all
      expect(dataset.match(), hasLength(2));

      // Match by graph name (explicit)
      expect(dataset.match(graphName: g1Name), unorderedEquals([qNamed]));

      // Match by subject (across all graphs)
      expect(dataset.match(subject: s1), hasLength(2));

      // Match non-existent graph
      expect(dataset.match(graphName: NamedNode('http://other')), isEmpty);
    });

    test('namedGraph returns same instance', () {
      final g1 = dataset.namedGraph(g1Name);
      final g2 = dataset.namedGraph(g1Name);
      expect(g1, same(g2));
    });
  });
}
