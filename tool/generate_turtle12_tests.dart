import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final manifestFile = File('test/codec/turtle/w3c/rdf12/eval/manifest.json');
  if (!manifestFile.existsSync()) {
    print('Manifest file not found at ${manifestFile.path}');
    exit(1);
  }

  final manifestContent = await manifestFile.readAsString();
  final List<dynamic> manifest = jsonDecode(manifestContent);

  final buffer = StringBuffer();
  buffer.writeln("import 'dart:io';");
  buffer.writeln();
  buffer.writeln("import 'package:test/test.dart';");
  buffer.writeln("import 'package:rdf_dart/rdf_dart.dart';");
  buffer.writeln();
  buffer.writeln("void main() {");
  buffer.writeln("  group('W3C Test Suite', () {");
  buffer.writeln("    group('RDF 1.2', () {");
  buffer.writeln(
    "      // All the test case files are loaded from this directory",
  );
  buffer.writeln(
    "      const testFilePath = 'test/codec/turtle/w3c/rdf12/eval';",
  );
  buffer.writeln("      group('Turtle Evaluation', () {");

  // All tests are considered Approved and Positive Syntax for this suite
  buffer.writeln("        group('Approved Tests', () {");
  _writeEvaluateGroup(
    buffer,
    "Positive Syntax Tests",
    manifest.cast<Map<String, dynamic>>(),
    true,
  );
  buffer.writeln("        });"); // End Approved Tests

  buffer.writeln("      });"); // End Turtle Syntax
  buffer.writeln("    });"); // End RDF 1.2
  buffer.writeln("  });"); // End W3C Test Suite
  buffer.writeln("}"); // End main

  final outputFile = File(
    'test/codec/turtle/generated_turtle12_eval_test.dart',
  );
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
    if (test['@type'] != 'rdft:TestTurtleEval') continue;

    final id = test['@id'];
    // rdfs:comment is not present in this manifest, using names or defaults if needed,
    // but the spec for 1.1 had comments. Here we use name as comment if comment is missing?
    // Looking at the file, it has mf:name. It doesn't seem to have rdfs:comment.
    // We will use mf:name as the comment if rdfs:comment is missing.
    final rawComment = test['rdfs:comment'] ?? test['mf:name'];

    final comment = rawComment
        ?.replaceAll(r'\', r'\\') // Escape backslashes first
        ?.replaceAll("'", r"\'") // Escape single quotes
        ?.replaceAll(r'$', r'\$'); // Escape dollar signs

    final name = test['mf:name'];
    final actionFile = test['mf:action']['@id'];

    // The name of the test in the test() call
    buffer.writeln("            test('$name', () async {");

    // Read action file
    buffer.writeln(
      "              final actionContent = await File('\$testFilePath/$actionFile').readAsString();",
    );

    if (isPositive) {
      final resultFile = test['mf:result']?['@id'];
      if (resultFile != null) {
        buffer.writeln(
          "              final expectedOutput = await File('\$testFilePath/$resultFile').readAsString();",
        );
      }
    }

    buffer.writeln();
    buffer.writeln("              final testData = (");
    buffer.writeln("                id: '$id',");
    buffer.writeln("                name: '$name',");
    buffer.writeln(
      "                type: '${isPositive ? 'PositiveSyntaxTest' : 'NegativeSyntaxTest'}',",
    );
    buffer.writeln("                action: actionContent,");
    if (isPositive && test['mf:result'] != null) {
      buffer.writeln("                result: expectedOutput");
    }
    buffer.writeln("              );");
    buffer.writeln();

    if (isPositive) {
      // Positive test logic
      buffer.writeln("              // Test that we can decode it");
      buffer.writeln(
        "              final result = turtleCodec.decode(testData.action);",
      );
      buffer.writeln(
        "              final actualOutput = turtleCodec.encode(result);",
      );
      buffer.writeln("              expect(actualOutput, expectedOutput);");
    } else {
      // Negative test logic (none in this batch, but keeping logic just in case)
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
