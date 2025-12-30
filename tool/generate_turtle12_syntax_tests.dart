import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final manifestFile = File('test/codec/turtle/w3c/rdf12/syntax/manifest.json');
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
    "      const testFilePath = 'test/codec/turtle/w3c/rdf12/syntax';",
  );
  buffer.writeln("      group('Turtle Syntax', () {");

  // Group tests by Positive and Negative
  final positiveTests = <Map<String, dynamic>>[];
  final negativeTests = <Map<String, dynamic>>[];

  for (final test in manifest) {
    final type = test['@type'];
    if (type == 'rdft:TestTurtlePositiveSyntax') {
      positiveTests.add(test);
    } else if (type == 'rdft:TestTurtleNegativeSyntax' ||
        type == 'rdft:TestNTriplesNegativeSyntax') {
      negativeTests.add(test);
    }
  }

  buffer.writeln(
    "        group('Positive Syntax Tests', () {",
  ); // Explicitly Positive
  _writeSyntaxGroup(buffer, positiveTests, true);
  buffer.writeln("        });"); // End Positive Syntax Tests

  buffer.writeln(
    "        group('Negative Syntax Tests', () {",
  ); // Explicitly Negative
  _writeSyntaxGroup(buffer, negativeTests, false);
  buffer.writeln("        });"); // End Negative Syntax Tests

  buffer.writeln("      });"); // End Turtle Syntax
  buffer.writeln("    });"); // End RDF 1.2
  buffer.writeln("  });"); // End W3C Test Suite
  buffer.writeln("}"); // End main

  final outputFile = File(
    'test/codec/turtle/generated_turtle12_syntax_test.dart',
  );
  await outputFile.writeAsString(buffer.toString());
  print('Generated tests at ${outputFile.path}');
}

void _writeSyntaxGroup(
  StringBuffer buffer,
  List<Map<String, dynamic>> tests,
  bool isPositive,
) {
  if (tests.isEmpty) return;

  for (final test in tests) {
    final id = test['@id'];
    // Use name as comment if rdfs:comment is missing, similar to prev script
    final rawComment = test['rdfs:comment'] ?? test['mf:name'];

    final comment = rawComment
        ?.replaceAll(r'\', r'\\') // Escape backslashes first
        ?.replaceAll("'", r"\'") // Escape single quotes
        ?.replaceAll(r'$', r'\$'); // Escape dollar signs

    final rawName = test['mf:name'];
    final name = rawName
        ?.replaceAll(r'\', r'\\') // Escape backslashes first
        ?.replaceAll("'", r"\'") // Escape single quotes
        ?.replaceAll(r'$', r'\$'); // Escape dollar signs
    final actionFile = test['mf:action']['@id'];

    buffer.writeln("          test('$name', () async {");
    buffer.writeln(
      "            final actionContent = await File('\$testFilePath/$actionFile').readAsString();",
    );
    buffer.writeln();
    buffer.writeln("            final testData = (");
    buffer.writeln("              id: '$id',");
    buffer.writeln("              name: '$name',");
    buffer.writeln(
      "              type: '${isPositive ? 'PositiveSyntaxTest' : 'NegativeSyntaxTest'}',",
    );
    buffer.writeln("              action: actionContent,");
    buffer.writeln("            );");
    buffer.writeln();

    if (isPositive) {
      buffer.writeln("            expect(");
      buffer.writeln(
        "              (() => turtleCodec.decode(testData.action)),",
      );
      buffer.writeln("              returnsNormally,");
      buffer.writeln("            );");
    } else {
      buffer.writeln("            expect(");
      buffer.writeln(
        "              (() => turtleCodec.decode(testData.action)),",
      );
      buffer.writeln("              throwsA(isA<FormatException>()),");
      buffer.writeln("            );");
    }

    buffer.writeln("          });"); // End test
  }
}
