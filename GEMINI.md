# rdf_dart - Project Context

## Project Overview
**rdf_dart** is a comprehensive implementation of the **RDF 1.2** standard (Concepts and Abstract Data Model) for the Dart programming language. It aims to provide modern RDF support, including compatibility with **RDF 1.1** and new features like **RDF-star** (Triple Terms).

## Key Files & Directories

*   **`lib/`**: Contains the main source code.
    *   **`rdf_dart.dart`**: Main library export file.
    *   **`src/model/`**: Core RDF data model definitions (IRI, Literal, BlankNode, Triple, Quad, Graph, Dataset).
    *   **`src/codecs/`**: Parsers and serializers (Turtle, N-Triples).
    *   **`src/reasoner/`**: Implementation of semantic reasoning (RDFS, Entailment).
    *   `src/vocabulary/`: Type-safe constants for RDF, RDFS, and XSD.
*   **`example/`**: Usage examples.
    *   `rdf_dart_example.dart`: Basic triple creation example.
*   **`test/`**: Unit and compliance tests.
    *   Contains W3C test suites under `test/codec/*/w3c`.
*   **`refdocs/`**: Reference documentation (HTML files of RDF specifications).
*   **`ntriples.bnf`, `turtle.bnf`**: Grammar files for the RDF serialization formats.
*   **`pubspec.yaml`**: Project metadata and dependencies.
*   **`analysis_options.yaml`**: Linting configuration (uses `package:lints/recommended.yaml`).

## Development Workflow

### Prerequisites
*   Dart SDK version `^3.10.1`.

### Setup
Get dependencies:
```bash
dart pub get
```

### Running Examples
Run the provided example to see basic usage:
```bash
dart run example/rdf_dart_example.dart
```

### Testing
Run the full test suite:
```bash
dart test
```

### Linting & Analysis
Check for code style and static analysis issues:
```bash
dart analyze
```
Format code:
```bash
dart format .
```

## Architecture & Design

The library is structured around the core concepts of RDF 1.2:
*   **Term Hierarchy**: `Term` is the base class, with implementations for `Iri`, `Literal`, `BlankNode`, and `TripleTerm` (for RDF-star). `Iri` relies on a robust local implementation (`lib/src/util/iri.dart`) based on RFC 3987 for Internationalized Resource Identifiers.
*   **Statements**: `Triple` (Subject, Predicate, Object) and `Quad` (Subject, Predicate, Object, Graph Name).
*   **Collections**: `Graph` (set of triples) and `Dataset` (default graph + named graphs).
*   **Codecs**: Implements Dart's `Converter` pattern (Encoder/Decoder) for parsing and serializing formats like Turtle and N-Triples. The `TurtleEncoder` is a sophisticated implementation that supports prefixes, base URIs, grouping, blank node inlining, and RDF 1.2 features (Triple Terms, Annotations).

## Dependencies

*   **`intl`**: Internationalization support.
*   **`xsd`**: XML Schema Datatypes support (sourced via Git).
*   **`lints`**: Standard Dart lints (dev dependency).
*   **`test`**: Testing framework (dev dependency).
