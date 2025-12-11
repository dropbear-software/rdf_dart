# Test Code Generator

## Input File

Your job is to take the contents of a provided JSON file `test/codec/tutle/w3c/rdf11/manifest.json` and use it to generate a series of Dart tests for an as yet to be developed feature of a Turtle 1.1 codec (encoder / decoder).

The file is an array of objects which cover a large number of tests representing a number of different key categories explained below:
1. Tests that are `approved` and deal with a `positive syntax` (i.e. they are valid and the codec should be able to parse them)
2. Tests that are `approved` and deal with a `negative syntax` (i.e. they are invalid and the codec should throw a `FormatException` when trying to parse them)
3. Tests that are `proposed` and deal with a `positive syntax` 
4. Tests that are `proposed` and deal with a `negative syntax`.

Here is an example of each one:

### Approved positive syntax

```json
{
  "@id": "#HYPHEN_MINUS_in_localName",
  "@type": "rdft:TestTurtleEval",
  "rdfs:comment": "HYPHEN-MINUS in local name",
  "mf:action": {
    "@id": "HYPHEN_MINUS_in_localName.ttl"
  },
  "mf:name": "HYPHEN_MINUS_in_localName",
  "mf:result": {
    "@id": "HYPHEN_MINUS_in_localName.nt"
  },
  "rdft:approval": {
    "@id": "rdft:Approved"
  }
}
```

- `@id` the identifer associated with the test
- `rdfs:comment` is a human readable description of the test
- `mf:action` has an object with an `@id` which represents the input file
- `mf:result` has an object with an `@id` which represents the another file which contains the expected output of a roundtrip
- `mf:name` is the name of the test
- `rdft:approval` has an object with an `@id` that represents if the test is approved or proposed.


### Proposed positive syntax

```json
{
  "@id": "#IRI-resolution-01",
  "@type": "rdft:TestTurtleEval",
  "rdfs:comment": "IRI resolution (RFC3986 original cases)",
  "mf:action": {
    "@id": "IRI-resolution-01.ttl"
  },
  "mf:name": "IRI-resolution-01",
  "mf:result": {
    "@id": "IRI-resolution-01.nt"
  },
  "rdft:approval": {
    "@id": "rdft:Proposed"
  }
}
```

All of the fields are the same with the same meaning, it's just that the `rdft:approval` is different.

### Approved negative syntax

```json
{
  "@id": "#turtle-eval-bad-01",
  "@type": "rdft:TestTurtleNegativeEval",
  "rdfs:comment": "Bad IRI : good escape, bad charcater (negative evaluation test)",
  "mf:action": {
    "@id": "turtle-eval-bad-01.ttl"
  },
  "mf:name": "turtle-eval-bad-01",
  "rdft:approval": {
    "@id": "rdft:Approved"
  }
}
```

In negative syntax tests there is no `mf:result` field as the test is expected to throw a `FormatException`.


### Proposed negative syntax

As above. There is no `mf:result` and the `rdft:approval` will indicate that it is proposed. It's not actually clear if any of these exist however.

## Output file

The file you are expected to generate looks like this. I've included an example of each test type (excluding proposed negative syntax as I didn't see any initially)

Note how the tests are grouped together into a clear hierarchy.


```dart
import 'dart:io';

import 'package:test/test.dart';
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  group('W3C Test Suite', () {
    group('RDF 1.1', () {
      // All the test case files are loaded from this directory
      const testFilePath = 'test/codec/turtle/w3c/rdf11';
      group('Turtle Syntax ', () {
        group('Approved Tests', () {
          group('Positive Syntax Tests', () {

            // Assuming we were dealing with this JSON object in this example
            // Obviously you wouldn't include these comments in the real version
            //{
            //  "@id": "#HYPHEN_MINUS_in_localName",
            //  "@type": "rdft:TestTurtleEval",
            //  "rdfs:comment": "HYPHEN-MINUS in local name",
            //  "mf:action": {
            //    "@id": "HYPHEN_MINUS_in_localName.ttl"
            //  },
            //  "mf:name": "HYPHEN_MINUS_in_localName",
            //  "mf:result": {
            //    "@id": "HYPHEN_MINUS_in_localName.nt"
            //  },
            //  "rdft:approval": {
            //    "@id": "rdft:Approved"
            //  }
            test('HYPHEN_MINUS_in_localName', () async {
              
              final actionContent = await File('$testFilePath/HYPHEN_MINUS_in_localName.ttl').readAsString();
              final expectedOutput = await File('$testFilePath/HYPHEN_MINUS_in_localName.nt').readAsString();

              final testData = (
                id: '#HYPHEN_MINUS_in_localName',
                comment: 'HYPHEN-MINUS in local name',
                name: 'HYPHEN_MINUS_in_localName',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: expectedOutput
              );

              // Test that we can decode it
              final result = turtleCodec.decode(testData.action);
              final actualOutput = turtleCodec.encode(result);
              expect(actualOutput, expectedOutput);              
            });
          });

          group('Negative Syntax Tests', () {
            // Assuming we were dealing with this JSON object in this example
            // Obviously you wouldn't include these comments in the real version
            //{
            //  "@id": "#turtle-eval-bad-01",
            //  "@type": "rdft:TestTurtleNegativeEval",
            //  "rdfs:comment": "Bad IRI : good escape, bad charcater (negative evaluation test)",
            //  "mf:action": {
            //    "@id": "turtle-eval-bad-01.ttl"
            //  },
            //  "mf:name": "turtle-eval-bad-01",
            //  "rdft:approval": {
            //    "@id": "rdft:Approved"
            //  }
            //}
            test('turtle-eval-bad-01', () async {
              
              final actionContent = await File('$testFilePath/turtle-eval-bad-01.ttl').readAsString();

              final testData = (
                id: '#turtle-eval-bad-01',
                comment: 'Bad IRI : good escape, bad charcater (negative evaluation test)',
                name: 'turtle-eval-bad-01',
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
            // Assuming we were dealing with this JSON object in this example
            // Obviously you wouldn't include these comments in the real version
            // {
            //   "@id": "#IRI-resolution-01",
            //   "@type": "rdft:TestTurtleEval",
            //   "rdfs:comment": "IRI resolution (RFC3986 original cases)",
            //   "mf:action": {
            //     "@id": "IRI-resolution-01.ttl"
            //   },
            //   "mf:name": "IRI-resolution-01",
            //   "mf:result": {
            //     "@id": "IRI-resolution-01.nt"
            //   },
            //   "rdft:approval": {
            //     "@id": "rdft:Proposed"
            //   }
            // }
            test('IRI-resolution-01', () async {
              
              final actionContent = await File('$testFilePath/IRI-resolution-01.ttl').readAsString();
              final expectedOutput = await File('$testFilePath/IRI-resolution-01.nt').readAsString();

              final testData = (
                id: '#IRI-resolution-01',
                comment: 'IRI resolution (RFC3986 original cases)',
                name: 'IRI-resolution-01',
                type: 'PositiveSyntaxTest',
                action: actionContent,
                result: expectedOutput
              );

              // Test that we can decode it
              final result = turtleCodec.decode(testData.action);
              final actualOutput = turtleCodec.encode(result);
              expect(actualOutput, expectedOutput);              
            });
          });
        });
      });
    });
  });
}
```

## The Task
Write a code generation script that processes the input file specified and outputs the tests as described.

The output file of the generated tests should be `test/codec/turtle/generated_test_helper.dart`