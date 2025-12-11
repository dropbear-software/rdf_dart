import 'dart:io';

import 'package:test/test.dart';
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  group('W3C Test Suite', () {
    group('RDF 1.2', () {
      // All the test case files are loaded from this directory
      const testFilePath = 'test/codec/turtle/w3c/rdf12/syntax';
      group('Turtle Syntax', () {
        group('Positive Syntax Tests', () {
          test('N-Triples 1.2 as Turtle 1.2 - triple term', () async {
            final actionContent = await File(
              '$testFilePath/nt-ttl12-syntax-1.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:nt-ttl12-1',
              name: 'N-Triples 1.2 as Turtle 1.2 - triple term',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('N-Triples 1.2 as Turtle 1.2 - whitespace and terms', () async {
            final actionContent = await File(
              '$testFilePath/nt-ttl12-syntax-2.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:nt-ttl12-2',
              name: 'N-Triples 1.2 as Turtle 1.2 - whitespace and terms',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('N-Triples 1.2 as Turtle 1.2 - Nested, no whitespace', () async {
            final actionContent = await File(
              '$testFilePath/nt-ttl12-syntax-3.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:nt-ttl12-3',
              name: 'N-Triples 1.2 as Turtle 1.2 - Nested, no whitespace',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('N-Triples 1.2 as Turtle 1.2 - Blank node object', () async {
            final actionContent = await File(
              '$testFilePath/nt-ttl12-bnode-1.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:nt-ttl12-bnode-1',
              name: 'N-Triples 1.2 as Turtle 1.2 - Blank node object',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('N-Triples 1.2 as Turtle 1.2 - base direction ltr', () async {
            final actionContent = await File(
              '$testFilePath/nt-ttl12-langdir-1.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:nt-ttl12-langdir-1',
              name: 'N-Triples 1.2 as Turtle 1.2 - base direction ltr',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('N-Triples 1.2 as Turtle 1.2 - base direction ltr', () async {
            final actionContent = await File(
              '$testFilePath/nt-ttl12-langdir-2.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:nt-ttl12-langdir-2',
              name: 'N-Triples 1.2 as Turtle 1.2 - base direction ltr',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('N-Triples 1.2 as Turtle 1.2 - Nested subject term', () async {
            final actionContent = await File(
              '$testFilePath/nt-ttl12-nested-1.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:nt-ttl12-nested-1',
              name: 'N-Triples 1.2 as Turtle 1.2 - Nested subject term',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - subject reified triple', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-basic-01.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-1',
              name: 'Turtle 1.2 - subject reified triple',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - object reified triple', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-basic-02.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-2',
              name: 'Turtle 1.2 - object reified triple',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - triple term object', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-basic-03.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-3',
              name: 'Turtle 1.2 - triple term object',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - reified triple outside triple', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-basic-04.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-4',
              name: 'Turtle 1.2 - reified triple outside triple',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - Annotation form', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-annotation-1.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-ann-1',
              name: 'Turtle 1.2 - Annotation form',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - Annotation example', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-annotation-2.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-ann-2',
              name: 'Turtle 1.2 - Annotation example',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - Annotation predicateObjecetList', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-annotation-3.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-ann-3',
              name: 'Turtle 1.2 - Annotation predicateObjecetList',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test(
            'Turtle 1.2 - Annotation followed by predicate/object',
            () async {
              final actionContent = await File(
                '$testFilePath/turtle12-annotation-4.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:turtle12-ann-4',
                name: 'Turtle 1.2 - Annotation followed by predicate/object',
                type: 'PositiveSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                returnsNormally,
              );
            },
          );
          test('Turtle 1.2 - Reifier without annotation block', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-annotation-5.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-ann-5',
              name: 'Turtle 1.2 - Reifier without annotation block',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - Empty reifier without annotation block', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-annotation-6.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-ann-6',
              name: 'Turtle 1.2 - Empty reifier without annotation block',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - Reifier with annotation block', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-annotation-7.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-ann-7',
              name: 'Turtle 1.2 - Reifier with annotation block',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - Empty reifier with annotation block', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-annotation-8.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-ann-8',
              name: 'Turtle 1.2 - Empty reifier with annotation block',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - blank node subject', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bnode-01.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bnode-1',
              name: 'Turtle 1.2 - blank node subject',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - blank node object', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bnode-02.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bnode-2',
              name: 'Turtle 1.2 - blank node object',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - blank node', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bnode-03.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bnode-3',
              name: 'Turtle 1.2 - blank node',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - compound forms', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-compound.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-compound-1',
              name: 'Turtle 1.2 - compound forms',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test(
            'Turtle 1.2 - reified triple inside blankNodePropertyList',
            () async {
              final actionContent = await File(
                '$testFilePath/turtle12-syntax-inside-01.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:turtle12-inside-1',
                name:
                    'Turtle 1.2 - reified triple inside blankNodePropertyList',
                type: 'PositiveSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                returnsNormally,
              );
            },
          );
          test('Turtle 1.2 - reified triple inside collection', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-inside-02.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-inside-2',
              name: 'Turtle 1.2 - reified triple inside collection',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - reified triple with IRI identifier', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-inside-03.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-inside-3',
              name: 'Turtle 1.2 - reified triple with IRI identifier',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test(
            'Turtle 1.2 - reified triple with blank node identifier',
            () async {
              final actionContent = await File(
                '$testFilePath/turtle12-syntax-inside-04.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:turtle12-inside-4',
                name: 'Turtle 1.2 - reified triple with blank node identifier',
                type: 'PositiveSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                returnsNormally,
              );
            },
          );
          test(
            'Turtle 1.2 - nested reified triple, subject position',
            () async {
              final actionContent = await File(
                '$testFilePath/turtle12-syntax-nested-01.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:turtle12-nested-1',
                name: 'Turtle 1.2 - nested reified triple, subject position',
                type: 'PositiveSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                returnsNormally,
              );
            },
          );
          test('Turtle 1.2 - nested reified triple, object position', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-nested-02.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-nested-2',
              name: 'Turtle 1.2 - nested reified triple, object position',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - VERSION', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-01.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-01',
              name: 'Turtle 1.2 - VERSION',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - @version', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-02.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-02',
              name: 'Turtle 1.2 - @version',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - VERSION in data ', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-03.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-03',
              name: 'Turtle 1.2 - VERSION in data ',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - @version in data', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-04.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-04',
              name: 'Turtle 1.2 - @version in data',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - VERSION other version string', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-05.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-05',
              name: 'Turtle 1.2 - VERSION other version string',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - @version other version string', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-06.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-06',
              name: 'Turtle 1.2 - @version other version string',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - mixed versions', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-07.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-07',
              name: 'Turtle 1.2 - mixed versions',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
          test('Turtle 1.2 - many versions', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-08.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-08',
              name: 'Turtle 1.2 - many versions',
              type: 'PositiveSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              returnsNormally,
            );
          });
        });
        group('Negative Syntax Tests', () {
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - triple term as predicate',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-01.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-01',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - triple term as predicate',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - triple term, literal subject',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-02.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-02',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - triple term, literal subject',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - triple term, literal predicate',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-03.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-03',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - triple term, literal predicate',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - triple term, blank node predicate',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-04.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-04',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - triple term, blank node predicate',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - triple term as subject',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-05.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-05',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - triple term as subject',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - reified triple as predicate',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-06.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-06',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - reified triple as predicate',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - reified triple, literal subject',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-07.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-07',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - reified triple, literal subject',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - reified triple, literal predicate',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-08.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-08',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - reified triple, literal predicate',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - Bad - reified triple, blank node predicate',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-bad-syntax-09.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-bad-09',
                name:
                    'N-Triples 1.2 as Turtle 1.2 - Bad - reified triple, blank node predicate',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'N-Triples 1.2 as Turtle 1.2 - undefined base direction',
            () async {
              final actionContent = await File(
                '$testFilePath/nt-ttl12-langdir-bad-1.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:nt-ttl12-langdir-bad-1',
                name: 'N-Triples 1.2 as Turtle 1.2 - undefined base direction',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test('N-Triples 1.2 as Turtle 1.2 - upper case LTR', () async {
            final actionContent = await File(
              '$testFilePath/nt-ttl12-langdir-bad-2.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:nt-ttl12-langdir-bad-2',
              name: 'N-Triples 1.2 as Turtle 1.2 - upper case LTR',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - bad - reified triple as predicate', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bad-01.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bad-1',
              name: 'Turtle 1.2 - bad - reified triple as predicate',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test(
            'Turtle 1.2 - bad - literal in subject position of reified triple',
            () async {
              final actionContent = await File(
                '$testFilePath/turtle12-syntax-bad-02.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:turtle12-bad-2',
                name:
                    'Turtle 1.2 - bad - literal in subject position of reified triple',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test(
            'Turtle 1.2 - bad - blank node  as predicate in reified triple',
            () async {
              final actionContent = await File(
                '$testFilePath/turtle12-syntax-bad-03.ttl',
              ).readAsString();

              final testData = (
                id: 'trs:turtle12-bad-3',
                name:
                    'Turtle 1.2 - bad - blank node  as predicate in reified triple',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            },
          );
          test('Turtle 1.2 - bad - incomplete reified triple', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bad-04.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bad-4',
              name: 'Turtle 1.2 - bad - incomplete reified triple',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - bad - over-long reified triple', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bad-05.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bad-5',
              name: 'Turtle 1.2 - bad - over-long reified triple',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - bad - reified with list object', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bad-06.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bad-6',
              name: 'Turtle 1.2 - bad - reified with list object',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - bad - compound blank node expression', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bad-07.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bad-7',
              name: 'Turtle 1.2 - bad - compound blank node expression',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - bad - empty annotation', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bad-ann-1.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bad-ann-1',
              name: 'Turtle 1.2 - bad - empty annotation',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - bad - triple as annotation', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-syntax-bad-ann-2.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-bad-ann-2',
              name: 'Turtle 1.2 - bad - triple as annotation',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - VERSION - not string', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-bad-01.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-bad-01',
              name: 'Turtle 1.2 - VERSION - not string',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - VERSION - triple-\'-quoted string', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-bad-02.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-bad-02',
              name: 'Turtle 1.2 - VERSION - triple-\'-quoted string',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - VERSION - triple-"-quoted string', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-bad-03.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-bad-03',
              name: 'Turtle 1.2 - VERSION - triple-"-quoted string',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - @version - not string', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-bad-04.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-bad-04',
              name: 'Turtle 1.2 - @version - not string',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - @version - triple-\'-quoted string', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-bad-05.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-bad-05',
              name: 'Turtle 1.2 - @version - triple-\'-quoted string',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
          test('Turtle 1.2 - @version - triple-"-quoted string', () async {
            final actionContent = await File(
              '$testFilePath/turtle12-version-bad-06.ttl',
            ).readAsString();

            final testData = (
              id: 'trs:turtle12-version-bad-06',
              name: 'Turtle 1.2 - @version - triple-"-quoted string',
              type: 'NegativeSyntaxTest',
              action: actionContent,
            );

            expect(
              (() => turtleCodec.decode(testData.action)),
              throwsA(isA<FormatException>()),
            );
          });
        });
      });
    });
  });
}
