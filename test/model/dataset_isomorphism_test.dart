import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/model/impl/in_memory_dataset.dart';
import 'package:test/test.dart';

void main() {
  group('Dataset Isomorphism', () {
    test('Empty datasets are isomorphic', () {
      final d1 = InMemoryDataset();
      final d2 = InMemoryDataset();
      expect(d1.isomorphic(d2), isTrue);
    });

    test('Identical ground datasets are isomorphic', () {
      final d1 = InMemoryDataset();
      d1.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
          Iri('http://g'),
        ),
      );

      final d2 = InMemoryDataset();
      d2.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
          Iri('http://g'),
        ),
      );

      expect(d1.isomorphic(d2), isTrue);
    });

    test('Different ground datasets are not isomorphic', () {
      final d1 = InMemoryDataset();
      d1.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
          Iri('http://g1'),
        ),
      );

      final d2 = InMemoryDataset();
      d2.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
          Iri('http://g2'),
        ),
      );

      expect(d1.isomorphic(d2), isFalse);
    });

    test('Isomorphic with blank node renaming in triple', () {
      // G { s p _:b1 }
      final d1 = InMemoryDataset();
      d1.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: BlankNode('b1'),
          ),
          Iri('http://g'),
        ),
      );

      // G { s p _:b2 }
      final d2 = InMemoryDataset();
      d2.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: BlankNode('b2'),
          ),
          Iri('http://g'),
        ),
      );

      expect(d1.isomorphic(d2), isTrue);
    });

    test('Isomorphic with blank node renaming in graph name', () {
      // _:g1 { s p o }
      final d1 = InMemoryDataset();
      d1.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
          BlankNode('g1'),
        ),
      );

      // _:g2 { s p o }
      final d2 = InMemoryDataset();
      d2.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
          BlankNode('g2'),
        ),
      );

      expect(d1.isomorphic(d2), isTrue);
    });

    test('Isomorphic with blank node shared between triple and graph name', () {
      // _:b1 { s p _:b1 }
      final d1 = InMemoryDataset();
      final b1 = BlankNode('b1');
      d1.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: b1,
          ),
          b1,
        ),
      );

      // _:b2 { s p _:b2 }
      final d2 = InMemoryDataset();
      final b2 = BlankNode('b2');
      d2.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: b2,
          ),
          b2,
        ),
      );

      expect(d1.isomorphic(d2), isTrue);

      // _:b3 { s p _:b4 } (different bnodes)
      final d3 = InMemoryDataset();
      final b3 = BlankNode('b3');
      final b4 = BlankNode('b4');
      d3.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: b4,
          ),
          b3,
        ),
      );

      expect(d1.isomorphic(d3), isFalse);
    });

    test('Default graph vs Named Graph', () {
      // Default Graph { s p o }
      final d1 = InMemoryDataset();
      d1.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
        ),
      );

      // Named Graph { s p o }
      final d2 = InMemoryDataset();
      d2.add(
        Quad(
          Triple(
            subject: Iri('http://s'),
            predicate: Iri('http://p'),
            object: Iri('http://o'),
          ),
          Iri('http://g'),
        ),
      );

      expect(d1.isomorphic(d2), isFalse);
    });
  });
}
