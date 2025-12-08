import 'package:rdf_dart/rdf_dart.dart';
import 'package:rdf_dart/src/reasoner/entailment_solver.dart';
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
  group("RDF Schema and Semantics tests", () {
    final nTriplesCodec = NTriplesCodec();

    Graph createGraph(Iterable<Triple> triples) {
      final g = InMemoryGraph();
      triples.forEach(g.add);
      return g;
    }

    void runTestCase(dynamic testCase) {
      // 1. Parse Input Graph
      final inputGraph = createGraph(
        nTriplesCodec.decode(testCase.action as String),
      );

      // 2. Configure Reasoner
      final regimeName = testCase.entailmentRegime as String;
      final regime = EntailmentRegime.values.firstWhere(
        (e) => e.name.toLowerCase() == regimeName.toLowerCase(),
        orElse: () => EntailmentRegime.simple,
      );

      final recDatatypes = (testCase.recognizedDatatypes as List)
          .cast<Iri>()
          .toSet();

      // 3. Expand Input Graph (Deductive Closure)
      final reasoner = RdfsReasoner(
        inputGraph,
        regime: regime,
        recognizedDatatypes: recDatatypes,
      );
      reasoner.apply();

      // 4. Check Result
      final result = testCase.result;

      if (result == false) {
        return;
      }

      if (result is String) {
        final outputGraph = createGraph(nTriplesCodec.decode(result));
        final solver = EntailmentSolver();
        final doesEntail = solver.entails(inputGraph, outputGraph);

        if (testCase.type == 'rdft:PositiveEntailmentTest') {
          expect(
            doesEntail,
            isTrue,
            reason: 'Expected input to entail output under $regimeName',
          );
        } else if (testCase.type == 'rdft:NegativeEntailmentTest') {
          expect(
            doesEntail,
            isFalse,
            reason: 'Expected input to NOT entail output under $regimeName',
          );
        }
      }
    }

    group('RDF 1.1', () {
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
          runTestCase(testCase);
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

          runTestCase(testCase);
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

          runTestCase(testCase);
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

          runTestCase(testCase);
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
          runTestCase(testCase);
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

          runTestCase(testCase);
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

        runTestCase(testCase);
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

          runTestCase(testCase);
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

        runTestCase(testCase);
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

        runTestCase(testCase);
      });

      test("datatypes-test010", () {
        // From decisions listed in
        // http://lists.w3.org/Archives/Public/w3c-rdfcore-wg/2002Oct/0098.html
        final testCase = (
          name: 'datatypes-test010',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#integer'),
          ],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/foo> <http://example.org/bar> "25" .
<http://example.org/bar> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2001/XMLSchema#integer> .
''',
          result: false,
        );

        runTestCase(testCase);
      });

      test(
        "A plain literal denotes the same thing as its corresponding xsd:string, where one exists.",
        () {
          final testCase = (
            name: 'datatypes-plain-literal-and-xsd-string',
            type: 'rdft:PositiveEntailmentTest',
            entailmentRegime: 'RDFS',
            recognizedDatatypes: [
              Iri('http://www.w3.org/2001/XMLSchema#string'),
            ],
            unrecognizedDatatypes: [],
            action:
                '<http://example.org/foo> <http://example.org/bar> "a string" .',
            result:
                '<http://example.org/foo> <http://example.org/bar> "a string"^^<http://www.w3.org/2001/XMLSchema#string> .',
          );

          runTestCase(testCase);
        },
      );

      test(
        "rdfs:subPropertyOf has intensional semantics, not extensional.",
        () {
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

          runTestCase(testCase);
        },
      );

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

          runTestCase(testCase);
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

          runTestCase(testCase);
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

        runTestCase(testCase);
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

        runTestCase(testCase);
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

        runTestCase(testCase);
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

        runTestCase(testCase);
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

          runTestCase(testCase);
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

          runTestCase(testCase);
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

        runTestCase(testCase);
      });

      test("rdfs-domain-and-range-intensionality-range", () {
        // RDF Semantics defines rdfs:range to have an intensional
        // reading. However, semantic extensions may give an extensional
        // reading to range. The premise/conclusion pair is a
        // non-entailment for RDFS reasoning, but may hold in semantic
        // extensions.
        final testCase = (
          name: 'rdfs-domain-and-range-intensionality-range',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#A> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Class> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#A> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#B> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#prop> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Property> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#B> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Class> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#prop> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#A> .
''',
          result: '''
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#B> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Class> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#prop> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Property> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#prop> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises005.rdf#B> .
''',
        );

        runTestCase(testCase);
      });

      test("rdfs-domain-and-range-intensionality-domain", () {
        // RDF Semantics defines rdfs:range to have an intensional
        // reading of domain. However, semantic extensions may give an
        // extensional reading to domain. The premise/conclusion pair is
        // a non-entailment for RDFS reasoning, but may hold in semantic
        // extensions.
        final testCase = (
          name: 'rdfs-domain-and-range-intensionality-domain',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#A> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Class> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#B> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Class> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#prop> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Property> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#A> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#B> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#prop> <http://www.w3.org/2000/01/rdf-schema#domain> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#A> .
''',
          result: '''
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#prop> <http://www.w3.org/2000/01/rdf-schema#domain> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#B> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#B> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Class> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-domain-and-range/premises006.rdf#prop> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Property> .
''',
        );

        runTestCase(testCase);
      });

      test("rdfs-entailment-test001", () {
        // Indicating a simple inconsistency drawn from RDFS. RDFS can
        // only produce inconsistencies through badly-formed XMLLiteral
        // datatypes.
        final testCase = (
          name: 'rdfs-entailment-test001',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/prop> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral> .
<http://example.org/foo> <http://example.org/prop> "<"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral> .
''',
          result: false,
        );

        runTestCase(testCase);
      });

      test("rdfs-entailment-test001", () {
        // Indicating a simple inconsistency drawn from RDFS. RDFS can
        // only produce inconsistencies through badly-formed XMLLiteral
        // datatypes.
        final testCase = (
          name: 'rdfs-entailment-test001',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [
            Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral'),
          ],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/prop> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral> .
<http://example.org/foo> <http://example.org/prop> "<"^^<http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral> .
''',
          result: false,
        );

        runTestCase(testCase);
      });

      test("Datatype clashes can occur in RDFS entailment.", () {
        // Indicating a simple inconsistency drawn from RDFS. RDFS can
        // only produce inconsistencies through badly-formed XMLLiteral
        // datatypes.
        final testCase = (
          name: 'rdfs-entailment-test002',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [
            Iri('http://www.w3.org/2001/XMLSchema#string'),
            Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#langString'),
          ],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/prop> <http://www.w3.org/2000/01/rdf-schema#range> <http://www.w3.org/1999/02/22-rdf-syntax-ns#langString> .
<http://example.org/foo> <http://example.org/prop> "flargh"^^<http://www.w3.org/2001/XMLSchema#string> .
''',
          result: false,
        );

        runTestCase(testCase);
      });

      test("rdfs-no-cycles-in-subClassOf-test001", () {
        // Cycles are permitted in subClassOf; therefore, no error occurs
        // and the following entailment holds trivially.
        final testCase = (
          name: 'rdfs-no-cycles-in-subClassOf-test001',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#X> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#X> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#A> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#B> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#B> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#A> .
''',
          result: '''
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#A> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#B> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#B> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#A> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#X> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subClassOf/test001#X> .
''',
        );

        runTestCase(testCase);
      });

      test("rdfs-no-cycles-in-subPropertyOf-test001", () {
        // Cycles are permitted in subPropertyOf; therefore, no error
        // occurs and the following entailment holds trivially.
        final testCase = (
          name: 'rdfs-no-cycles-in-subPropertyOf-test001',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#A> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#B> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#X> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#X> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#B> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#A> .
''',
          result: '''
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#A> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#B> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#B> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#A> .
<http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#X> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://www.w3.org/2000/10/rdf-tests/rdfcore/rdfs-no-cycles-in-subPropertyOf/test001#X> .
''',
        );

        runTestCase(testCase);
      });

      test("rdfs-subClassOf-a-Property-test001", () {
        // an instance of the Property class may have an rdfs:subClassOf
        // property. the meaning of such a property is defined by the
        // model theory. The wording of the formal resolution is a bit
        // bare, so let me add a few words of explanation. What this
        // means is that a resource can be both a class and a property.
        // This test is encoded as follows: a Property may have a
        // subclass (that is, such an RDF graph is satisfiable)
        final testCase = (
          name: 'rdfs-subClassOf-a-Property-test001',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/foo> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> .
<http://example.org/bar> <http://www.w3.org/2000/01/rdf-schema#subClassOf> <http://example.org/foo> .
''',
          result: false,
        );

        runTestCase(testCase);
      });

      test("rdfs-subPropertyOf-semantics-test001", () {
        // The inheritance semantics of the subPropertyOf relationship
        // needs to be clarified. => subProperties inherit conjunctively
        // the domain and range of their superproperties
        final testCase = (
          name: 'rdfs-subPropertyOf-semantics-test001',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/bar> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> .
<http://example.org/bas> <http://www.w3.org/2000/01/rdf-schema#subPropertyOf> <http://example.org/bar> .
<http://example.org/bar> <http://www.w3.org/2000/01/rdf-schema#domain> <http://example.org/Domain1> .
<http://example.org/bas> <http://www.w3.org/2000/01/rdf-schema#domain> <http://example.org/Domain2> .
<http://example.org/bar> <http://www.w3.org/2000/01/rdf-schema#range> <http://example.org/Range1> .
<http://example.org/bas> <http://www.w3.org/2000/01/rdf-schema#range> <http://example.org/Range2> .
<http://example.org/baz1> <http://example.org/bas> <http://example.org/baz2> .
''',
          result: '''
<http://example.org/baz1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/Domain1> .
<http://example.org/baz1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/Domain2> .
<http://example.org/baz2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/Range1> .
<http://example.org/baz2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://example.org/Range2> .
''',
        );

        runTestCase(testCase);
      });

      test("statement-entailment-test001", () {
        // RDFCore WG RESOLVED that a reified statement was a stating,
        // not a statement. The following entailment does not, therefore, hold.
        final testCase = (
          name: 'statement-entailment-test001',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDF',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/stmt1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement> .
<http://example.org/stmt1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#subject> <http://example.org/subject> .
<http://example.org/stmt1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate> <http://example.org/predicate> .
<http://example.org/stmt1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#object> <http://example.org/object> .

<http://example.org/stmt2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement> .
<http://example.org/stmt2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#subject> <http://example.org/subject> .
<http://example.org/stmt2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate> <http://example.org/predicate> .
<http://example.org/stmt2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#object> <http://example.org/object> .

<http://example.org/stmt1> <http://example.org/property> <http://example.org/foo> .
''',
          result:
              '<http://example.org/stmt2> <http://example.org/property> <http://example.org/foo> .',
        );

        runTestCase(testCase);
      });

      test("statement-entailment-test002", () {
        // RDFCore WG RESOLVED that a statement does NOT entail its
        // reification. The following entailment does not, therefore, hold.
        final testCase = (
          name: 'statement-entailment-test002',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDF',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/subj> <http://example.org/prop> <http://example.org/obj> .',
          result: '''
_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement> .
_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#subject> <http://example.org/subj> .
_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate> <http://example.org/prop> .
_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#object> <http://example.org/obj> .
''',
        );

        runTestCase(testCase);
      });

      test("statement-entailment-test003", () {
        // RDFCore WG RESOLVED that a reified statement was a stating,
        // not a statement. The following entailment does not, therefore,
        // hold. This is the same as test001, but using RDFS-entailment.
        final testCase = (
          name: 'statement-entailment-test003',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '''
<http://example.org/stmt1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement> .
<http://example.org/stmt1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#subject> <http://example.org/subject> .
<http://example.org/stmt1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate> <http://example.org/predicate> .
<http://example.org/stmt1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#object> <http://example.org/object> .

<http://example.org/stmt2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement> .
<http://example.org/stmt2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#subject> <http://example.org/subject> .
<http://example.org/stmt2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate> <http://example.org/predicate> .
<http://example.org/stmt2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#object> <http://example.org/object> .

<http://example.org/stmt1> <http://example.org/property> <http://example.org/foo> .
''',
          result:
              '<http://example.org/stmt2> <http://example.org/property> <http://example.org/foo> .',
        );

        runTestCase(testCase);
      });

      test("statement-entailment-test004", () {
        // RDFCore WG RESOLVED that a statement does NOT entail its
        // reification. The following entailment does not, therefore,
        // hold. This is the same as test002, but using RDFS-entailment.
        final testCase = (
          name: 'statement-entailment-test004',
          type: 'rdft:NegativeEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action:
              '<http://example.org/subj> <http://example.org/prop> <http://example.org/obj> .',
          result: '''
_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement> .
_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#subject> <http://example.org/subj> .
_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate> <http://example.org/prop> .
_:r <http://www.w3.org/1999/02/22-rdf-syntax-ns#object> <http://example.org/obj> .
''',
        );

        runTestCase(testCase);
      });

      test("The case of the language tag is not significant.", () {
        final testCase = (
          name: 'tex-01-language-tag-case-1',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDF',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '_:ub2bL0C1 <http://example.org/prop> "a"@en-us .',
          result: '_:ub2bL0C1 <http://example.org/prop> "a"@en-US .',
        );

        runTestCase(testCase);
      });

      test("The case of the language tag is not significant. (2)", () {
        final testCase = (
          name: 'tex-01-language-tag-case-2',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDF',
          recognizedDatatypes: [],
          unrecognizedDatatypes: [],
          action: '_:ub2bL0C1 <http://example.org/prop> "a"@en-US .',
          result: '_:ub2bL0C1 <http://example.org/prop> "a"@en-us .',
        );

        runTestCase(testCase);
      });

      test(
        "A well-formed typed literal is not related to an ill-formed literal. Even if they only differ by whitespace.",
        () {
          final testCase = (
            name: 'xmlsch-02-whitespace-facet-1',
            type: 'rdft:NegativeEntailmentTest',
            entailmentRegime: 'RDFS',
            recognizedDatatypes: [Iri('http://www.w3.org/2001/XMLSchema#int')],
            unrecognizedDatatypes: [],
            action:
                '<http://www.example.org/a> <http://example.org/prop> "3"^^<http://www.w3.org/2001/XMLSchema#int> .',
            result:
                '<http://www.example.org/a> <http://example.org/prop> " 3 "^^<http://www.w3.org/2001/XMLSchema#int> .',
          );

          runTestCase(testCase);
        },
      );

      test(
        "A well-formed typed literal is not related to an ill-formed literal. Even if they only differ by whitespace. (2)",
        () {
          final testCase = (
            name: 'xmlsch-02-whitespace-facet-2',
            type: 'rdft:PositiveEntailmentTest',
            entailmentRegime: 'RDFS',
            recognizedDatatypes: [Iri('http://www.w3.org/2001/XMLSchema#int')],
            unrecognizedDatatypes: [],
            action:
                '<http://www.example.org/a> <http://example.org/prop> " 3 "^^<http://www.w3.org/2001/XMLSchema#int> .',
            result: false,
          );

          runTestCase(testCase);
        },
      );

      test("A simple test for well-formedness of a typed literal.", () {
        final testCase = (
          name: 'xmlsch-02-whitespace-facet-3',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [Iri('http://www.w3.org/2001/XMLSchema#int')],
          unrecognizedDatatypes: [],
          action:
              '<http://www.example.org/a> <http://example.org/prop> "3"^^<http://www.w3.org/2001/XMLSchema#int> .',
          result: '''
_:ub2bL3C54 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Literal> .
<http://www.example.org/a> <http://example.org/prop> _:ub2bL3C54 .
''',
        );

        runTestCase(testCase);
      });

      test("An integer with whitespace is ill-formed.", () {
        final testCase = (
          name: 'xmlsch-02-whitespace-facet-4',
          type: 'rdft:PositiveEntailmentTest',
          entailmentRegime: 'RDFS',
          recognizedDatatypes: [Iri('http://www.w3.org/2001/XMLSchema#int')],
          unrecognizedDatatypes: [],
          action:
              '<http://www.example.org/a> <http://example.org/prop> " 3 "^^<http://www.w3.org/2001/XMLSchema#int> .',
          result: false,
        );

        runTestCase(testCase);
      });
    });

    group('RDF 1.2', () {
      test(
        'Multiple occurrences of the same triple term are the same domain element.',
        () {
          final testCase = (
            name: 'all-identical-triple-terms-are-the-same',
            type: 'rdft:PositiveEntailmentTest',
            entailmentRegime: 'simple',
            recognizedDatatypes: [],
            unrecognizedDatatypes: [],
            action:
                '<http://example.com/ns#a1> <http://example.com/ns#p1> <<( <http://example.com/ns#a> <http://example.com/ns#b> <http://example.com/ns#c> )>> .',
            result:
                '<http://example.com/ns#a1> <http://example.com/ns#p1> <<( <http://example.com/ns#a> <http://example.com/ns#b> <http://example.com/ns#c> )>> .',
          );
          runTestCase(testCase);
        },
      );
    });
  });
}
