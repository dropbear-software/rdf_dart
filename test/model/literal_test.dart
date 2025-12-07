import 'dart:typed_data';

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
              final dateTimeLiteral = Literal(
                '2002-10-10T12:00:00+05:30',
                datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#dateTime'),
              );

              expect(
                dateTimeLiteral.value,
                XsdDateTime.parse('2002-10-10T12:00:00+05:30'),
              );
              expect((dateTimeLiteral.value as XsdDateTime).value.year, 2002);
              expect((dateTimeLiteral.value as XsdDateTime).value.month, 10);
              expect((dateTimeLiteral.value as XsdDateTime).value.day, 10);
              expect(
                (dateTimeLiteral.value as XsdDateTime).value.isUtc,
                isTrue,
              );
              expect((dateTimeLiteral.value as XsdDateTime).value.hour, 6);
              expect((dateTimeLiteral.value as XsdDateTime).value.minute, 30);
              expect(
                (dateTimeLiteral.value as XsdDateTime).originalOffset,
                const Duration(hours: 5, minutes: 30),
              );
            });
          });
        });

        group('Recurring and partial dates', () {
          test('Maps xsd:gYear', () {
            final gYearLiteral = Literal(
              '0000',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gYear'),
            );

            expect(gYearLiteral.value, GregorianYear.parse('0000'));
            expect((gYearLiteral.value as GregorianYear).year, 0);
          });

          test('Maps xsd:gYearMonth', () {
            final gYearMonthLiteral = Literal(
              '2002-10',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gYearMonth'),
            );

            expect(gYearMonthLiteral.value, YearMonth.parse('2002-10'));
            expect((gYearMonthLiteral.value as YearMonth).year, 2002);
            expect((gYearMonthLiteral.value as YearMonth).month, 10);
          });

          test('Maps xsd:gMonth', () {
            final gMonthLiteral = Literal(
              '--02+05:30',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gMonth'),
            );

            expect(
              gMonthLiteral.value,
              GregorianMonth(2, timezoneOffsetInMinutes: 330),
            );
          });

          test('Maps xsd:gMonthDay', () {
            final gMonthDayLiteral = Literal(
              '--12-31',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gMonthDay'),
            );

            expect(gMonthDayLiteral.value, GregorianMonthDay(12, 31));
          });

          test('Maps xsd:gDay', () {
            final gDayLiteral = Literal(
              '---03-08:00',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#gDay'),
            );

            expect(
              gDayLiteral.value,
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
            final longLiteral = Literal(
              '9223372036854775801',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#long'),
            );

            expect(longLiteral.value, BigInt.from(9223372036854775801));
          });

          test('Maps xsd:unsignedByte', () {
            final byteLiteral = Literal(
              '255',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#unsignedByte'),
            );

            expect(byteLiteral.value, 255);
          });

          test('Maps xsd:unsignedShort', () {
            final unsignedShortLiteral = Literal(
              '65530',
              datatypeIri: Iri(
                'http://www.w3.org/2001/XMLSchema#unsignedShort',
              ),
            );

            expect(unsignedShortLiteral.value, isA<int>());
            expect(unsignedShortLiteral.value, 65530);
          });

          test('Maps xsd:unsignedInt', () {
            final unsignedIntLiteral = Literal(
              '429496729',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#unsignedInt'),
            );

            expect(unsignedIntLiteral.value, 429496729);
          });

          test('Maps xsd:unsignedLong', () {
            final unsignedLongLiteral = Literal(
              '1844674407370955161',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#unsignedLong'),
            );

            expect(unsignedLongLiteral.value, BigInt.from(1844674407370955161));
          });

          test('Maps xsd:positiveInteger', () {
            final positiveIntegerLiteral = Literal(
              '\n\t+123  ',
              datatypeIri: Iri(
                'http://www.w3.org/2001/XMLSchema#positiveInteger',
              ),
            );

            expect(positiveIntegerLiteral.value, BigInt.from(123));
          });

          test('Maps xsd:nonNegativeInteger', () {
            final nonNegativeIntegerLiteral = Literal(
              '123456789',
              datatypeIri: Iri(
                'http://www.w3.org/2001/XMLSchema#nonNegativeInteger',
              ),
            );

            expect(nonNegativeIntegerLiteral.value, BigInt.from(123456789));
          });

          test('Maps xsd:negativeInteger', () {
            final negativeIntegerLiteral = Literal(
              '-123456789',
              datatypeIri: Iri(
                'http://www.w3.org/2001/XMLSchema#negativeInteger',
              ),
            );

            expect(negativeIntegerLiteral.value, BigInt.from(-123456789));
          });

          test('Maps xsd:nonPositiveInteger', () {
            final nonPositiveIntegerLiteral = Literal(
              '-123456789',
              datatypeIri: Iri(
                'http://www.w3.org/2001/XMLSchema#nonPositiveInteger',
              ),
            );

            expect(nonPositiveIntegerLiteral.value, BigInt.from(-123456789));
          });
        });

        group('Encoded binary data', () {
          test('Maps xsd:base64Binary', () {
            final byteLiteral = Literal(
              'Zm9v',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#base64Binary'),
            );

            expect(byteLiteral.value, Uint8List.fromList('foo'.codeUnits));
          });

          test('Maps xsd:hexBinary', () {
            final byteLiteral = Literal(
              '0123ABCDEF',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#hexBinary'),
            );

            expect(
              byteLiteral.value,
              Uint8List.fromList([0x01, 0x23, 0xAB, 0xCD, 0xEF]),
            );
          });
        });

        group('Miscellaneous XSD types', () {
          test('Maps xsd:anyURI', () {
            final uriLiteral = Literal(
              'urn:isbn:1234567890',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#anyURI'),
            );

            expect(uriLiteral.value, Uri.parse('urn:isbn:1234567890'));
          });

          test('Maps xsd:language', () {
            final uriLiteral = Literal(
              'de-DE-x-goethe',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#language'),
            );

            expect(uriLiteral.value, Locale.parse('de-DE-x-goethe'));
          });

          test('Maps xsd:normalizedString', () {
            final normalizedStringLiteral = Literal(
              'hello\t\n\rworld',
              datatypeIri: Iri(
                'http://www.w3.org/2001/XMLSchema#normalizedString',
              ),
            );

            expect(normalizedStringLiteral.value, 'hello   world');
          });

          test('Maps xsd:token', () {
            final tokenLiteral = Literal(
              '\t  hello   \n \r world  \t',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#token'),
            );

            expect(tokenLiteral.value, 'hello world');
          });

          test('Maps xsd:Name', () {
            final nameLiteral = Literal(
              '\t_val:id.Name-\n',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#Name'),
            );

            expect(nameLiteral.value, '_val:id.Name-');
          });

          test('Maps xsd:NMTOKEN', () {
            final nameLiteral = Literal(
              'עם-שלום',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#NMTOKEN'),
            );

            expect(nameLiteral.value, 'עם-שלום');
          });

          test('Maps xsd:NCName', () {
            final nameLiteral = Literal(
              'Österreich',
              datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#NCName'),
            );

            expect(nameLiteral.value, 'Österreich');
          });
        });

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
