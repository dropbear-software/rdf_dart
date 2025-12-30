# Implementation Plan: RDF 1.2 Turtle Serializer

This plan outlines the steps to implement a fully compliant RDF 1.2 Turtle serializer for the `rdf_dart` package.

## Journal
- **Phase 0:** Initial state. Analysis complete.
- **Phase 1:** Completed basic setup. Created `_TurtleWriter` and updated `TurtleEncoder`. Implemented basic grouping by subject and predicate. Verified with new `turtle_encoder_test.dart`.
- **Phase 2:** Implemented Prefix and Base URI support. Added `_relativizeIri` and `_isValidLocalName` logic. Updated encoder to emit directives. Verified with tests.
- **Phase 3:** Implemented Blank Node inlining and Collections support. Added `_TurtleGraphAnalyzer` for preprocessing. Updated serializer to use `[ ... ]` and `( ... )` syntax. Verified with tests.
- **Phase 4:** Implemented RDF 1.2 features. Added support for `TripleTerm` serialization and `{| ... |}` annotation syntax. Updated analyzer to detect reifiers. Verified with tests.

## Phase 1: Preparation & Basic Setup
- [x] Run all existing tests to ensure a clean baseline.
- [x] Create `TurtleConfig` class (or just use named parameters) to hold configuration state (prefixes, base URI).
- [x] Create a `TurtleWriter` helper class to manage `StringBuffer`, indentation, and basic token writing.
- [x] Update `TurtleEncoder` to accept configuration and initialize the writer.
- [x] Implement a basic "Grouped" serializer: Group triples by Subject, then Predicate. Output simple blocks using `;` and `,`. (No prefixes/nesting yet).
- [x] Verify: Run existing tests. The output format will change from N-Triples to basic Turtle, so tests asserting exact string matches might fail and need updates.

## Phase 2: Prefix and Base URI Support
- [x] Implement `_relativizeIri` logic in `TurtleWriter`.
    - [x] Handle Base URI stripping.
    - [x] Handle Prefix replacement (Map check).
    - [x] Validate generated `prefix:localName` against Turtle grammar (PN_LOCAL) to ensure validity. Fallback to `<...>` if invalid characters are present.
- [x] Update `TurtleEncoder` to output `@base` and `@prefix` directives at the start.
- [x] Add unit tests specifically for prefix shrinking and base URI handling.

## Phase 3: Blank Node Nesting and Collections
- [x] Implement a `GraphAnalyzer` (or similar helper) to preprocess the input graph.
    - [x] Count reference occurrences for each Blank Node.
    - [x] Detect RDF List structures (`rdf:first`, `rdf:rest`, `rdf:nil`).
- [x] Update serialization logic to use `[ ... ]` for blank nodes with single reference count (that aren't cyclic).
- [x] Update serialization logic to use `( ... )` for valid RDF lists.
- [x] Add unit tests for nesting and collections.

## Phase 4: RDF 1.2 Features (Triple Terms & Annotations)
- [x] Implement serialization for `TripleTerm` objects using `<<( ... )>>` syntax.
- [x] Implement logic to detect reified triples (`rdf:reifies`).
- [x] Support `{| ... |}` annotation syntax for reifiers that are used as subjects of metadata assertions.
- [x] Verify compliance with RDF 1.2 syntax tests (if available) or create specific scenarios covering Triple Terms.

## Phase 5: Finalization & Polish
- [ ] Review all TODOs.
- [ ] Ensure formatting (indentation, newlines) matches the "pretty" goals (objects on new lines, etc.).
- [ ] Run `dart_fix` and `dart_format`.
- [ ] Run full test suite.
- [ ] Update `README.md` to document the new serializer features and configuration options.
- [ ] Update `GEMINI.md`.
