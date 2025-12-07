import 'dart:io';

import 'package:intl/intl.dart';
import 'package:rdf_dart/src/codecs/n-triples/n_triples_codec.dart';
import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/iri.dart';
import 'package:rdf_dart/src/model/literal.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';
import 'package:test/test.dart';

void main() {
  group('W3C Test Suite', () {
    group('RDF 1.1', () {
      group('N-Triples Syntax ', () {
        group('Approved Tests', () {
          group('Positive Syntax Tests', () {
            test('Empty file', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-file-01',
                _NTriplesVersion.rdf11,
              );
              final result = nTriplesCodec.decode(inputFile);
              expect(result, hasLength(0));
            });

            test('Only comment', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-file-02',
                _NTriplesVersion.rdf11,
              );
              final result = nTriplesCodec.decode(inputFile);
              expect(result, hasLength(0));
            });

            test('One comment, one empty line', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-file-03',
                _NTriplesVersion.rdf11,
              );
              final result = nTriplesCodec.decode(inputFile);
              expect(result, hasLength(0));
            });

            test('Only IRIs', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-uri-01',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.object, Iri('http://example/o'));
              expect(decoded.first.predicate, Iri('http://example/p'));

              final encoded = nTriplesCodec.encode(decoded);
              expect(encoded, inputFile);
            });

            test('IRIs with Unicode escape', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-uri-02',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/S'));
              expect(decoded.first.object, Iri('http://example/o'));
              expect(decoded.first.predicate, Iri('http://example/p'));
            });

            test('IRIs with long Unicode escape', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-uri-03',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/S'));
              expect(decoded.first.object, Iri('http://example/o'));
              expect(decoded.first.predicate, Iri('http://example/p'));
            });

            test('Legal IRIs', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-uri-04',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(
                decoded.first.object.toString().startsWith('scheme'),
                isTrue,
              );
              expect(decoded.first.object, isA<Iri>());
            });

            test('string literal', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-string-01',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(decoded.first.object, Literal('string'));
              expect(
                (decoded.first.object as Literal),
                Iri('http://www.w3.org/2001/XMLSchema#string'),
              );

              final encoded = nTriplesCodec.encode(decoded);

              expect(encoded, inputFile);
            });

            test('langString literal', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-string-02',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(
                decoded.first.object,
                Literal(
                  'string',
                  datatypeIri: Iri(
                    'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
                  ),
                  languageTag: 'en',
                ),
              );

              final encoded = nTriplesCodec.encode(decoded);

              expect(encoded, inputFile);
            });

            test('langString literal with region', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-string-03',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(
                decoded.first.object,
                Literal(
                  'string',
                  datatypeIri: Iri(
                    'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
                  ),
                  languageTag: 'en-uk',
                ),
              );

              final encoded = nTriplesCodec.encode(decoded);

              expect(encoded, inputFile);
            });

            test('string literal with escaped newline', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-str-esc-01',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(decoded.first.object, Literal('a\n'));

              final encoded = nTriplesCodec.encode(decoded);

              expect(encoded, inputFile);
            });

            test('string literal with Unicode escape', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-str-esc-02',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(decoded.first.object, Literal('a b'));
            });

            test('string literal with long Unicode escape', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-str-esc-03',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(decoded.first.object, Literal('a b'));
            });

            test('blank node subject', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bnode-01',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, BlankNode('a'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(decoded.first.object, Iri('http://example/o'));
            });

            test('blank node object', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bnode-02',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(2));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(decoded.first.object, BlankNode('a'));

              expect(decoded.last.subject, BlankNode('a'));
              expect(decoded.last.predicate, Iri('http://example/p'));
              expect(decoded.last.object, Iri('http://example/o'));
            });

            test('Blank node labels may start with a digit', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bnode-03',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(2));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(decoded.first.object, BlankNode('1a'));

              expect(decoded.last.subject, BlankNode('1a'));
              expect(decoded.last.predicate, Iri('http://example/p'));
              expect(decoded.last.object, Iri('http://example/o'));
            });

            test('xsd:byte literal', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-datatypes-01',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(
                decoded.first.object,
                Literal(
                  '123',
                  datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#byte'),
                ),
              );

              final encoded = nTriplesCodec.encode(decoded);

              expect(encoded, inputFile);
            });

            test('integer as xsd:string', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-datatypes-02',
                _NTriplesVersion.rdf11,
              );

              final decoded = nTriplesCodec.decode(inputFile);

              expect(decoded, hasLength(1));

              expect(decoded.first.subject, Iri('http://example/s'));
              expect(decoded.first.predicate, Iri('http://example/p'));
              expect(decoded.first.object, Literal('123'));
            });

            test('Submission test from Original RDF Test Cases', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-subm-01',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test(
              "literal_all_controls '\\x00\\x01\\x02\\x03\\x04...'",
              () async {
                final inputFile = await _loadTestFile(
                  'literal_all_controls',
                  _NTriplesVersion.rdf11,
                );

                expect(
                  (() => nTriplesCodec.decode(inputFile)),
                  returnsNormally,
                );
              },
            );

            test("literal_all_punctuation '!\"#\$%&()...'", () async {
              final inputFile = await _loadTestFile(
                'literal_all_punctuation',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });
          });

          group('Negative Syntax Tests', () {
            test('Bad IRI : space', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad IRI : bad escape', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-02',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad IRI : bad long escape', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-03',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad IRI : character escapes not allowed', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-04',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad IRI : character escapes not allowed (2)', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-05',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad IRI : relative IRI not allowed in subject', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-06',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad IRI : relative IRI not allowed in predicate', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-07',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad IRI : relative IRI not allowed in object', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-08',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad IRI : relative IRI not allowed in datatype', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-uri-09',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('@prefix not allowed in n-triples', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-prefix-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('@base not allowed in N-Triples', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-base-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Colon in bnode label not allowed', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-bnode-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Colon in bnode label not allowed (2)', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-bnode-02',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('N-Triples does not have objectList', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-struct-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('N-Triples does not have predicateObjectList', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-struct-02',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('langString with bad lang', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-lang-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad string escape', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-esc-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad string escape (2)', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-esc-02',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Bad string escape (3)', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-esc-03',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('mismatching string literal open/close', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-string-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('mismatching string literal open/close (2)', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-string-02',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('single quotes', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-string-03',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('long single string literal', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-string-04',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('long double string literal', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-string-05',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('string literal with no end', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-string-06',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('string literal with no start', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-string-07',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('no numbers in N-Triples (integer)', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-num-01',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('no numbers in N-Triples (decimal)', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-num-02',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('no numbers in N-Triples (float)', () async {
              final inputFile = await _loadTestFile(
                'nt-syntax-bad-num-03',
                _NTriplesVersion.rdf11,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });
          });
        });

        group('Proposed Tests', () {
          group('Positive Syntax Tests', () {
            test('Tests comments after a triple', () async {
              final inputFile = await _loadTestFile(
                'comment_following_triple',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal_ascii_boundaries '\\x00\\x26\\x28...'", () async {
              final inputFile = await _loadTestFile(
                'literal_ascii_boundaries',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test(
              "literal_with_UTF8_boundaries '\\x80\\x7ff\\x800\\xfff...'",
              () async {
                final inputFile = await _loadTestFile(
                  'literal_with_UTF8_boundaries',
                  _NTriplesVersion.rdf11,
                );

                expect(
                  (() => nTriplesCodec.decode(inputFile)),
                  returnsNormally,
                );
              },
            );

            test("literal with squote \"x'y\"", () async {
              final inputFile = await _loadTestFile(
                'literal_with_squote',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with 2 squotes \"x''y\"", () async {
              final inputFile = await _loadTestFile(
                'literal_with_2_squotes',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal \"\"\"x\"\"\"", () async {
              final inputFile = await _loadTestFile(
                'literal',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test('literal with dquote "x"y"', () async {
              final inputFile = await _loadTestFile(
                'literal_with_dquote',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with 2 dquotes \"\"\"a\"\"b\"\"\"", () async {
              final inputFile = await _loadTestFile(
                'literal_with_2_dquotes',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("REVERSE SOLIDUS at end of literal", () async {
              final inputFile = await _loadTestFile(
                'literal_with_REVERSE_SOLIDUS2',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with CHARACTER TABULATION", () async {
              final inputFile = await _loadTestFile(
                'literal_with_CHARACTER_TABULATION',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with BACKSPACE", () async {
              final inputFile = await _loadTestFile(
                'literal_with_BACKSPACE',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with LINE FEED", () async {
              final inputFile = await _loadTestFile(
                'literal_with_LINE_FEED',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with CARRIAGE RETURN", () async {
              final inputFile = await _loadTestFile(
                'literal_with_CARRIAGE_RETURN',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with FORM FEED", () async {
              final inputFile = await _loadTestFile(
                'literal_with_FORM_FEED',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with REVERSE SOLIDUS", () async {
              final inputFile = await _loadTestFile(
                'literal_with_REVERSE_SOLIDUS',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with numeric escape4 \\u", () async {
              final inputFile = await _loadTestFile(
                'literal_with_numeric_escape4',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("literal with numeric escape8 \\U", () async {
              final inputFile = await _loadTestFile(
                'literal_with_numeric_escape8',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("langtagged string \"x\"@en", () async {
              final inputFile = await _loadTestFile(
                'langtagged_string',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test("lantag with subtag \"x\"@en-us", () async {
              final inputFile = await _loadTestFile(
                'lantag_with_subtag',
                _NTriplesVersion.rdf11,
              );

              expect((() => nTriplesCodec.decode(inputFile)), returnsNormally);
            });

            test(
              "tests absense of whitespace between subject, predicate, object and end-of-statement",
              () async {
                final inputFile = await _loadTestFile(
                  'minimal_whitespace',
                  _NTriplesVersion.rdf11,
                );

                expect(
                  (() => nTriplesCodec.decode(inputFile)),
                  returnsNormally,
                );
              },
            );
          });
        });
      });
    });
    group('RDF 1.2', () {
      group('N-Triples Syntax ', () {
        group('Approved Tests', () {
          group('Positive Syntax Tests', () {
            test('object triple term', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-syntax-01',
                _NTriplesVersion.rdf12,
              );

              final result = nTriplesCodec.decode(inputFile);

              expect(result, hasLength(1));
              expect(result.first.subject, Iri('http://example/a'));
              expect(
                result.first.predicate,
                Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies'),
              );
              expect(
                result.first.object,
                TripleTerm(
                  Triple(
                    subject: Iri('http://example/s'),
                    predicate: Iri('http://example/p'),
                    object: Iri('http://example/o'),
                  ),
                ),
              );
            });

            test('object triple term, no whitespace', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-syntax-02',
                _NTriplesVersion.rdf12,
              );

              final result = nTriplesCodec.decode(inputFile);

              expect(result, hasLength(1));
              expect(result.first.subject, Iri('http://example/s'));
              expect(
                result.first.predicate,
                Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies'),
              );
              expect(
                result.first.object,
                TripleTerm(
                  Triple(
                    subject: Iri('http://example/s2'),
                    predicate: Iri('http://example/p2'),
                    object: Iri('http://example/o2'),
                  ),
                ),
              );
            });

            test('Nested, no whitespace', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-syntax-03',
                _NTriplesVersion.rdf12,
              );

              final result = nTriplesCodec.decode(inputFile);

              expect(result, hasLength(1));
              expect(result.first.subject, Iri('http://example/s'));
              expect(
                result.first.predicate,
                Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies'),
              );
              expect(
                result.first.object,
                TripleTerm(
                  Triple(
                    subject: Iri('http://example/s2'),
                    predicate: Iri('http://example/q2'),
                    object: TripleTerm(
                      Triple(
                        subject: Iri('http://example/s3'),
                        predicate: Iri('http://example/p2'),
                        object: Iri('http://example/o3'),
                      ),
                    ),
                  ),
                ),
              );
            });

            test('Blank node subject', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bnode-1',
                _NTriplesVersion.rdf12,
              );
              final result = nTriplesCodec.decode(inputFile);

              expect(result, hasLength(2));

              expect(
                result.first,
                Triple(
                  subject: BlankNode('b0'),
                  predicate: Iri('http://example/p'),
                  object: Iri('http://example/o'),
                ),
              );

              expect(result.last.subject, BlankNode('b0'));
              expect(
                result.last.predicate,
                Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies'),
              );
              expect(
                result.last.object,
                TripleTerm(
                  Triple(
                    subject: BlankNode('b0'),
                    predicate: Iri('http://example/p'),
                    object: Iri('http://example/o'),
                  ),
                ),
              );
            });

            test('N-Triples-12 - Nested object term', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-nested-1',
                _NTriplesVersion.rdf12,
              );
              final result = nTriplesCodec.decode(inputFile);

              expect(result, hasLength(3));

              expect(result, <Triple>{
                Triple(
                  subject: Iri('http://example/s'),
                  predicate: Iri('http://example/p'),
                  object: Iri('http://example/o'),
                ),
                Triple(
                  subject: Iri('http://example/a'),
                  predicate: Iri(
                    'http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies',
                  ),
                  object: TripleTerm(
                    Triple(
                      subject: Iri('http://example/s1'),
                      predicate: Iri('http://example/p1'),
                      object: Iri('http://example/o1'),
                    ),
                  ),
                ),
                Triple(
                  subject: Iri('http://example/r'),
                  predicate: Iri(
                    'http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies',
                  ),
                  object: TripleTerm(
                    Triple(
                      subject: Iri('http://example/23'),
                      predicate: Iri(
                        'http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies',
                      ),
                      object: TripleTerm(
                        Triple(
                          subject: Iri('http://example/s3'),
                          predicate: Iri('http://example/p3'),
                          object: Iri('http://example/o3'),
                        ),
                      ),
                    ),
                  ),
                ),
              });
            });

            test('N-Triples literal with base direction ltr', () async {
              final inputFile = await _loadTestFile(
                'ntriples-langdir-1',
                _NTriplesVersion.rdf12,
              );

              final result = nTriplesCodec.decode(inputFile);

              expect(result, hasLength(1));
              expect(
                result.first,
                Triple(
                  subject: Iri('http://example/a'),
                  predicate: Iri('http://example/b'),
                  object: Literal(
                    'Hello',
                    datatypeIri: Iri(
                      'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString',
                    ),
                    baseDirection: TextDirection.LTR,
                    languageTag: 'en',
                  ),
                ),
              );
            });

            test('N-Triples literal with base direction rtl', () async {
              final inputFile = await _loadTestFile(
                '<ntriples-langdir-2',
                _NTriplesVersion.rdf12,
              );

              final result = nTriplesCodec.decode(inputFile);

              expect(result, hasLength(1));
              expect(
                result.first,
                Triple(
                  subject: Iri('http://example/a'),
                  predicate: Iri('http://example/b'),
                  object: Literal(
                    'Hello',
                    datatypeIri: Iri(
                      'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString',
                    ),
                    baseDirection: TextDirection.RTL,
                    languageTag: 'en',
                  ),
                ),
              );
            });
          });

          group('Negative Syntax Tests', () {
            test('reified triple as predicate', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-01',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('reified triple, literal subject', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-02',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('reified triple, literal predicate', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-03',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('reified triple, blank node predicate', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-04',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('triple term as predicate', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-05',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('triple term, literal subject', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-06',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('triple term, literal predicate', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-07',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('triple term, blank node predicate', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-08',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('reified triple object', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-09',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('triple term as subject', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-syntax-10',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('invalid IRI', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-iri-1',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('subject reified triple', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-reified-syntax-1',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('object reified triple', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-reified-syntax-2',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('object reified triples', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-reified-syntax-3',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('predicate reified triple', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bad-reified-syntax-4',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('annotated triple, blank node subject', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bnode-bad-annotated-syntax-1',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('annotated triple, blank node object', () async {
              final inputFile = await _loadTestFile(
                'ntriples12-bnode-bad-annotated-syntax-2',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('undefined base direction', () async {
              final inputFile = await _loadTestFile(
                'ntriples-langdir-bad-1',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('upper case LTR', () async {
              final inputFile = await _loadTestFile(
                'ntriples-langdir-bad-2',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('literal with missing language tag', () async {
              final inputFile = await _loadTestFile(
                'ntriples-langdir-bad-3',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('literal with bad language tag', () async {
              final inputFile = await _loadTestFile(
                'ntriples-langdir-bad-4',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });

            test('literal with missing language tag and direction', () async {
              final inputFile = await _loadTestFile(
                'ntriples-langdir-bad-5',
                _NTriplesVersion.rdf12,
              );

              expect(
                (() => nTriplesCodec.decode(inputFile)),
                throwsA(isA<FormatException>()),
              );
            });
          });
        });
      });
    });
  });
}

enum _NTriplesVersion { rdf11, rdf12 }

/// Helper method that takes in a filename and loads the appropriate test file
/// and returns it as a String for input to the codec.
Future<String> _loadTestFile(String fileName, _NTriplesVersion version) async {
  if (version == _NTriplesVersion.rdf11) {
    final bytes = await File(
      'test/codec/n_triples/w3c/rdf11/rdf-n-triples/$fileName.nt',
    ).readAsString();
    return bytes;
  } else {
    final bytes = await File(
      'test/codec/n_triples/w3c/rdf12/rdf-n-triples/syntax/$fileName.nt',
    ).readAsString();
    return bytes;
  }
}
