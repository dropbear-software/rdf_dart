# RDF for Dart

A comprehensive implementation of the **RDF 1.2** standard for the Dart programming language.

## Overview

This package aims to provide a complete and compliant implementation of the [RDF 1.2 Concepts and Abstract Data Model](https://www.w3.org/TR/rdf12-concepts/) and related specifications. It is designed to modernize RDF support in Dart, incorporating the latest advancements from the W3C, including support for **RDF-star** (Triple Terms).

This implementation will also be fully compatible with **RDF 1.1**.

## Features

- **RDF 1.2 Data Model**: Full support for IRIs, Literals, Blank Nodes, and Triple Terms.
- **Datasets**: Native support for RDF Datasets (Default Graph + Named Graphs).
- **Strong Typing**: leveraged Dart's type system for correct RDF term representation.
- **Modern Standards**: Built to align with specifications like `xsd:duration` and `xsd:dayTimeDuration`.
- **Serialization**: Fully compliant RDF 1.2 Turtle and N-Triples codecs.

## Usage

### Turtle Serialization

The `TurtleEncoder` provides human-readable, terse output with support for prefixes, base URIs, and RDF 1.2 features like annotations and triple terms.

```dart
import 'package:rdf_dart/rdf_dart.dart';

void main() {
  final s = Iri('http://example.org/alice');
  final p = Iri('http://xmlns.com/foaf/0.1/name');
  final o = Literal('Alice');

  final triples = [Triple(subject: s, predicate: p, object: o)];

  final turtle = TurtleEncoder(
    prefixes: {'foaf': 'http://xmlns.com/foaf/0.1/', 'ex': 'http://example.org/'},
    baseUri: 'http://example.org/',
  ).convert(triples);

  print(turtle);
  // Output:
  // PREFIX ex: <http://example.org/>
  // PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  // 
  // ex:alice
  //     foaf:name "Alice" .
}
```

## Roadmap

- [ ] Abstract Data Model (IRIs, Literals, Blank Nodes, Triple Terms)
- [ ] RDF Datasets
- [ ] Serialization (Turtle, N-Triples, etc.)
- [ ] Semantics & Reasoning (Entailment)

