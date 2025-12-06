import 'package:intl/intl.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Literals', () {
    group('RDF 1.1 Features', () {
      group('Creating Literals', () {
        test('Creating Literal with xsd:string', () {
          final lit = Literal(
            'hello',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#string'),
          );
          expect(lit.lexicalForm, 'hello');
          expect(
            lit.datatypeIri,
            Iri('http://www.w3.org/2001/XMLSchema#string'),
          );
          expect(lit.value, 'hello');
        });
      });
    });

    group('RDF 1.2 Features', () {
      group('Creating Literals', () {
        test('Directional language-tagged strings with valid values', () {
          expect(
            () => Literal(
              'hello',
              languageTag: 'en',
              baseDirection: TextDirection.LTR,
              datatypeIri: Iri(
                'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString',
              ),
            ),
            returnsNormally,
          );
        });
      });
    });
  });
}
