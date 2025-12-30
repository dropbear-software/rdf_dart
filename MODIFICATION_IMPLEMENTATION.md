# Implementation Plan: RDF Vocabulary Constants

This plan outlines the steps to introduce type-safe vocabulary constants and refactor the `rdf_dart` codebase to use them.

## Journal
- **Phase 0:** Initial state. Design approved.
- **Phase 1:** Vocabulary definitions created (`lib/src/vocabulary/`). `Rdf`, `Rdfs`, `Xsd` classes implemented with `static final` fields to support non-const `Iri` constructor. Exported via `vocabulary.dart` and `rdf_dart.dart`. Verified with `dart analyze`.
- **Phase 2:** Refactored `rdfs_reasoner.dart` and `entailment_solver.dart` to use vocabulary constants. Refactored `literal.dart` to use `Rdf.langString`, `Rdf.dirLangString`, and `Xsd.string` for default datatypes. Verified with existing tests.
- **Phase 3:** Refactored `turtle_encoder.dart` and `n_triples_encoder.dart`. Refactoring `turtle_decoder.dart` (encountered truncation issue, retrying with full file read).

## Phase 1: Create Vocabulary Definitions
- [x] Create `lib/src/vocabulary/` directory.
- [x] Create `lib/src/vocabulary/rdf.dart` with `Rdf` class and standard RDF constants.
- [x] Create `lib/src/vocabulary/rdfs.dart` with `Rdfs` class and standard RDFS constants.
- [x] Create `lib/src/vocabulary/xsd.dart` with `Xsd` class and standard XSD constants.
- [x] Create `lib/src/vocabulary/vocabulary.dart` to export the above files.
- [x] Export `lib/src/vocabulary/vocabulary.dart` from `lib/rdf_dart.dart`.
- [x] Verify: Run `dart analyze` to ensure new files are valid.

## Phase 2: Refactor Code (Reasoner & Models)
- [x] Refactor `lib/src/reasoner/rdfs_reasoner.dart` to use new constants.
- [x] Refactor `lib/src/reasoner/entailment_solver.dart` to use new constants.
- [x] Refactor `lib/src/model/literal.dart` to use new constants (especially for default datatype checks).
- [x] Verify: Run existing tests to ensure no regressions in reasoning logic.

## Phase 3: Refactor Code (Codecs)
- [x] Refactor `lib/src/codecs/turtle/turtle_encoder.dart` (Turtle encoder) to use new constants (e.g., `rdf:type` detection).
- [x] Refactor `lib/src/codecs/n-triples/n_triples_encoder.dart` (N-Triples encoder).
- [x] Refactor `lib/src/codecs/turtle/turtle_decoder.dart` (Turtle decoder).
- [x] Verify: Run codec tests.

## Phase 4: Finalization & Cleanup
- [x] Refactor unit tests where applicable to use new constants (optional but good for consistency).
- [x] Review all files for any remaining hardcoded strings for standard namespaces.
- [x] Run `dart_fix` and `dart_format`.
- [x] Run full test suite.
- [ ] Update `README.md` to document the new `Rdf`, `Rdfs`, and `Xsd` classes.
- [ ] Update `GEMINI.md`.