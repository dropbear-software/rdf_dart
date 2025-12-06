import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Triples', () {
    group('RDF 1.1 Features', () {
      group('Creating Triples', () {
        test('Using only IRIs', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = Iri('http://example.org/o');

          expect(
            () => Triple(subject: s, predicate: p, object: o),
            returnsNormally,
          );
        });

        test('With a Blank Node subject', () {
          final s = BlankNode('b1');
          final p = Iri('http://example.org/p');
          final o = Iri('http://example.org/o');

          expect(
            () => Triple(subject: s, predicate: p, object: o),
            returnsNormally,
          );
        });

        test('With a Blank Node object', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = BlankNode('b1');

          expect(
            () => Triple(subject: s, predicate: p, object: o),
            returnsNormally,
          );
        });

        test('With a Blank Node subject and object', () {
          final s = BlankNode('b1');
          final p = Iri('http://example.org/p');
          final o = BlankNode('b2');

          expect(
            () => Triple(subject: s, predicate: p, object: o),
            returnsNormally,
          );
        });

        test('With the same Blank Node subject and object', () {
          final s = BlankNode('b1');
          final p = Iri('http://example.org/p');
          final o = BlankNode('b1');

          expect(s, equals(o));
          expect(
            () => Triple(subject: s, predicate: p, object: o),
            returnsNormally,
          );
        });
      });

      group('Ground triples', () {
        test('Using only IRIs is grounded', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = Iri('http://example.org/o');

          final triple = Triple(subject: s, predicate: p, object: o);
          expect(triple.isGround, isTrue);
        });

        test('Using a Literal object is grounded', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = Literal('object');

          final triple = Triple(subject: s, predicate: p, object: o);
          expect(triple.isGround, isTrue);
        });

        test('Using a BlankNode object is not grounded', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = BlankNode('b1');

          final triple = Triple(subject: s, predicate: p, object: o);
          expect(triple.isGround, isFalse);
        });

        test('Using a BlankNode subject is not grounded', () {
          final s = BlankNode('b1');
          final p = Iri('http://example.org/p');
          final o = Iri('http://example.org/s');

          final triple = Triple(subject: s, predicate: p, object: o);
          expect(triple.isGround, isFalse);
        });
      });
      group('Equality', () {
        test(
          'Triples are equal if they have the same subject, predicate, and object',
          () {
            final s = Iri('http://example.org/s');
            final p = Iri('http://example.org/p');
            final o = Iri('http://example.org/o');

            final triple1 = Triple(subject: s, predicate: p, object: o);
            final triple2 = Triple(subject: s, predicate: p, object: o);

            expect(triple1, equals(triple2));
            expect(triple1.hashCode, equals(triple2.hashCode));
          },
        );

        test('The RDF Terms of the triple implement equality semantics', () {
          final s1 = BlankNode('b1');
          final p1 = Iri('http://example.org/p');
          final o1 = Literal(
            '123',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#byte'),
          );

          final s2 = BlankNode('b1');
          final p2 = Iri('http://example.org/p');
          final o2 = Literal(
            '123',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#byte'),
          );

          final triple1 = Triple(subject: s1, predicate: p1, object: o1);
          final triple2 = Triple(subject: s2, predicate: p2, object: o2);

          expect(triple1, equals(triple2));
          expect(triple1.hashCode, equals(triple2.hashCode));
        });

        test('Is determined by lexical equality not value equality', () {
          final s1 = BlankNode('b1');
          final p1 = Iri('http://example.org/p');
          final o1 = Literal(
            '1',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
          );

          final s2 = BlankNode('b1');
          final p2 = Iri('http://example.org/p');
          final o2 = Literal(
            '01',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
          );

          final triple1 = Triple(subject: s1, predicate: p1, object: o1);
          final triple2 = Triple(subject: s2, predicate: p2, object: o2);

          expect(
            (triple1.object as Literal).value,
            equals((triple2.object as Literal).value),
          );
          expect(
            (triple1.object as Literal).value.hashCode,
            equals((triple2.object as Literal).value.hashCode),
          );
          expect(triple1, isNot(equals(triple2)));
          expect(triple1.hashCode, isNot(equals(triple2.hashCode)));
        });
      });
    });

    group('RDF 1.2 Features', () {
      group('Creating Triples', () {
        test('With a TripleTerm object', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = TripleTerm(
            Triple(
              subject: Iri('http://example.org/s'),
              predicate: Iri('http://example.org/p'),
              object: Iri('http://example.org/o'),
            ),
          );

          expect(
            () => Triple(subject: s, predicate: p, object: o),
            returnsNormally,
          );
        });

        test('With a deeply nested TripleTerm object', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = TripleTerm(
            Triple(
              subject: Iri('http://example.org/s'),
              predicate: Iri('http://example.org/p'),
              object: TripleTerm(
                Triple(
                  subject: Iri('http://example.org/s'),
                  predicate: Iri('http://example.org/p'),
                  object: TripleTerm(
                    Triple(
                      subject: Iri('http://example.org/s'),
                      predicate: Iri('http://example.org/p'),
                      object: Iri('http://example.org/o'),
                    ),
                  ),
                ),
              ),
            ),
          );

          expect(
            () => Triple(subject: s, predicate: p, object: o),
            returnsNormally,
          );
        });
      });
      group('Ground Triples', () {
        test('With a ground TripleTerm object is grounded', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = TripleTerm(
            Triple(
              subject: Iri('http://example.org/s'),
              predicate: Iri('http://example.org/p'),
              object: Iri('http://example.org/o'),
            ),
          );

          final triple = Triple(subject: s, predicate: p, object: o);
          expect(o.triple.isGround, isTrue);
          expect(triple.isGround, isTrue);
        });

        test('With a unground TripleTerm object is ungrounded', () {
          final s = Iri('http://example.org/s');
          final p = Iri('http://example.org/p');
          final o = TripleTerm(
            Triple(
              subject: Iri('http://example.org/s'),
              predicate: Iri('http://example.org/p'),
              object: BlankNode('b1'),
            ),
          );

          final triple = Triple(subject: s, predicate: p, object: o);
          expect(o.triple.isGround, isFalse);
          expect(triple.isGround, isFalse);
        });
      });

      group('Equality', () {
        test('Works with TripleTerms as expected', () {
          final s1 = Iri('http://example.org/s');
          final p1 = Iri('http://example.org/p');
          final o1 = TripleTerm(
            Triple(
              subject: Iri('http://example.org/s'),
              predicate: Iri('http://example.org/p'),
              object: BlankNode('b1'),
            ),
          );

          final s2 = Iri('http://example.org/s');
          final p2 = Iri('http://example.org/p');
          final o2 = TripleTerm(
            Triple(
              subject: Iri('http://example.org/s'),
              predicate: Iri('http://example.org/p'),
              object: BlankNode('b1'),
            ),
          );

          final triple1 = Triple(subject: s1, predicate: p1, object: o1);
          final triple2 = Triple(subject: s2, predicate: p2, object: o2);

          expect(triple1, equals(triple2));
          expect(triple1.hashCode, equals(triple2.hashCode));
        });
      });
    });
  });
}
