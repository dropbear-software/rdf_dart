import 'package:intl/intl.dart';
import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';
import 'package:xsd/xsd.dart';

void main() {
  group('Literals', () {
    group('RDF 1.1 Features', () {
      group('Creation and Validation', () {
        test('Default datatype is xsd:string', () {
          final lit = Literal('hello');
          expect(lit.lexicalForm, 'hello');
          expect(
            lit.datatypeIri,
            Iri('http://www.w3.org/2001/XMLSchema#string'),
          );
          expect(lit.languageTag, isNull);
          expect(lit.baseDirection, isNull);
          expect(lit.value, 'hello');
        });

        test('Explicit datatype creation', () {
          final lit = Literal(
            '123',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
          );
          expect(lit.lexicalForm, '123');
          expect(
            lit.datatypeIri,
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
          );
          expect(lit.value, BigInt.from(123));
        });

        test('Language-tagged string implies rdf:langString', () {
          final lit = Literal('bonjour', languageTag: 'fr');
          expect(lit.lexicalForm, 'bonjour');
          expect(lit.languageTag, 'fr');
          expect(
            lit.datatypeIri,
            Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#langString'),
          );
          expect(lit.value, 'bonjour');
        });

        test('Valid language tag validation', () {
          expect(() => Literal('hello', languageTag: 'en-US'), returnsNormally);
        });

        test('Invalid language tag throws exception', () {
          expect(
            () => Literal('hello', languageTag: 'invalid language tag'),
            throwsFormatException,
          );
        });

        test('Explicit rdf:langString requires language tag', () {
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

        test('Explicit rdf:langString forbids direction', () {
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

        test('Other datatypes forbid language tag', () {
          expect(
            () => Literal(
              'hello',
              languageTag: 'en',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#string'),
            ),
            throwsFormatException,
          );
        });
      });

      group('Value Mapping', () {
        group('XML Schema Datatypes', () {
          group('Core types', () {
            test('Maps xsd:boolean', () {
              expect(
                Literal(
                  '1',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#boolean'),
                ).value,
                true,
              );
              expect(
                Literal(
                  'true',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#boolean'),
                ).value,
                true,
              );
              expect(
                Literal(
                  '0',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#boolean'),
                ).value,
                false,
              );
              expect(
                Literal(
                  'false',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#boolean'),
                ).value,
                false,
              );
            });
            test('Maps xsd:integer', () {
              expect(
                Literal(
                  '42',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
                ).value,
                BigInt.from(42),
              );
            });

            test('Maps xsd:string', () {
              expect(
                Literal(
                  'Hello World',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#string'),
                ).value,
                'Hello World',
              );
            });
          });

          group('IEEE floating-point numbers', () {
            test('Maps xsd:double', () {
              expect(
                Literal(
                  '3.14',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#double'),
                ).value,
                3.14,
              );

              expect(
                Literal(
                  '03.14',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#double'),
                ).value,
                3.14,
              );
            });

            test('Maps xsd:float', () {
              expect(
                Literal(
                  'INF',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#float'),
                ).value,
                double.infinity,
              );

              expect(
                Literal(
                  '-INF',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#float'),
                ).value,
                double.negativeInfinity,
              );

              expect(
                Literal(
                  '-12300.0',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#float'),
                ).value,
                -1.23e4,
              );
            });
          });

          group('Time and date', () {
            test('Maps xsd:date', () {
              final dateLiteral = Literal(
                '2002-10-10-05:00',
                datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#date'),
              );

              expect(dateLiteral.value, XsdDate.parse('2002-10-10-05:00'));
              expect((dateLiteral.value as XsdDate).value.year, 2002);
              expect((dateLiteral.value as XsdDate).value.month, 10);
              expect((dateLiteral.value as XsdDate).value.day, 10);
              expect(
                (dateLiteral.value as XsdDate).originalOffset,
                const Duration(hours: -5),
              );
            });

            test('Maps xsd:dateTime', () {
              final dateLiteral = Literal(
                '2002-10-10T12:00:00+05:30',
                datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#dateTime'),
              );

              expect(
                dateLiteral.value,
                XsdDateTime.parse('2002-10-10T12:00:00+05:30'),
              );
              expect((dateLiteral.value as XsdDateTime).value.year, 2002);
              expect((dateLiteral.value as XsdDateTime).value.month, 10);
              expect((dateLiteral.value as XsdDateTime).value.day, 10);
              expect((dateLiteral.value as XsdDateTime).value.isUtc, isTrue);
              expect((dateLiteral.value as XsdDateTime).value.hour, 6);
              expect((dateLiteral.value as XsdDateTime).value.minute, 30);
              expect(
                (dateLiteral.value as XsdDateTime).originalOffset,
                const Duration(hours: 5, minutes: 30),
              );
            });
          });
        });

        group('Recurring and partial dates', () {
          test('Maps xsd:gYear', () {
            final dateLiteral = Literal(
              '0000',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gYear'),
            );

            expect(dateLiteral.value, GregorianYear.parse('0000'));
            expect((dateLiteral.value as GregorianYear).year, 0);
          });

          test('Maps xsd:gYearMonth', () {
            final dateLiteral = Literal(
              '2002-10',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gYearMonth'),
            );

            expect(dateLiteral.value, YearMonth.parse('2002-10'));
            expect((dateLiteral.value as YearMonth).year, 2002);
            expect((dateLiteral.value as YearMonth).month, 10);
          });

          test('Maps xsd:gMonth', () {
            final dateLiteral = Literal(
              '--02+05:30',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gMonth'),
            );

            expect(
              dateLiteral.value,
              GregorianMonth(2, timezoneOffsetInMinutes: 330),
            );
          });

          test('Maps xsd:gMonthDay', () {
            final dateLiteral = Literal(
              '--12-31',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gMonthDay'),
            );

            expect(dateLiteral.value, GregorianMonthDay(12, 31));
          });

          test('Maps xsd:gDay', () {
            final dateLiteral = Literal(
              '---03-08:00',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gDay'),
            );

            expect(
              dateLiteral.value,
              GregorianDay(3, timezoneOffsetInMinutes: -480),
            );
          });
        });

        group('Durations', () {
          test('Maps xsd:duration', () {
            final durationLiteral = Literal(
              'P1Y1M',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#duration'),
            );

            expect(durationLiteral.value, XsdDuration(months: 13));
          });
        });

        group('Limited-range integer numbers', () {
          test('Maps xsd:byte', () {
            final byteLiteral = Literal(
              '-128',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#byte'),
            );

            expect(byteLiteral.value, -128);
          });

          test('Maps xsd:short', () {
            final shortLiteral = Literal(
              '32758',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#short'),
            );

            expect(shortLiteral.value, 32758);
          });

          test('Maps xsd:int', () {
            final intLiteral = Literal(
              '214748364',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#int'),
            );

            expect(intLiteral.value, 214748364);
          });

          test('Maps xsd:long', () {
            final intLiteral = Literal(
              '9223372036854775801',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#long'),
            );

            expect(intLiteral.value, BigInt.from(9223372036854775801));
          });

          test('Maps xsd:unsignedByte', () {
            final byteLiteral = Literal(
              '255',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#unsignedByte'),
            );

            expect(byteLiteral.value, 255);
          });

          test('Maps xsd:unsignedShort', () {
            final byteLiteral = Literal(
              '65530',
              datatypeIri: Iri(
                'http://www.w3.org/2001/XMLSchema#unsignedShort',
              ),
            );

            expect(byteLiteral.value, 65530);
          });
        });

        group('Encoded binary data', () {});

        group('Miscellaneous XSD types', () {});

        test(
          'Ill-typed literals have null value but keep their lexical form',
          () {
            final lit = Literal(
              'not-a-number',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
            );
            expect(lit.value, isNull);
            expect(lit.lexicalForm, 'not-a-number');
          },
        );

        test('Unknown datatypes return lexical form as value', () {
          expect(
            Literal(
              'custom',
              datatypeIri: Iri('http://example.org/myType'),
            ).value,
            'custom',
          );
        });
      });

      group('Equality and HashCode', () {
        test('Identity equality', () {
          final lit = Literal('hello');
          expect(lit, equals(lit));
        });

        test('Value equality structural', () {
          final lit1 = Literal(
            '1',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
          );
          final lit2 = Literal(
            '1',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
          );
          expect(lit1, equals(lit2));
          expect(lit1.hashCode, equals(lit2.hashCode));
        });

        test('Different lexical forms are not equal', () {
          final lit1 = Literal('a');
          final lit2 = Literal('b');
          expect(lit1, isNot(equals(lit2)));
        });

        test('Different datatypes are not equal', () {
          final lit1 = Literal(
            '1',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#string'),
          );
          final lit2 = Literal(
            '1',
            datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
          );
          expect(lit1, isNot(equals(lit2)));
        });

        test('Language tags are case-insensitive for equality', () {
          final lit1 = Literal('hello', languageTag: 'en-US');
          final lit2 = Literal('hello', languageTag: 'EN-us');
          expect(lit1, equals(lit2));
          expect(lit1.hashCode, equals(lit2.hashCode));
        });

        test('Different language tags are not equal', () {
          final lit1 = Literal('hello', languageTag: 'en');
          final lit2 = Literal('hello', languageTag: 'fr');
          expect(lit1, isNot(equals(lit2)));
        });
      });

      group('toString', () {
        test('Simple literal', () {
          final lit = Literal('hello');
          expect(
            lit.toString(),
            '"hello"^^<http://www.w3.org/2001/XMLSchema#string>',
          );
        });

        test('Language-tagged literal', () {
          final lit = Literal('hello', languageTag: 'en');
          expect(lit.toString(), '"hello"@en');
        });
      });

      group('isGround', () {
        test('Literal is always ground', () {
          expect(Literal('foo').isGround, isTrue);
          expect(Literal('foo', languageTag: 'en').isGround, isTrue);
        });
      });
    });

    group('RDF 1.2 Features', () {
      group('Creation and Validation', () {
        test('Direction implies rdf:dirLangString', () {
          final lit = Literal(
            'hello',
            languageTag: 'en',
            baseDirection: TextDirection.LTR,
          );
          expect(lit.lexicalForm, 'hello');
          expect(lit.languageTag, 'en');
          expect(lit.baseDirection, TextDirection.LTR);
          expect(
            lit.datatypeIri,
            Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString'),
          );
        });

        test('Explicit rdf:dirLangString requires direction and lang', () {
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

        test('Explicit rdf:dirLangString missing direction throws', () {
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
        });

        test('Explicit rdf:dirLangString missing lang throws', () {
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

        test('Other datatypes forbid direction', () {
          expect(
            () => Literal(
              'hello',
              baseDirection: TextDirection.LTR,
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#string'),
            ),
            throwsFormatException,
          );
        });
      });

      group('Equality', () {
        test('Different directions are not equal', () {
          final lit1 = Literal(
            'hello',
            languageTag: 'en',
            baseDirection: TextDirection.LTR,
          );
          final lit2 = Literal(
            'hello',
            languageTag: 'en',
            baseDirection: TextDirection.RTL,
          );
          expect(lit1, isNot(equals(lit2)));
        });

        test('Directional vs non-directional are not equal', () {
          final lit1 = Literal(
            'hello',
            languageTag: 'en',
            baseDirection: TextDirection.LTR,
          );
          final lit2 = Literal('hello', languageTag: 'en');
          expect(lit1, isNot(equals(lit2)));
        });
      });

      group('toString', () {
        test('Directional literal', () {
          final lit = Literal(
            'hello',
            languageTag: 'en',
            baseDirection: TextDirection.LTR,
          );
          expect(lit.toString(), '"hello"@en--ltr');
        });
      });
    });
  });
}
