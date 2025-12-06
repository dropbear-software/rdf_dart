import 'package:intl/intl.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Literal Details', () {
    test('Value Mapping - Integer', () {
      final integerType = Iri('http://www.w3.org/2001/XMLSchema#integer');
      final lit = Literal('123', datatypeIri: integerType);

      expect(lit.lexicalForm, '123');
      expect(lit.datatypeIri, integerType);
      expect(lit.value, BigInt.from(123)); // Check typed value
    });

    test('Value Mapping - Boolean', () {
      final booleanType = Iri('http://www.w3.org/2001/XMLSchema#boolean');
      final lit = Literal('true', datatypeIri: booleanType);

      expect(lit.value, true);
    });

    test('Value Mapping - Ill-typed', () {
      final integerType = Iri('http://www.w3.org/2001/XMLSchema#integer');
      final lit = Literal('abc', datatypeIri: integerType);

      // Should be null for ill-typed
      expect(lit.value, isNull);
    });

    test('Equality - Case Insensitive Language', () {
      final l1 = Literal('hello', languageTag: 'en-US');
      final l2 = Literal('hello', languageTag: 'EN-us');

      expect(l1, equals(l2));
      expect(l1.hashCode, equals(l2.hashCode));
    });

    test('Equality - Direction', () {
      final l1 = Literal(
        'hello',
        languageTag: 'en',
        baseDirection: TextDirection.LTR,
      );
      final l2 = Literal(
        'hello',
        languageTag: 'en',
        baseDirection: TextDirection.LTR,
      );
      final l3 = Literal(
        'hello',
        languageTag: 'en',
        baseDirection: TextDirection.RTL,
      );

      expect(l1, equals(l2));
      expect(l1, isNot(equals(l3)));
    });

    group('Validation', () {
      test('Language with xsd:string throws FormatException', () {
        expect(
          () => Literal(
            'hello',
            languageTag: 'en',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#string'),
          ),
          throwsFormatException,
        );
      });

      test('Direction without language throws FormatException', () {
        // Here we explicitly provide a datatype that is NOT dirLangString, so direction shouldn't be valid
        // Actually, if we provide direction and NO datatype, it infers dirLangString so it's valid.
        // But if we provide direction and xsd:string, it should fail.
        expect(
          () => Literal(
            'hello',
            baseDirection: TextDirection.LTR,
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#string'),
          ),
          throwsFormatException,
        );
      });

      test('Direction with rdf:langString throws FormatException', () {
        expect(
          () => Literal(
            'hello',
            languageTag: 'en',
            baseDirection: TextDirection.LTR,
            datatypeIri: Iri(
              'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
            ),
          ),
          throwsFormatException,
        );
      });

      test('Missing language for rdf:langString throws FormatException', () {
        expect(
          () => Literal(
            'hello',
            datatypeIri: Iri(
              'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
            ),
          ),
          throwsFormatException,
        );
      });

      test('Missing language for rdf:dirLangString throws FormatException', () {
        expect(
          () => Literal(
            'hello',
            baseDirection: TextDirection.LTR,
            datatypeIri: Iri(
              'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString',
            ),
          ),
          throwsFormatException,
        );
      });

      test(
        'Missing direction for rdf:dirLangString throws FormatException',
        () {
          expect(
            () => Literal(
              'hello',
              languageTag: 'en',
              datatypeIri: Iri(
                'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString',
              ),
            ),
            throwsFormatException,
          );
        },
      );
    });
  });
}
