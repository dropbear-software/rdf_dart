import 'package:rdf_dart/rdf_dart.dart';
import 'package:test/test.dart';

void main() {
  // This describes W3C RDF 1.1 Working Group's Entailment test suite.
  // This test suite contains two kinds of tests:
  //
  // 1. Positive Entailment Tests (rdft:PositiveEntailmentTest)
  // 2. Positive Entailment Tests (rdft:NegativeEntailmentTest)
  //
  // Each test is one of the above kinds of tests. All tests have
  // - a name (mf:name),
  // - an input RDF graph URL (mf:action),
  // - an output RDF graph URL or the special marker false (mf:result),
  // - an entailment regime, which is "simple", "RDF", or "RDFS" (mf:entailmentRegime),
  // - a list of recognized datatypes (mf:recognizedDatatypes),
  // - a list of unrecognized datatypes (mf:unrecognizedDatatypes).
  //
  // An implementation passes a Positive (Negative) Entailment Test
  // if, when configured to 1. perform entailment under the entailment regime
  // of the test or some entailment regime that is stronger (weaker) than
  // the entailment regime and 2. recognize all the datatypes in the list of
  // recognized datatypes and none of the datatypes in the list of unrecognized
  // datatypes, * for tests that have an output graph, determines that the input
  // RDF graph entails (does not entail) the output RDF graph * for tests that
  // have false as output, either determines that the input RDF graph
  // entails (does not entail) an inconsistent RDF graph or that the input
  // RDF graph is inconsistent (consistent).
  //
  // An implementation also passes a test if when configured differently from
  // a correct configuration as given above nonetheless produces the given
  // result, and the result is correct in the configured entailment regime
  // with the configured recognized datatypes.
  group("W3C RDF 1.1 Working Group's Entailment test suite", () {
    final nTriplesCodec = NTriplesCodec();

    test(
      'The claim that xsd:integer is a subClassOF xsd:decimal is not incompatible with using the intensional semantics for datatypes.',
      () {
        final testCase = (
          name: 'datatypes-intensional-xsd-integer-decimal-compatible',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#decimal'),
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
          ],
          unrecognizedDatatypes: [],
          action:
              '<http://www.w3.org/2001/XMLSchema#integer> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2001/XMLSchema#decimal> .',
          result: false,
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test(
      "The claim that xsd:integer is a subClassOF xsd:string is incompatible with using the intensional semantics for datatypes",
      () {
        final testCase = (
          name: 'datatypes-intensional-xsd-integer-string-incompatible',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
            Iri('http://www.w3.org/2001/XMLSchema#string'),
          ],
          unrecognizedDatatypes: [],
          action:
              '<http://www.w3.org/2001/XMLSchema#integer> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2001/XMLSchema#string> .',
          result: false,
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test(
      "Without datatype knowledge, a 'badly-formed' datatyped literal cannot be detected. Used to be a postitive test to itself.",
      () {
        final testCase = (
          name: 'datatypes-non-well-formed-literal-1',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
          ],
          action:
              '<http://example.org/foo> <http://example.org/bar> "flargh"^^<http://www.w3.org/2001/XMLSchema#integer> .',
          result: false,
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test(
      "With appropriate datatype knowledge, a 'badly-formed' datatyped literal can be detected.",
      () {
        final testCase = (
          name: 'datatypes-non-well-formed-literal-1',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
          ],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/foo> <http://example.org/bar> "flargh"^^<http://www.w3.org/2001/XMLSchema#integer> .',
          result: false,
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test(
      "Demonstrating the semantic equivalence of two lexical forms of the same datatyped value.",
      () {
        final testCase = (
          name: 'datatypes-semantic-equivalence-within-type-1',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDF',
          recognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
          ],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/foo> <http://example.org/bar> "010"^^<http://www.w3.org/2001/XMLSchema#integer> .',
          result:
              '<http://example.org/foo> <http://example.org/bar> "10"^^<http://www.w3.org/2001/XMLSchema#integer> .',
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test(
      "As semantic-equivalence-within-type-1; the entailment works both ways.",
      () {
        final testCase = (
          name: 'datatypes-semantic-equivalence-within-type-2',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDF',
          recognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
          ],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/foo> <http://example.org/bar> "10"^^<http://www.w3.org/2001/XMLSchema#integer> .',
          result:
              '<http://example.org/foo> <http://example.org/bar> "010"^^<http://www.w3.org/2001/XMLSchema#integer> .',
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test("Members of different datatypes may be semantically equivalent.", () {
      final testCase = (
        name: 'datatypes-semantic-equivalence-between-datatypes',
        type: 'rdft:PositiveEntailmentTest',
        entailmentRegime: 'RDF',
        recognizedDatatypes: [
          Iri('http://www.w3.org/2001/XMLSchema#integer'),
          Iri('http://www.w3.org/2001/XMLSchema#decimal'),
        ],
        unrecognizedDatatypes: [],
        action:
            '<http://example.org/foo> <http://example.org/bar> "10"^^<http://www.w3.org/2001/XMLSchema#integer> .',
        result:
            '<http://example.org/foo> <http://example.org/bar> "10.0"^^<http://www.w3.org/2001/XMLSchema#decimal> .',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test(
      "Where sufficient DT knowledge is available, a range clash may be detected; the document then contains a contradiction.",
      () {
        final testCase = (
          name: 'datatypes-range-clash',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
            Iri('http://www.w3.org/2001/XMLSchema#string'),
          ],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/foo> <http://example.org/bar> "25"^^<http://www.w3.org/2001/XMLSchema#integer> .
<http://example.org/bar> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#string> .
''',
          result: false,
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test("datatypes-test008", () {
      // From decisions listed in
      // http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2002Oct/0098.html
      final testCase = (
        name: 'datatypes-test008',
        type: 'rdft:PositiveEntailmentTest',
        entailmentRegime: 'simple',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [],
        action: '''
<http://example.org/a> <http://example.org/b> "10" .
<http://example.org/c> <http://example.org/d> "10" .
''',
        result: '''
<http://example.org/a> <http://example.org/b> _:x .
<http://example.org/c> <http://example.org/d> _:x .
''',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test("datatypes-test009", () {
      // From decisions listed in
      // http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2002Oct/0098.html
      final testCase = (
        name: 'datatypes-test009',
        type: 'rdft:NegativeEntailmentTest',
        entailmentRegime: 'simple',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [
          Iri('http://www.w3.org/2001/XMLSchema#integer'),
        ],
        action: '''
<http://example.org/a> <http://example.org/b> "10" .
<http://example.org/c> <http://example.org/d> "10"^^<http://www.w3.org/2001/XMLSchema#integer> .
''',
        result: '''
<http://example.org/a> <http://example.org/b> _:x .
<http://example.org/c> <http://example.org/d> _:x .
''',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test("datatypes-test010", () {
      // From decisions listed in
      // http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2002Oct/0098.html
      final testCase = (
        name: 'datatypes-test010',
        type: 'rdft:PositiveEntailmentTest',
        entailmentRegime: 'RDFS',
        recognizedDatatypes: [Iri('http://www.w3.org/2001/XMLSchema#integer')],
        unrecognizedDatatypes: [],
        action: '''
<http://example.org/foo> <http://example.org/bar> "25" .
<http://example.org/bar> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#integer> .
''',
        result: false,
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test(
      "A plain literal denotes the same thing as its corresponding xsd:string, where one exists.",
      () {
        final testCase = (
          name: 'datatypes-plain-literal-and-xsd-string',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [Iri('http://www.w3.org/2001/XMLSchema#string')],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/foo> <http://example.org/bar> "a string" .',
          result:
              '<http://example.org/foo> <http://example.org/bar> "a string"^^<http://www.w3.org/2001/XMLSchema#string> .',
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test("rdfs:subPropertyOf has intensional semantics, not extensional.", () {
      final testCase = (
        name: 'horst-01-subPropertyOf-intensional',
        type: 'rdft:NegativeEntailmentTest',
        entailmentRegime: 'RDFS',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [],
        action: '''
<http://example.org/p> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#integer> .
<http://example.org/p> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> .
<http://example.org/q> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> .
<http://example.org/p> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#string> .
''',
        result: '''
<http://example.org/p> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://example.org/q> .
<http://example.org/p> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> .
''',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test("Test that ICEXT(I(rdfs:Literal)) is a subset of LV.", () {
      final testCase = (
        name: 'pfps-10-non-well-formed-literal-1',
        type: 'rdft:PositiveEntailmentTest',
        entailmentRegime: 'RDFS',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [],
        action: '<http://example.org/foo> <http://example.org/bar> "a" .',
        result: '''
<http://example.org/foo> <http://example.org/bar> _:x .
_:x <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Literal> .
''',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test(
      "An international URI ref and its %-escaped form label different nodes in the graph. No model theoretic relationship holds between them.",
      () {
        final testCase = (
          name: 'rdf-charmod-uris-test003',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDF',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/#André> <http://example.org/#owes> "2000" .',
          result:
              '<http://example.org/#Andr%C3%A9> <http://example.org/#owes> "2000" .',
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test(
      "An international URI ref and its %-escaped form label different nodes in the graph. No model theoretic relationship holds between them. (2)",
      () {
        final testCase = (
          name: 'rdf-charmod-uris-test004',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDF',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/#Andr%C3%A9> <http://example.org/#owes> "2000" .',
          result:
              '<http://example.org/#André> <http://example.org/#owes> "2000" .',
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test("Statement of the MT closure rule.", () {
      final testCase = (
        name: 'rdfms-seq-representation-test002',
        type: 'rdft:PositiveEntailmentTest',
        entailmentRegime: 'RDFS',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [],
        action:
            '<http://example.org/foo> <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1> <http://example.org/bar> .',
        result:
            '<http://www.w3.org/1999/02/22-rdf-syntax-ns#_1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#ContainerMembershipProperty> .',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test("Statement of the MT closure rule. (2)", () {
      final testCase = (
        name: 'rdfms-seq-representation-test003',
        type: 'rdft:PositiveEntailmentTest',
        entailmentRegime: 'RDFS',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [],
        action:
            '<http://example.org/a> <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1> <http://example.org/b> .',
        result:
            '<http://example.org/a> <http://www.w3.org/2000/01/rdf-schema#member> <http://example.org/b> .',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test("Statement of the MT closure rule. (3)", () {
      final testCase = (
        name: 'rdfms-seq-representation-test004',
        type: 'rdft:PositiveEntailmentTest',
        entailmentRegime: 'RDFS',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [],
        action:
            '<http://example.org/foo> <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1> <http://example.org/bar> .',
        result:
            '<http://www.w3.org/1999/02/22-rdf-syntax-ns#_1> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/01/rdf-schema#member> .',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test("Plain literals are distinguishable on the basis of language tags.", () {
      final testCase = (
        name: 'rdfms-xmllang-test007a',
        type: 'rdft:NegativeEntailmentTest',
        entailmentRegime: 'simple',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [],
        action:
            '<http://example.org/node> <http://example.org/property> "chat"@fr .',
        result:
            '<http://example.org/node> <http://example.org/property> "chat"@en .',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });

    test(
      "Plain literals are distinguishable on the basis of language tags. (2)",
      () {
        final testCase = (
          name: 'rdfms-xmllang-test007b',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'simple',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/node> <http://example.org/property> "chat"@en .',
          result:
              '<http://example.org/node> <http://example.org/property> "chat" .',
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test(
      "Plain literals are distinguishable on the basis of language tags. (3)",
      () {
        final testCase = (
          name: 'rdfms-xmllang-test007c',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'simple',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/node> <http://example.org/property> "chat" .',
          result:
              '<http://example.org/node> <http://example.org/property> "chat"@fr .',
        );

        final inputGraph = nTriplesCodec.decode(testCase.action);

        // TODO: Figure out what we are actually testing here
      },
    );

    test("rdfs-container-membership-superProperty-test001", () {
      // While it is a superproperty, `_:a <rdfs:contains (@@member?)> _:b .`
      // does NOT entail `_:a <rdf:_n> _:b . for any _n.`
      final testCase = (
        name: 'rdfs-container-membership-superProperty-test001',
        type: 'rdft:NegativeEntailmentTest',
        entailmentRegime: 'RDFS',
        recognizedDatatypes: [],
        unrecognizedDatatypes: [],
        action:
            '<http://example/stuff#something> <http://www.w3.org/2000/01/rdf-schema#member> <http://example/stuff#somethingElse> .',
        result:
            '<http://example/stuff#something> <http://www.w3.org/1999/02/22-rdf-syntax-ns#_1> <http://example/stuff#somethingElse> .',
      );

      final inputGraph = nTriplesCodec.decode(testCase.action);

      // TODO: Figure out what we are actually testing here
    });
  });
}
