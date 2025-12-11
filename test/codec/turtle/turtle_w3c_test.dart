import 'dart:io';

import 'package:intl/intl.dart';
import 'package:rdf_dart/src/codecs/n-triples/n_triples_codec.dart';
import 'package:rdf_dart/src/codecs/turtle/turtle_codec.dart';
import 'package:rdf_dart/src/model/blank_node.dart';
import 'package:rdf_dart/src/model/iri.dart';
import 'package:rdf_dart/src/model/literal.dart';
import 'package:rdf_dart/src/model/triple.dart';
import 'package:rdf_dart/src/model/triple_term.dart';
import 'package:test/test.dart';

void main() {
  group('W3C Test Suite', () {
    group('RDF 1.1', () {
      group('Turtle Syntax ', () {
        group('Approved Tests', () {
          group('Positive Syntax Tests', () {});

          group('Negative Syntax Tests', () {});
        });

        group('Proposed Tests', () {
          group('Positive Syntax Tests', () {});
        });
      });
    });
    group('RDF 1.2', () {
      group('Turtle Syntax ', () {
        group('Approved Tests', () {
          group('Positive Syntax Tests', () {
            test('Turtle 1.2 - subject reified triple', () async {
              final testData = (
                id: 'trs:turtle12-1',
                name: 'Turtle 1.2 - subject reified triple',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o .
<<:s :p :o>> :q 123 .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test('Turtle 1.2 - object reified triple', () async {
              final testData = (
                id: 'trs:turtle12-2',
                name: 'Turtle 1.2 - object reified triple',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o .
:x :p <<:s :p :o>> .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test('Turtle 1.2 - triple term object', () async {
              final testData = (
                id: 'trs:turtle12-3',
                name: 'Turtle 1.2 - triple term object',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p <<(:s :p :o )>> .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(1));
            });

            test('Turtle 1.2 - reified triple outside triple', () async {
              final testData = (
                id: 'trs:turtle12-4',
                name: 'Turtle 1.2 - reified triple outside triple',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o .
<<:s :p :o>> .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test(
              'Turtle 1.2 - reified triple inside blankNodePropertyList',
              () async {
                final testData = (
                  id: 'trs:turtle12-inside-1',
                  name:
                      'Turtle 1.2 - reified triple inside blankNodePropertyList',
                  type: 'PositiveSyntaxTest',
                  action: '''
PREFIX : <http://example/>

:s :p :o .
[ :q <<:s :p :o>> ] :b :c .
''',
                );

                final result = turtleCodec.decode(testData.action);
                expect(result, hasLength(2));
              },
            );

            test('Turtle 1.2 - reified triple inside collection', () async {
              final testData = (
                id: 'trs:turtle12-inside-2',
                name: 'Turtle 1.2 - reified triple inside collection',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o1 .
:s :p :o2 .
( <<:s :p :o1>> <<:s :p :o2>> )  :q 123 .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(3));
            });

            test('Turtle 1.2 - reified triple with IRI identifier', () async {
              final testData = (
                id: 'trs:turtle12-inside-3',
                name: 'Turtle 1.2 - reified triple with IRI identifier',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p << :s :p :o1 ~ :id >> .
:id :q 123 .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test(
              'Turtle 1.2 - reified triple with blank node identifier',
              () async {
                final testData = (
                  id: 'trs:turtle12-inside-4',
                  name:
                      'Turtle 1.2 - reified triple with blank node identifier',
                  type: 'PositiveSyntaxTest',
                  action: '''
PREFIX : <http://example/>

:s :p <<:s :p :o1 ~_:id>> .
_:id :q 123 .
''',
                );

                final result = turtleCodec.decode(testData.action);
                expect(result, hasLength(2));
              },
            );

            test(
              'Turtle 1.2 - nested reified triple, subject position',
              () async {
                final testData = (
                  id: 'trs:turtle12-nested-1',
                  name: 'Turtle 1.2 - nested reified triple, subject position',
                  type: 'PositiveSyntaxTest',
                  action: '''
PREFIX : <http://example/>

:s :p :o .

<<:s :p :o >> :r :z .

<< <<:s :p :o >> :r :z >> :q 1 .
''',
                );

                final result = turtleCodec.decode(testData.action);
                expect(result, hasLength(3));
              },
            );

            test(
              'Turtle 1.2 - nested reified triple, object position',
              () async {
                final testData = (
                  id: 'trs:turtle12-nested-2',
                  name: 'Turtle 1.2 - nested reified triple, object position',
                  type: 'PositiveSyntaxTest',
                  action: '''
PREFIX : <http://example/>

:s :p :o .
:a :q <<:s :p :o >> .
<< :a :q <<:s :p :o >>>> :r :z .
''',
                );

                final result = turtleCodec.decode(testData.action);
                expect(result, hasLength(3));
              },
            );

            test('Turtle 1.2 - compound forms', () async {
              final testData = (
                id: 'trs:turtle12-compound-1',
                name: 'Turtle 1.2 - compound forms',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>


:x :r :z .
:a :b :c .
<<:a :b :c>> :r :z .
<<:x :r :z >> :p <<:a :b :c>> .

<< <<:x :r :z >> :p <<:a :b :c>> >>
   :q
<< <<:x :r :z >> :p <<:a :b :c>> >> .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(7));
            });

            test('Turtle 1.2 - blank node subject', () async {
              final testData = (
                id: 'trs:turtle12-bnode-1',
                name: 'Turtle 1.2 - blank node subject',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

_:a :p :o .
<<_:a :p :o >> :q 456 .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test('Turtle 1.2 - blank node object', () async {
              final testData = (
                id: 'trs:turtle12-bnode-2',
                name: 'Turtle 1.2 - blank node object',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p _:a .
<<:s :p _:a >> :q 456 .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test('Turtle 1.2 - blank node', () async {
              final testData = (
                id: 'trs:turtle12-bnode-3',
                name: 'Turtle 1.2 - blank node',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

<<[] :p [] >> :q :z .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test('Turtle 1.2 - Annotation form', () async {
              final testData = (
                id: 'trs:turtle12-ann-1',
                name: 'Turtle 1.2 - Annotation form',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o {| :r :z |} .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(1));
            });

            test('Turtle 1.2 - Annotation example', () async {
              final testData = (
                id: 'trs:turtle12-ann-2',
                name: 'Turtle 1.2 - Annotation example',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX :       <http://example/>
PREFIX xsd:     <http://www.w3.org/2001/XMLSchema#>

:s :p :o {| :source [ :graph <http://host1/> ;
                      :date "2020-01-20"^^xsd:date
                    ] ;
            :source [ :graph <http://host2/> ;
                      :date "2020-12-31"^^xsd:date
                    ]
          |} .

''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result.isNotEmpty, isTrue);
            });

            test('Turtle 1.2 - Annotation predicateObjecetList', () async {
              final testData = (
                id: 'trs:turtle12-ann-3',
                name: 'Turtle 1.2 - Annotation predicateObjecetList',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o {| :q1 :r1 ; :q2 :r2 ; |} .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(1));
            });

            test(
              'Turtle 1.2 - Annotation followed by predicate/object',
              () async {
                final testData = (
                  id: 'trs:turtle12-ann-4',
                  name: 'Turtle 1.2 - Annotation followed by predicate/object',
                  type: 'PositiveSyntaxTest',
                  action: '''
PREFIX : <http://example/>

:s :p :o {| :x :y |} ; :q :r .
''',
                );

                final result = turtleCodec.decode(testData.action);
                expect(result, hasLength(2));
              },
            );

            test('Turtle 1.2 - Reifier without annotation block', () async {
              final testData = (
                id: 'trs:turtle12-ann-5',
                name: 'Turtle 1.2 - Reifier without annotation block',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o ~:e .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test(
              'Turtle 1.2 - Empty reifier without annotation block',
              () async {
                final testData = (
                  id: 'trs:turtle12-ann-6',
                  name: 'Turtle 1.2 - Empty reifier without annotation block',
                  type: 'PositiveSyntaxTest',
                  action: '''
PREFIX : <http://example/>

:s :p :o ~ .
''',
                );

                final result = turtleCodec.decode(testData.action);
                expect(result, hasLength(2));
              },
            );

            test('Turtle 1.2 - Reifier with annotation block', () async {
              final testData = (
                id: 'trs:turtle12-ann-7',
                name: 'Turtle 1.2 - Reifier with annotation block',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o ~:e {| :q :r |} .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });

            test('Turtle 1.2 - Empty reifier with annotation block', () async {
              final testData = (
                id: 'trs:turtle12-ann-8',
                name: 'Turtle 1.2 - Empty reifier with annotation block',
                type: 'PositiveSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o ~ {| :q :r |} .
''',
              );

              final result = turtleCodec.decode(testData.action);
              expect(result, hasLength(2));
            });
          });

          group('Negative Syntax Tests', () {
            test('Turtle 1.2 - bad - reified triple as predicate', () async {
              final testData = (
                id: 'trs:turtle12-bad-1',
                name: 'Turtle 1.2 - bad - reified triple as predicate',
                type: 'NegativeSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p :o .
:x <<:s :p :o>> 123 .
''',
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test(
              'Turtle 1.2 - bad - literal in subject position of reified triple',
              () async {
                final testData = (
                  id: 'trs:turtle12-bad-2',
                  name: 'Turtle 1.2 - bad - reified triple as predicate',
                  type: 'NegativeSyntaxTest',
                  action: '''
PREFIX : <http://example/>

:s :p :o .
<<3 :p :o >> :q :z .
''',
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
                final testData = (
                  id: 'trs:turtle12-bad-3',
                  name:
                      'Turtle 1.2 - bad - blank node  as predicate in reified triple',
                  type: 'NegativeSyntaxTest',
                  action: '''
PREFIX : <http://example/>

<<:s [] :o>> :q 123 .
''',
                );

                expect(
                  (() => turtleCodec.decode(testData.action)),
                  throwsA(isA<FormatException>()),
                );
              },
            );

            test('Turtle 1.2 - bad - incomplete reified triple', () async {
              final testData = (
                id: 'trs:turtle12-bad-4',
                name: 'Turtle 1.2 - bad - incomplete reified triple',
                type: 'NegativeSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p << :p :r >> .
''',
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Turtle 1.2 - bad - over-long reified triple', () async {
              final testData = (
                id: 'trs:turtle12-bad-5',
                name: 'Turtle 1.2 - bad - over-long reified triple',
                type: 'NegativeSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p << :g :s :p :o >> .
''',
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Turtle 1.2 - bad - reified with list object', () async {
              final testData = (
                id: 'trs:turtle12-bad-6',
                name: 'Turtle 1.2 - bad - reified with list object',
                type: 'NegativeSyntaxTest',
                action: '''
PREFIX : <http://example/>

:s :p ("abc") .
<<:s :p ("abc") >> :q 123 .
''',
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Turtle 1.2 - bad - compound blank node expression', () async {
              final testData = (
                id: 'trs:turtle12-bad-7',
                name: 'Turtle 1.2 - bad - compound blank node expression',
                type: 'NegativeSyntaxTest',
                action: '''
PREFIX : <http://example/>

<<:s :p [ :p1 :o1 ]  >> :q 123 .
''',
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Turtle 1.2 - bad - empty annotation', () async {
              final testData = (
                id: 'trs:turtle12-bad-ann-2',
                name: 'Turtle 1.2 - bad - empty annotation',
                type: 'NegativeSyntaxTest',
                action: '''
PREFIX : <http://example.com/ns#>

SELECT * {
  :s :p :o {|  |} .
}
''',
              );

              expect(
                (() => turtleCodec.decode(testData.action)),
                throwsA(isA<FormatException>()),
              );
            });

            test('Turtle 1.2 - bad - triple as annotation', () async {
              final testData = (
                id: 'trs:turtle12-bad-ann-2',
                name: 'Turtle 1.2 - bad - triple as annotation',
                type: 'NegativeSyntaxTest',
                action: '''
PREFIX : <http://example.com/ns#>

:a :b :c {| :s :p :o |} .
''',
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
  });
}
