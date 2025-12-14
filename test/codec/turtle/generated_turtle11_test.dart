import 'dart:io';

import 'package:test/test.dart';
import 'package:rdf_dart/src/codecs/turtle/turtle_decoder.dart';
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  group('W3C Test Suite', () {
    group('RDF 1.1', () {
      // All the test case files are loaded from this directory
      const testFilePath = 'test/codec/turtle/w3c/rdf11';
      group('Turtle Syntax ', () {
        group('Approved Tests', () {
          group('Positive Syntax Tests', () {
            test('HYPHEN_MINUS_in_localName', () async {
              final actionContent = await File(
                '$testFilePath/HYPHEN_MINUS_in_localName.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/HYPHEN_MINUS_in_localName.nt',
              ).readAsString();

              final testData = (
                id: '#HYPHEN_MINUS_in_localName',
                comment: 'HYPHEN-MINUS in local name',
                name: 'HYPHEN_MINUS_in_localName',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('IRIREF_datatype', () async {
              final actionContent = await File(
                '$testFilePath/IRIREF_datatype.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRIREF_datatype.nt',
              ).readAsString();

              final testData = (
                id: '#IRIREF_datatype',
                comment: 'IRIREF datatype ""^^<t>',
                name: 'IRIREF_datatype',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('IRI_subject', () async {
              final actionContent = await File(
                '$testFilePath/IRI_subject.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#IRI_subject',
                comment: 'IRI subject',
                name: 'IRI_subject',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('IRI_with_all_punctuation', () async {
              final actionContent = await File(
                '$testFilePath/IRI_with_all_punctuation.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_with_all_punctuation.nt',
              ).readAsString();

              final testData = (
                id: '#IRI_with_all_punctuation',
                comment: 'IRI with all punctuation',
                name: 'IRI_with_all_punctuation',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('IRI_with_eight_digit_numeric_escape', () async {
              final actionContent = await File(
                '$testFilePath/IRI_with_eight_digit_numeric_escape.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#IRI_with_eight_digit_numeric_escape',
                comment: 'IRI with eight digit numeric escape (\\U)',
                name: 'IRI_with_eight_digit_numeric_escape',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('IRI_with_four_digit_numeric_escape', () async {
              final actionContent = await File(
                '$testFilePath/IRI_with_four_digit_numeric_escape.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#IRI_with_four_digit_numeric_escape',
                comment: 'IRI with four digit numeric escape (\\u)',
                name: 'IRI_with_four_digit_numeric_escape',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL1', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL1.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL1.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL1',
                comment: 'LITERAL1 \'x\'',
                name: 'LITERAL1',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL1_all_controls', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL1_all_controls.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL1_all_controls.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL1_all_controls',
                comment: 'LITERAL1_all_controls \'\x00\x01\x02\x03\x04...\'',
                name: 'LITERAL1_all_controls',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL1_all_punctuation', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL1_all_punctuation.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL1_all_punctuation.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL1_all_punctuation',
                comment: 'LITERAL1_all_punctuation \'!"#\$%&()...\'',
                name: 'LITERAL1_all_punctuation',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL1_ascii_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL1_ascii_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL1_ascii_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL1_ascii_boundaries',
                comment:
                    'LITERAL1_ascii_boundaries \'\x00\x09\x0b\x0c\x0e\x26\x28...\'',
                name: 'LITERAL1_ascii_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL1_with_UTF8_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL1_with_UTF8_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_with_UTF8_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL1_with_UTF8_boundaries',
                comment:
                    'LITERAL1_with_UTF8_boundaries \'\x80\x7ff\x800\xfff...\'',
                name: 'LITERAL1_with_UTF8_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL2', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL2.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL1.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL2',
                comment: 'LITERAL2 "x"',
                name: 'LITERAL2',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL2_ascii_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL2_ascii_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL2_ascii_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL2_ascii_boundaries',
                comment:
                    'LITERAL2_ascii_boundaries \'\x00\x09\x0b\x0c\x0e\x21\x23...\'',
                name: 'LITERAL2_ascii_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL2_with_UTF8_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL2_with_UTF8_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_with_UTF8_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL2_with_UTF8_boundaries',
                comment:
                    'LITERAL2_with_UTF8_boundaries \'\x80\x7ff\x800\xfff...\'',
                name: 'LITERAL2_with_UTF8_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG1', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG1.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL1.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG1',
                comment: 'LITERAL_LONG1 \'\'\'x\'\'\'',
                name: 'LITERAL_LONG1',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG1_ascii_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG1_ascii_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_LONG1_ascii_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG1_ascii_boundaries',
                comment: 'LITERAL_LONG1_ascii_boundaries \'\x00\x26\x28...\'',
                name: 'LITERAL_LONG1_ascii_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG1_with_1_squote', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG1_with_1_squote.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_LONG1_with_1_squote.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG1_with_1_squote',
                comment: 'LITERAL_LONG1 with 1 squote \'\'\'a\'b\'\'\'',
                name: 'LITERAL_LONG1_with_1_squote',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG1_with_2_squotes', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG1_with_2_squotes.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_LONG1_with_2_squotes.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG1_with_2_squotes',
                comment: 'LITERAL_LONG1 with 2 squotes \'\'\'a\'\'b\'\'\'',
                name: 'LITERAL_LONG1_with_2_squotes',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG1_with_UTF8_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG1_with_UTF8_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_with_UTF8_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG1_with_UTF8_boundaries',
                comment:
                    'LITERAL_LONG1_with_UTF8_boundaries \'\x80\x7ff\x800\xfff...\'',
                name: 'LITERAL_LONG1_with_UTF8_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG2', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG2.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL1.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG2',
                comment: 'LITERAL_LONG2 """x"""',
                name: 'LITERAL_LONG2',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG2_ascii_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG2_ascii_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_LONG2_ascii_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG2_ascii_boundaries',
                comment: 'LITERAL_LONG2_ascii_boundaries \'\x00\x21\x23...\'',
                name: 'LITERAL_LONG2_ascii_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG2_with_1_squote', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG2_with_1_squote.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_LONG2_with_1_squote.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG2_with_1_squote',
                comment: 'LITERAL_LONG2 with 1 squote """a"b"""',
                name: 'LITERAL_LONG2_with_1_squote',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG2_with_2_squotes', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG2_with_2_squotes.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_LONG2_with_2_squotes.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG2_with_2_squotes',
                comment: 'LITERAL_LONG2 with 2 squotes """a""b"""',
                name: 'LITERAL_LONG2_with_2_squotes',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG2_with_REVERSE_SOLIDUS', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG2_with_REVERSE_SOLIDUS.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_LONG2_with_REVERSE_SOLIDUS.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG2_with_REVERSE_SOLIDUS',
                comment: 'REVERSE SOLIDUS at end of LITERAL_LONG2',
                name: 'LITERAL_LONG2_with_REVERSE_SOLIDUS',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('LITERAL_LONG2_with_UTF8_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/LITERAL_LONG2_with_UTF8_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/LITERAL_with_UTF8_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#LITERAL_LONG2_with_UTF8_boundaries',
                comment:
                    'LITERAL_LONG2_with_UTF8_boundaries \'\x80\x7ff\x800\xfff...\'',
                name: 'LITERAL_LONG2_with_UTF8_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('SPARQL_style_base', () async {
              final actionContent = await File(
                '$testFilePath/SPARQL_style_base.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#SPARQL_style_base',
                comment: 'SPARQL-style base',
                name: 'SPARQL_style_base',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('SPARQL_style_prefix', () async {
              final actionContent = await File(
                '$testFilePath/SPARQL_style_prefix.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#SPARQL_style_prefix',
                comment: 'SPARQL-style prefix',
                name: 'SPARQL_style_prefix',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('anonymous_blank_node_object', () async {
              final actionContent = await File(
                '$testFilePath/anonymous_blank_node_object.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/labeled_blank_node_object.nt',
              ).readAsString();

              final testData = (
                id: '#anonymous_blank_node_object',
                comment: 'anonymous blank node object',
                name: 'anonymous_blank_node_object',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('anonymous_blank_node_subject', () async {
              final actionContent = await File(
                '$testFilePath/anonymous_blank_node_subject.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/labeled_blank_node_subject.nt',
              ).readAsString();

              final testData = (
                id: '#anonymous_blank_node_subject',
                comment: 'anonymous blank node subject',
                name: 'anonymous_blank_node_subject',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('bareword_a_predicate', () async {
              final actionContent = await File(
                '$testFilePath/bareword_a_predicate.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/bareword_a_predicate.nt',
              ).readAsString();

              final testData = (
                id: '#bareword_a_predicate',
                comment: 'bareword a predicate',
                name: 'bareword_a_predicate',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('bareword_decimal', () async {
              final actionContent = await File(
                '$testFilePath/bareword_decimal.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/bareword_decimal.nt',
              ).readAsString();

              final testData = (
                id: '#bareword_decimal',
                comment: 'bareword decimal',
                name: 'bareword_decimal',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('bareword_double', () async {
              final actionContent = await File(
                '$testFilePath/bareword_double.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/bareword_double.nt',
              ).readAsString();

              final testData = (
                id: '#bareword_double',
                comment: 'bareword double',
                name: 'bareword_double',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('bareword_integer', () async {
              final actionContent = await File(
                '$testFilePath/bareword_integer.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRIREF_datatype.nt',
              ).readAsString();

              final testData = (
                id: '#bareword_integer',
                comment: 'bareword integer',
                name: 'bareword_integer',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('blankNodePropertyList_as_object', () async {
              final actionContent = await File(
                '$testFilePath/blankNodePropertyList_as_object.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/blankNodePropertyList_as_object.nt',
              ).readAsString();

              final testData = (
                id: '#blankNodePropertyList_as_object',
                comment: 'blankNodePropertyList as object <s> <p> [ … ] .',
                name: 'blankNodePropertyList_as_object',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('blankNodePropertyList_as_object_containing_objectList', () async {
              final actionContent = await File(
                '$testFilePath/blankNodePropertyList_as_object_containing_objectList.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/blankNodePropertyList_as_object_containing_objectList.nt',
              ).readAsString();

              final testData = (
                id: '#blankNodePropertyList_as_object_containing_objectList',
                comment:
                    'blankNodePropertyList as object containing objectList <s> <p> [ <p2> <o>,<o2> ] .',
                name: 'blankNodePropertyList_as_object_containing_objectList',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test(
              'blankNodePropertyList_as_object_containing_objectList_of_two_objects',
              () async {
                final actionContent = await File(
                  '$testFilePath/blankNodePropertyList_as_object_containing_objectList_of_two_objects.ttl',
                ).readAsString();
                final resultContent = await File(
                  '$testFilePath/blankNodePropertyList_as_object_containing_objectList_of_two_objects.nt',
                ).readAsString();

                final testData = (
                  id: '#blankNodePropertyList_as_object_containing_objectList_of_two_objects',
                  comment:
                      'blankNodePropertyList as object containing objectList of two objects <s> <p> [ <p2 <o> ] , <o2> .',
                  name:
                      'blankNodePropertyList_as_object_containing_objectList_of_two_objects',
                  type: 'PositiveSyntaxTest',
                  action: actionContent,
                  result: resultContent,
                );

                final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
                final nTriples = nTriplesCodec.decode(testData.result);
                final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
                final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
                expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
              },
            );

            test('blankNodePropertyList_as_subject', () async {
              final actionContent = await File(
                '$testFilePath/blankNodePropertyList_as_subject.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/blankNodePropertyList_as_subject.nt',
              ).readAsString();

              final testData = (
                id: '#blankNodePropertyList_as_subject',
                comment: 'blankNodePropertyList as subject [ … ] <p> <o> .',
                name: 'blankNodePropertyList_as_subject',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('blankNodePropertyList_containing_collection', () async {
              final actionContent = await File(
                '$testFilePath/blankNodePropertyList_containing_collection.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/blankNodePropertyList_containing_collection.nt',
              ).readAsString();

              final testData = (
                id: '#blankNodePropertyList_containing_collection',
                comment:
                    'blankNodePropertyList containing collection [ <p1> ( … ) ]',
                name: 'blankNodePropertyList_containing_collection',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('blankNodePropertyList_with_multiple_triples', () async {
              final actionContent = await File(
                '$testFilePath/blankNodePropertyList_with_multiple_triples.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/blankNodePropertyList_with_multiple_triples.nt',
              ).readAsString();

              final testData = (
                id: '#blankNodePropertyList_with_multiple_triples',
                comment:
                    'blankNodePropertyList with multiple triples [ <s> <p> ; <s2> <p2> ]',
                name: 'blankNodePropertyList_with_multiple_triples',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('collection_object', () async {
              final actionContent = await File(
                '$testFilePath/collection_object.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/collection_object.nt',
              ).readAsString();

              final testData = (
                id: '#collection_object',
                comment: 'collection object',
                name: 'collection_object',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('collection_subject', () async {
              final actionContent = await File(
                '$testFilePath/collection_subject.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/collection_subject.nt',
              ).readAsString();

              final testData = (
                id: '#collection_subject',
                comment: 'collection subject',
                name: 'collection_subject',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('default_namespace_IRI', () async {
              final actionContent = await File(
                '$testFilePath/default_namespace_IRI.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#default_namespace_IRI',
                comment: 'default namespace IRI (:ln)',
                name: 'default_namespace_IRI',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('double_lower_case_e', () async {
              final actionContent = await File(
                '$testFilePath/double_lower_case_e.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/double_lower_case_e.nt',
              ).readAsString();

              final testData = (
                id: '#double_lower_case_e',
                comment: 'double lower case e',
                name: 'double_lower_case_e',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('empty_collection', () async {
              final actionContent = await File(
                '$testFilePath/empty_collection.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/empty_collection.nt',
              ).readAsString();

              final testData = (
                id: '#empty_collection',
                comment: 'empty collection ()',
                name: 'empty_collection',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('first', () async {
              final actionContent = await File(
                '$testFilePath/first.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/first.nt',
              ).readAsString();

              final testData = (
                id: '#first',
                comment: 'first, not last, non-empty nested collection',
                name: 'first',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('labeled_blank_node_object', () async {
              final actionContent = await File(
                '$testFilePath/labeled_blank_node_object.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/labeled_blank_node_object.nt',
              ).readAsString();

              final testData = (
                id: '#labeled_blank_node_object',
                comment: 'labeled blank node object',
                name: 'labeled_blank_node_object',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('labeled_blank_node_subject', () async {
              final actionContent = await File(
                '$testFilePath/labeled_blank_node_subject.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/labeled_blank_node_subject.nt',
              ).readAsString();

              final testData = (
                id: '#labeled_blank_node_subject',
                comment: 'labeled blank node subject',
                name: 'labeled_blank_node_subject',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test(
              'labeled_blank_node_with_PN_CHARS_BASE_character_boundaries',
              () async {
                final actionContent = await File(
                  '$testFilePath/labeled_blank_node_with_PN_CHARS_BASE_character_boundaries.ttl',
                ).readAsString();
                final resultContent = await File(
                  '$testFilePath/labeled_blank_node_object.nt',
                ).readAsString();

                final testData = (
                  id: '#labeled_blank_node_with_PN_CHARS_BASE_character_boundaries',
                  comment:
                      'labeled blank node with PN_CHARS_BASE character boundaries (_:AZazÀÖØöø...)',
                  name:
                      'labeled_blank_node_with_PN_CHARS_BASE_character_boundaries',
                  type: 'PositiveSyntaxTest',
                  action: actionContent,
                  result: resultContent,
                );

                final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
                final nTriples = nTriplesCodec.decode(testData.result);
                final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
                final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
                expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
              },
            );

            test('labeled_blank_node_with_leading_digit', () async {
              final actionContent = await File(
                '$testFilePath/labeled_blank_node_with_leading_digit.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/labeled_blank_node_object.nt',
              ).readAsString();

              final testData = (
                id: '#labeled_blank_node_with_leading_digit',
                comment: 'labeled blank node with_leading_digit (_:0)',
                name: 'labeled_blank_node_with_leading_digit',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('labeled_blank_node_with_leading_underscore', () async {
              final actionContent = await File(
                '$testFilePath/labeled_blank_node_with_leading_underscore.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/labeled_blank_node_object.nt',
              ).readAsString();

              final testData = (
                id: '#labeled_blank_node_with_leading_underscore',
                comment: 'labeled blank node with_leading_underscore (_:_)',
                name: 'labeled_blank_node_with_leading_underscore',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('labeled_blank_node_with_non_leading_extras', () async {
              final actionContent = await File(
                '$testFilePath/labeled_blank_node_with_non_leading_extras.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/labeled_blank_node_object.nt',
              ).readAsString();

              final testData = (
                id: '#labeled_blank_node_with_non_leading_extras',
                comment:
                    'labeled blank node with_non_leading_extras (_:a·̀ͯ‿.⁀)',
                name: 'labeled_blank_node_with_non_leading_extras',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('langtagged_LONG', () async {
              final actionContent = await File(
                '$testFilePath/langtagged_LONG.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/langtagged_non_LONG.nt',
              ).readAsString();

              final testData = (
                id: '#langtagged_LONG',
                comment: 'langtagged LONG """x"""@en',
                name: 'langtagged_LONG',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('langtagged_LONG_with_subtag', () async {
              final actionContent = await File(
                '$testFilePath/langtagged_LONG_with_subtag.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/langtagged_LONG_with_subtag.nt',
              ).readAsString();

              final testData = (
                id: '#langtagged_LONG_with_subtag',
                comment: 'langtagged LONG with subtag """Cheers"""@en-UK',
                name: 'langtagged_LONG_with_subtag',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('langtagged_non_LONG', () async {
              final actionContent = await File(
                '$testFilePath/langtagged_non_LONG.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/langtagged_non_LONG.nt',
              ).readAsString();

              final testData = (
                id: '#langtagged_non_LONG',
                comment: 'langtagged non-LONG "x"@en',
                name: 'langtagged_non_LONG',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('lantag_with_subtag', () async {
              final actionContent = await File(
                '$testFilePath/lantag_with_subtag.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/lantag_with_subtag.nt',
              ).readAsString();

              final testData = (
                id: '#lantag_with_subtag',
                comment: 'lantag with subtag "x"@en-us',
                name: 'lantag_with_subtag',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('last', () async {
              final actionContent = await File(
                '$testFilePath/last.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/last.nt',
              ).readAsString();

              final testData = (
                id: '#last',
                comment: 'last, not first, non-empty nested collection',
                name: 'last',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_false', () async {
              final actionContent = await File(
                '$testFilePath/literal_false.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_false.nt',
              ).readAsString();

              final testData = (
                id: '#literal_false',
                comment: 'literal false',
                name: 'literal_false',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_true', () async {
              final actionContent = await File(
                '$testFilePath/literal_true.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_true.nt',
              ).readAsString();

              final testData = (
                id: '#literal_true',
                comment: 'literal true',
                name: 'literal_true',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_BACKSPACE', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_BACKSPACE.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_BACKSPACE.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_BACKSPACE',
                comment: 'literal with BACKSPACE',
                name: 'literal_with_BACKSPACE',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_CARRIAGE_RETURN', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_CARRIAGE_RETURN.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_CARRIAGE_RETURN.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_CARRIAGE_RETURN',
                comment: 'literal with CARRIAGE RETURN',
                name: 'literal_with_CARRIAGE_RETURN',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_CHARACTER_TABULATION', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_CHARACTER_TABULATION.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_CHARACTER_TABULATION.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_CHARACTER_TABULATION',
                comment: 'literal with CHARACTER TABULATION',
                name: 'literal_with_CHARACTER_TABULATION',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_FORM_FEED', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_FORM_FEED.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_FORM_FEED.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_FORM_FEED',
                comment: 'literal with FORM FEED',
                name: 'literal_with_FORM_FEED',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_LINE_FEED', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_LINE_FEED.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_LINE_FEED.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_LINE_FEED',
                comment: 'literal with LINE FEED',
                name: 'literal_with_LINE_FEED',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_REVERSE_SOLIDUS', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_REVERSE_SOLIDUS.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_REVERSE_SOLIDUS.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_REVERSE_SOLIDUS',
                comment: 'literal with REVERSE SOLIDUS',
                name: 'literal_with_REVERSE_SOLIDUS',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_escaped_BACKSPACE', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_escaped_BACKSPACE.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_BACKSPACE.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_escaped_BACKSPACE',
                comment: 'literal with escaped BACKSPACE',
                name: 'literal_with_escaped_BACKSPACE',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_escaped_CARRIAGE_RETURN', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_escaped_CARRIAGE_RETURN.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_CARRIAGE_RETURN.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_escaped_CARRIAGE_RETURN',
                comment: 'literal with escaped CARRIAGE RETURN',
                name: 'literal_with_escaped_CARRIAGE_RETURN',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_escaped_CHARACTER_TABULATION', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_escaped_CHARACTER_TABULATION.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_CHARACTER_TABULATION.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_escaped_CHARACTER_TABULATION',
                comment: 'literal with escaped CHARACTER TABULATION',
                name: 'literal_with_escaped_CHARACTER_TABULATION',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_escaped_FORM_FEED', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_escaped_FORM_FEED.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_FORM_FEED.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_escaped_FORM_FEED',
                comment: 'literal with escaped FORM FEED',
                name: 'literal_with_escaped_FORM_FEED',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_escaped_LINE_FEED', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_escaped_LINE_FEED.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_LINE_FEED.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_escaped_LINE_FEED',
                comment: 'literal with escaped LINE FEED',
                name: 'literal_with_escaped_LINE_FEED',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_numeric_escape4', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_numeric_escape4.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_numeric_escape4.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_numeric_escape4',
                comment: 'literal with numeric escape4 \\u',
                name: 'literal_with_numeric_escape4',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('literal_with_numeric_escape8', () async {
              final actionContent = await File(
                '$testFilePath/literal_with_numeric_escape8.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/literal_with_numeric_escape4.nt',
              ).readAsString();

              final testData = (
                id: '#literal_with_numeric_escape8',
                comment: 'literal with numeric escape8 \\U',
                name: 'literal_with_numeric_escape8',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test(
              'localName_with_assigned_nfc_PN_CHARS_BASE_character_boundaries',
              () async {
                final actionContent = await File(
                  '$testFilePath/localName_with_assigned_nfc_PN_CHARS_BASE_character_boundaries.ttl',
                ).readAsString();
                final resultContent = await File(
                  '$testFilePath/localName_with_assigned_nfc_PN_CHARS_BASE_character_boundaries.nt',
                ).readAsString();

                final testData = (
                  id: '#localName_with_assigned_nfc_PN_CHARS_BASE_character_boundaries',
                  comment:
                      'localName with assigned, NFC-normalized PN CHARS BASE character boundaries (p:AZazÀÖØöø...)',
                  name:
                      'localName_with_assigned_nfc_PN_CHARS_BASE_character_boundaries',
                  type: 'PositiveSyntaxTest',
                  action: actionContent,
                  result: resultContent,
                );

                final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
                final nTriples = nTriplesCodec.decode(testData.result);
                final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
                final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
                expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
              },
            );

            test(
              'localName_with_assigned_nfc_bmp_PN_CHARS_BASE_character_boundaries',
              () async {
                final actionContent = await File(
                  '$testFilePath/localName_with_assigned_nfc_bmp_PN_CHARS_BASE_character_boundaries.ttl',
                ).readAsString();
                final resultContent = await File(
                  '$testFilePath/localName_with_assigned_nfc_bmp_PN_CHARS_BASE_character_boundaries.nt',
                ).readAsString();

                final testData = (
                  id: '#localName_with_assigned_nfc_bmp_PN_CHARS_BASE_character_boundaries',
                  comment:
                      'localName with assigned, NFC-normalized, basic-multilingual-plane PN CHARS BASE character boundaries (p:AZazÀÖØöø...)',
                  name:
                      'localName_with_assigned_nfc_bmp_PN_CHARS_BASE_character_boundaries',
                  type: 'PositiveSyntaxTest',
                  action: actionContent,
                  result: resultContent,
                );

                final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
                final nTriples = nTriplesCodec.decode(testData.result);
                final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
                final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
                expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
              },
            );

            test('localName_with_leading_digit', () async {
              final actionContent = await File(
                '$testFilePath/localName_with_leading_digit.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/localName_with_leading_digit.nt',
              ).readAsString();

              final testData = (
                id: '#localName_with_leading_digit',
                comment: 'localName with leading digit (p:_)',
                name: 'localName_with_leading_digit',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('localName_with_leading_underscore', () async {
              final actionContent = await File(
                '$testFilePath/localName_with_leading_underscore.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/localName_with_leading_underscore.nt',
              ).readAsString();

              final testData = (
                id: '#localName_with_leading_underscore',
                comment: 'localName with leading underscore (p:_)',
                name: 'localName_with_leading_underscore',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('localName_with_nfc_PN_CHARS_BASE_character_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/localName_with_nfc_PN_CHARS_BASE_character_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/localName_with_nfc_PN_CHARS_BASE_character_boundaries.nt',
              ).readAsString();

              final testData = (
                id: '#localName_with_nfc_PN_CHARS_BASE_character_boundaries',
                comment:
                    'localName with nfc-normalize PN CHARS BASE character boundaries (p:AZazÀÖØöø...)',
                name: 'localName_with_nfc_PN_CHARS_BASE_character_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('localName_with_non_leading_extras', () async {
              final actionContent = await File(
                '$testFilePath/localName_with_non_leading_extras.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/localName_with_non_leading_extras.nt',
              ).readAsString();

              final testData = (
                id: '#localName_with_non_leading_extras',
                comment: 'localName with_non_leading_extras (_:a·̀ͯ‿.⁀)',
                name: 'localName_with_non_leading_extras',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('localname_with_COLON', () async {
              final actionContent = await File(
                '$testFilePath/localname_with_COLON.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/localname_with_COLON.nt',
              ).readAsString();

              final testData = (
                id: '#localname_with_COLON',
                comment: 'localname with COLON',
                name: 'localname_with_COLON',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('negative_numeric', () async {
              final actionContent = await File(
                '$testFilePath/negative_numeric.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/negative_numeric.nt',
              ).readAsString();

              final testData = (
                id: '#negative_numeric',
                comment: 'negative numeric',
                name: 'negative_numeric',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('nested_blankNodePropertyLists', () async {
              final actionContent = await File(
                '$testFilePath/nested_blankNodePropertyLists.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/nested_blankNodePropertyLists.nt',
              ).readAsString();

              final testData = (
                id: '#nested_blankNodePropertyLists',
                comment:
                    'nested blankNodePropertyLists [ <p1> [ <p2> <o2> ] ; <p3> <o3> ]',
                name: 'nested_blankNodePropertyLists',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('nested_collection', () async {
              final actionContent = await File(
                '$testFilePath/nested_collection.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/nested_collection.nt',
              ).readAsString();

              final testData = (
                id: '#nested_collection',
                comment: 'nested collection (())',
                name: 'nested_collection',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('numeric_with_leading_0', () async {
              final actionContent = await File(
                '$testFilePath/numeric_with_leading_0.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/numeric_with_leading_0.nt',
              ).readAsString();

              final testData = (
                id: '#numeric_with_leading_0',
                comment: 'numeric with leading 0',
                name: 'numeric_with_leading_0',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('objectList_with_two_objects', () async {
              final actionContent = await File(
                '$testFilePath/objectList_with_two_objects.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/objectList_with_two_objects.nt',
              ).readAsString();

              final testData = (
                id: '#objectList_with_two_objects',
                comment: 'objectList with two objects … <o1>,<o2>',
                name: 'objectList_with_two_objects',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('old_style_base', () async {
              final actionContent = await File(
                '$testFilePath/old_style_base.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#old_style_base',
                comment: 'old-style base',
                name: 'old_style_base',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('old_style_prefix', () async {
              final actionContent = await File(
                '$testFilePath/old_style_prefix.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#old_style_prefix',
                comment: 'old-style prefix',
                name: 'old_style_prefix',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('percent_escaped_localName', () async {
              final actionContent = await File(
                '$testFilePath/percent_escaped_localName.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/percent_escaped_localName.nt',
              ).readAsString();

              final testData = (
                id: '#percent_escaped_localName',
                comment: 'percent-escaped local name',
                name: 'percent_escaped_localName',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('positive_numeric', () async {
              final actionContent = await File(
                '$testFilePath/positive_numeric.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/positive_numeric.nt',
              ).readAsString();

              final testData = (
                id: '#positive_numeric',
                comment: 'positive numeric',
                name: 'positive_numeric',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('predicateObjectList_with_blankNodePropertyList_as_object', () async {
              final actionContent = await File(
                '$testFilePath/predicateObjectList_with_blankNodePropertyList_as_object.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/predicateObjectList_with_blankNodePropertyList_as_object.nt',
              ).readAsString();

              final testData = (
                id: '#predicateObjectList_with_blankNodePropertyList_as_object',
                comment:
                    'predicateObjectList_with_blankNodePropertyList_as_object <s> <p> [ <p2> <o> ] ; <p3> [ <p4> <o2> , <o3> ] ',
                name:
                    'predicateObjectList_with_blankNodePropertyList_as_object',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('predicateObjectList_with_two_objectLists', () async {
              final actionContent = await File(
                '$testFilePath/predicateObjectList_with_two_objectLists.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/predicateObjectList_with_two_objectLists.nt',
              ).readAsString();

              final testData = (
                id: '#predicateObjectList_with_two_objectLists',
                comment: 'predicateObjectList with two objectLists … <o1>,<o2>',
                name: 'predicateObjectList_with_two_objectLists',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('prefix_only_IRI', () async {
              final actionContent = await File(
                '$testFilePath/prefix_only_IRI.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#prefix_only_IRI',
                comment: 'prefix-only IRI (p:)',
                name: 'prefix_only_IRI',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('prefix_reassigned_and_used', () async {
              final actionContent = await File(
                '$testFilePath/prefix_reassigned_and_used.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/prefix_reassigned_and_used.nt',
              ).readAsString();

              final testData = (
                id: '#prefix_reassigned_and_used',
                comment: 'prefix reassigned and used',
                name: 'prefix_reassigned_and_used',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('prefix_with_PN_CHARS_BASE_character_boundaries', () async {
              final actionContent = await File(
                '$testFilePath/prefix_with_PN_CHARS_BASE_character_boundaries.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#prefix_with_PN_CHARS_BASE_character_boundaries',
                comment:
                    'prefix with PN CHARS BASE character boundaries (prefix: AZazÀÖØöø...:)',
                name: 'prefix_with_PN_CHARS_BASE_character_boundaries',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('prefix_with_non_leading_extras', () async {
              final actionContent = await File(
                '$testFilePath/prefix_with_non_leading_extras.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#prefix_with_non_leading_extras',
                comment: 'prefix with_non_leading_extras (_:a·̀ͯ‿.⁀)',
                name: 'prefix_with_non_leading_extras',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('prefixed_IRI_object', () async {
              final actionContent = await File(
                '$testFilePath/prefixed_IRI_object.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#prefixed_IRI_object',
                comment: 'prefixed IRI object',
                name: 'prefixed_IRI_object',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('prefixed_IRI_predicate', () async {
              final actionContent = await File(
                '$testFilePath/prefixed_IRI_predicate.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#prefixed_IRI_predicate',
                comment: 'prefixed IRI predicate',
                name: 'prefixed_IRI_predicate',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('prefixed_name_datatype', () async {
              final actionContent = await File(
                '$testFilePath/prefixed_name_datatype.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRIREF_datatype.nt',
              ).readAsString();

              final testData = (
                id: '#prefixed_name_datatype',
                comment: 'prefixed name datatype ""^^p:t',
                name: 'prefixed_name_datatype',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('repeated_semis_at_end', () async {
              final actionContent = await File(
                '$testFilePath/repeated_semis_at_end.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/predicateObjectList_with_two_objectLists.nt',
              ).readAsString();

              final testData = (
                id: '#repeated_semis_at_end',
                comment: 'repeated semis at end <s> <p> <o> ;; <p2> <o2> .',
                name: 'repeated_semis_at_end',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('repeated_semis_not_at_end', () async {
              final actionContent = await File(
                '$testFilePath/repeated_semis_not_at_end.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/repeated_semis_not_at_end.nt',
              ).readAsString();

              final testData = (
                id: '#repeated_semis_not_at_end',
                comment: 'repeated semis not at end <s> <p> <o> ;;.',
                name: 'repeated_semis_not_at_end',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('reserved_escaped_localName', () async {
              final actionContent = await File(
                '$testFilePath/reserved_escaped_localName.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/reserved_escaped_localName.nt',
              ).readAsString();

              final testData = (
                id: '#reserved_escaped_localName',
                comment: 'reserved-escaped local name',
                name: 'reserved_escaped_localName',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('sole_blankNodePropertyList', () async {
              final actionContent = await File(
                '$testFilePath/sole_blankNodePropertyList.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/labeled_blank_node_subject.nt',
              ).readAsString();

              final testData = (
                id: '#sole_blankNodePropertyList',
                comment: 'sole blankNodePropertyList [ <p> <o> ] .',
                name: 'sole_blankNodePropertyList',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-eval-lists-01', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-lists-01.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-eval-lists-01.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-lists-01',
                comment: 'empty list',
                name: 'turtle-eval-lists-01',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-eval-lists-02', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-lists-02.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-eval-lists-02.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-lists-02',
                comment: 'mixed list',
                name: 'turtle-eval-lists-02',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-eval-lists-03', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-lists-03.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-eval-lists-03.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-lists-03',
                comment: 'isomorphic list as subject and object',
                name: 'turtle-eval-lists-03',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-eval-lists-04', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-lists-04.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-eval-lists-04.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-lists-04',
                comment: 'lists of lists',
                name: 'turtle-eval-lists-04',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-eval-lists-05', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-lists-05.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-eval-lists-05.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-lists-05',
                comment: 'mixed lists with embedded lists',
                name: 'turtle-eval-lists-05',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-eval-lists-06', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-lists-06.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-eval-lists-06.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-lists-06',
                comment: 'list containing blank node with abbreviated term',
                name: 'turtle-eval-lists-06',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-eval-struct-01', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-struct-01.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-eval-struct-01.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-struct-01',
                comment: 'triple with IRIs',
                name: 'turtle-eval-struct-01',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-eval-struct-02', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-struct-02.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-eval-struct-02.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-struct-02',
                comment: 'triple with IRIs and embedded whitespace',
                name: 'turtle-eval-struct-02',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-01', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-01.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-01.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-01',
                comment: 'Blank subject',
                name: 'turtle-subm-01',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-02', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-02.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-02.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-02',
                comment: '@prefix and qnames',
                name: 'turtle-subm-02',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-03', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-03.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-03.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-03',
                comment: ', operator',
                name: 'turtle-subm-03',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-04', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-04.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-04.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-04',
                comment: '; operator',
                name: 'turtle-subm-04',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-05', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-05.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-05.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-05',
                comment: 'empty [] as subject and object',
                name: 'turtle-subm-05',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-06', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-06.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-06.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-06',
                comment: 'non-empty [] as subject and object',
                name: 'turtle-subm-06',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-07', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-07.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-07.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-07',
                comment: '\'a\' as predicate',
                name: 'turtle-subm-07',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-08', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-08.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-08.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-08',
                comment: 'simple collection',
                name: 'turtle-subm-08',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-09', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-09.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-09.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-09',
                comment: 'empty collection',
                name: 'turtle-subm-09',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-10', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-10.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-10.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-10',
                comment: 'integer datatyped literal',
                name: 'turtle-subm-10',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-11', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-11.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-11.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-11',
                comment: 'decimal integer canonicalization',
                name: 'turtle-subm-11',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-12', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-12.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-12.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-12',
                comment: '- and _ in names and qnames',
                name: 'turtle-subm-12',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-13', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-13.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-13.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-13',
                comment:
                    'tests for rdf:_<numbers> and other qnames starting with _',
                name: 'turtle-subm-13',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-14', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-14.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-14.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-14',
                comment: 'bare : allowed',
                name: 'turtle-subm-14',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-15', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-15.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-15.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-15',
                comment: 'simple long literal',
                name: 'turtle-subm-15',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-16', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-16.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-16.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-16',
                comment: 'long literals with escapes',
                name: 'turtle-subm-16',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-17', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-17.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-17.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-17',
                comment: 'floating point number',
                name: 'turtle-subm-17',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-18', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-18.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-18.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-18',
                comment: 'empty literals, normal and long variant',
                name: 'turtle-subm-18',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-19', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-19.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-19.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-19',
                comment: 'positive integer, decimal and doubles',
                name: 'turtle-subm-19',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-20', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-20.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-20.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-20',
                comment: 'negative integer, decimal and doubles',
                name: 'turtle-subm-20',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-21', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-21.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-21.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-21',
                comment: 'long literal ending in double quote',
                name: 'turtle-subm-21',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-22', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-22.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-22.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-22',
                comment: 'boolean literals',
                name: 'turtle-subm-22',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-23', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-23.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-23.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-23',
                comment: 'comments',
                name: 'turtle-subm-23',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-24', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-24.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-24.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-24',
                comment: 'no final mewline',
                name: 'turtle-subm-24',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-25', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-25.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-25.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-25',
                comment: 'repeating a @prefix changes pname definition',
                name: 'turtle-subm-25',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-26', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-26.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-26.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-26',
                comment: 'Variations on decimal canonicalization',
                name: 'turtle-subm-26',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('turtle-subm-27', () async {
              final actionContent = await File(
                '$testFilePath/turtle-subm-27.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/turtle-subm-27.nt',
              ).readAsString();

              final testData = (
                id: '#turtle-subm-27',
                comment: 'Repeating @base changes base for relative IRI lookup',
                name: 'turtle-subm-27',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('two_LITERAL_LONG2s', () async {
              final actionContent = await File(
                '$testFilePath/two_LITERAL_LONG2s.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/two_LITERAL_LONG2s.nt',
              ).readAsString();

              final testData = (
                id: '#two_LITERAL_LONG2s',
                comment: 'two LITERAL_LONG2s testing quote delimiter overrun',
                name: 'two_LITERAL_LONG2s',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('underscore_in_localName', () async {
              final actionContent = await File(
                '$testFilePath/underscore_in_localName.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/underscore_in_localName.nt',
              ).readAsString();

              final testData = (
                id: '#underscore_in_localName',
                comment: 'underscore in local name',
                name: 'underscore_in_localName',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });
          });
          group('Negative Syntax Tests', () {
            test('turtle-eval-bad-01', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-bad-01.ttl',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-bad-01',
                comment:
                    'Bad IRI : good escape, bad charcater (negative evaluation test)',
                name: 'turtle-eval-bad-01',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test('turtle-eval-bad-02', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-bad-02.ttl',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-bad-02',
                comment: 'Bad IRI : hex 3C is < (negative evaluation test)',
                name: 'turtle-eval-bad-02',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test('turtle-eval-bad-03', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-bad-03.ttl',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-bad-03',
                comment: 'Bad IRI : hex 3E is  (negative evaluation test)',
                name: 'turtle-eval-bad-03',
                type: 'NegativeSyntaxTest',
                action: actionContent,
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test('turtle-eval-bad-04', () async {
              final actionContent = await File(
                '$testFilePath/turtle-eval-bad-04.ttl',
              ).readAsString();

              final testData = (
                id: '#turtle-eval-bad-04',
                comment: 'Bad IRI : {abc} (negative evaluation test)',
                name: 'turtle-eval-bad-04',
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
        group('Proposed Tests', () {
          group('Positive Syntax Tests', () {
            test('IRI-resolution-01', () async {
              final actionContent = await File(
                '$testFilePath/IRI-resolution-01.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI-resolution-01.nt',
              ).readAsString();

              final testData = (
                id: '#IRI-resolution-01',
                comment: 'IRI resolution (RFC3986 original cases)',
                name: 'IRI-resolution-01',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('IRI-resolution-02', () async {
              final actionContent = await File(
                '$testFilePath/IRI-resolution-02.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI-resolution-02.nt',
              ).readAsString();

              final testData = (
                id: '#IRI-resolution-02',
                comment:
                    'IRI resolution (RFC3986 using base IRI with trailing slash)',
                name: 'IRI-resolution-02',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('IRI-resolution-07', () async {
              final actionContent = await File(
                '$testFilePath/IRI-resolution-07.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI-resolution-07.nt',
              ).readAsString();

              final testData = (
                id: '#IRI-resolution-07',
                comment:
                    'IRI resolution (RFC3986 using base IRI with file path)',
                name: 'IRI-resolution-07',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('IRI-resolution-08', () async {
              final actionContent = await File(
                '$testFilePath/IRI-resolution-08.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI-resolution-08.nt',
              ).readAsString();

              final testData = (
                id: '#IRI-resolution-08',
                comment: 'IRI resolution (miscellaneous cases)',
                name: 'IRI-resolution-08',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('comment_following_PNAME_NS', () async {
              final actionContent = await File(
                '$testFilePath/comment_following_PNAME_NS.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/comment_following_PNAME_NS.nt',
              ).readAsString();

              final testData = (
                id: '#comment_following_PNAME_NS',
                comment: 'comment following PNAME_NS',
                name: 'comment_following_PNAME_NS',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('comment_following_localName', () async {
              final actionContent = await File(
                '$testFilePath/comment_following_localName.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/IRI_spo.nt',
              ).readAsString();

              final testData = (
                id: '#comment_following_localName',
                comment: 'comment following localName',
                name: 'comment_following_localName',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('number_sign_following_PNAME_NS', () async {
              final actionContent = await File(
                '$testFilePath/number_sign_following_PNAME_NS.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/number_sign_following_PNAME_NS.nt',
              ).readAsString();

              final testData = (
                id: '#number_sign_following_PNAME_NS',
                comment: 'number sign following PNAME_NS',
                name: 'number_sign_following_PNAME_NS',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });

            test('number_sign_following_localName', () async {
              final actionContent = await File(
                '$testFilePath/number_sign_following_localName.ttl',
              ).readAsString();
              final resultContent = await File(
                '$testFilePath/number_sign_following_localName.nt',
              ).readAsString();

              final testData = (
                id: '#number_sign_following_localName',
                comment: 'number sign following localName',
                name: 'number_sign_following_localName',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: resultContent,
              );

              final turtleTriples = TurtleDecoder(baseUri: 'https://w3c.github.io/rdf-tests/rdf/rdf11/rdf-turtle/${testData.name}.ttl').convert(testData.action);
              final nTriples = nTriplesCodec.decode(testData.result);
              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);
              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);
              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);
            });
          });
        });
      });
    });
  });
}
