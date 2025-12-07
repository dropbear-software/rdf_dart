import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/model/impl/in_memory_dataset.dart';
import 'package:test/test.dart';

void main() {
  group('Dataset Isomorphism', () {
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
      d1.add(Quad(Triple(subject: b1, predicate: Iri('p'), object: Iri('o'))));
      d1.add(
        Quad(
          Triple(subject: b1, predicate: Iri('p'), object: Iri('o2')),
          Iri('g1'),
        ),
      );

      final d2 = InMemoryDataset();
      final b2 = BlankNode('b2');
      d2.add(Quad(Triple(subject: b2, predicate: Iri('p'), object: Iri('o'))));
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
      d1.add(Quad(Triple(subject: b1, predicate: Iri('p'), object: Iri('o'))));
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
      d3.add(Quad(Triple(subject: b3, predicate: Iri('p'), object: Iri('o'))));
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
        Quad(Triple(subject: Iri('s'), predicate: Iri('p'), object: Iri('o'))),
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
}
