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

## Roadmap

- [ ] Abstract Data Model (IRIs, Literals, Blank Nodes, Triple Terms)
- [ ] RDF Datasets
- [ ] Serialization (Turtle, N-Triples, etc.)
- [ ] Semantics & Reasoning (Entailment)

## Dependencies

This project will leverage community-standard packages where appropriate, including:
- `iri` for strictly compliant IRI handling.
- Custom XSD datatype handling for robust literal value conversion.
