import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final manifestFile = File('test/codec/turtle/w3c/rdf11/manifest.json');
  if (!manifestFile.existsSync()) {
    print('Manifest file not found at ${manifestFile.path}');
    exit(1);
  }

  final manifestContent = await manifestFile.readAsString();
  final List<dynamic> manifest = jsonDecode(manifestContent);

  final approvedPositive = <Map<String, dynamic>>[];
  final approvedNegative = <Map<String, dynamic>>[];
  final proposedPositive = <Map<String, dynamic>>[];
  final proposedNegative = <Map<String, dynamic>>[];

  for (final test in manifest) {
    if (test is! Map<String, dynamic>) continue;

    final type = test['@type'];
    final approval = test['rdft:approval']?['@id'];

    if (type == 'rdft:TestTurtleEval') {
      if (approval == 'rdft:Approved') {
        approvedPositive.add(test);
      } else if (approval == 'rdft:Proposed') {
        proposedPositive.add(test);
      }
    } else if (type == 'rdft:TestTurtleNegativeEval') {
      if (approval == 'rdft:Approved') {
        approvedNegative.add(test);
      } else if (approval == 'rdft:Proposed') {
        proposedNegative.add(test);
      }
    }
  }

  final buffer = StringBuffer();
  buffer.writeln("import 'dart:io';");
  buffer.writeln();
  buffer.writeln("import 'package:test/test.dart';");
  buffer.writeln("import 'package:rdf_dart/rdf_dart.dart';");
  buffer.writeln();
  buffer.writeln("void main() {");
  buffer.writeln("  group('W3C Test Suite', () {");
  buffer.writeln("    group('RDF 1.1', () {");
  buffer.writeln(
    "      // All the test case files are loaded from this directory",
  );
  buffer.writeln("      const testFilePath = 'test/codec/turtle/w3c/rdf11';");
  buffer.writeln("      group('Turtle Syntax ', () {");

  // Approved Tests
  buffer.writeln("        group('Approved Tests', () {");
  _writeEvaluateGroup(buffer, "Positive Syntax Tests", approvedPositive, true);
  _writeEvaluateGroup(buffer, "Negative Syntax Tests", approvedNegative, false);
  buffer.writeln("        });"); // End Approved Tests

  // Proposed Tests
  buffer.writeln("        group('Proposed Tests', () {");
  _writeEvaluateGroup(buffer, "Positive Syntax Tests", proposedPositive, true);
  _writeEvaluateGroup(buffer, "Negative Syntax Tests", proposedNegative, false);
  buffer.writeln("        });"); // End Proposed Tests

  buffer.writeln("      });"); // End Turtle Syntax
  buffer.writeln("    });"); // End RDF 1.1
  buffer.writeln("  });"); // End W3C Test Suite
  buffer.writeln("}"); // End main

  final outputFile = File('test/codec/turtle/generated_turtle11_test.dart');
  await outputFile.writeAsString(buffer.toString());
  print('Generated tests at ${outputFile.path}');
}

void _writeEvaluateGroup(
  StringBuffer buffer,
  String groupName,
  List<Map<String, dynamic>> tests,
  bool isPositive,
) {
  if (tests.isEmpty) return;

  buffer.writeln("          group('$groupName', () {");

  for (final test in tests) {
    final id = test['@id'];
    final comment = test['rdfs:comment']?.replaceAll(
      "'",
      r"\'",
    ); // Escape single quotes for Dart string
    final name = test['mf:name'];
    final actionFile = test['mf:action']['@id'];

    // The name of the test in the test() call
    buffer.writeln("");
    buffer.writeln("            test('$name', () async {");

    // Read action file
    buffer.writeln(
      "              final actionContent = await File('\$testFilePath/$actionFile').readAsString();",
    );

    if (isPositive) {
      final resultFile = test['mf:result']?['@id'];
      if (resultFile != null) {
        buffer.writeln(
          "              final resultContent = await File('\$testFilePath/$resultFile').readAsString();",
        );
      }
    }

    buffer.writeln();
    buffer.writeln("              final testData = (");
    buffer.writeln("                id: '$id',");
    buffer.writeln("                comment: '$comment',");
    buffer.writeln("                name: '$name',");
    buffer.writeln(
      "                type: '${isPositive ? 'PositiveSyntaxTest' : 'NegativeSyntaxTest'}',",
    );
    buffer.writeln("                action: actionContent,");
    if (isPositive && test['mf:result'] != null) {
      buffer.writeln("                result: resultContent");
    }
    buffer.writeln("              );");
    buffer.writeln();

    if (isPositive) {
      // Positive test logic
      buffer.writeln(
        "              final turtleTriples = turtleCodec.decode(testData.action);",
      );
      buffer.writeln(
        "              final nTriples = nTriplesCodec.decode(testData.result);",
      );
      buffer.writeln(
        "              final nTriplesGraph = InMemoryGraph()..addAll(nTriples);",
      );
      buffer.writeln(
        "              final turtleGraph = InMemoryGraph()..addAll(turtleTriples);",
      );
      buffer.writeln(
        "              expect(turtleGraph.isomorphic(nTriplesGraph), isTrue);",
      );
    } else {
      // Negative test logic
      buffer.writeln("              expect(");
      buffer.writeln(
        "                (() => turtleCodec.decode(testData.action)),",
      );
      buffer.writeln("                throwsA(isA<FormatException>()),");
      buffer.writeln("              );");
    }

    buffer.writeln("            });"); // End test
  }
  buffer.writeln("          });"); // End group
}
