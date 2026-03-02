# Implementation Plan - Replace hand-rolled IRI with `package:iri` (now local copy)

This plan outlines the steps to replace the internal IRI implementation with a robust version derived from `package:iri`, brought into the project to fix canonicalization issues.

## Journal
* **Phase 1: Baseline and Dependency Setup**
    * Ran all tests. Found 3 pre-existing failures in `test/semantics_test.dart` related to RDF 1.2 and reification/literals.
    * Added `iri: ^0.2.0` to `pubspec.yaml`.
    * Ran `analyze_files`, no new issues were introduced.
* **Phase 2: Local Integration and Fix**
    * Reached out to user who requested bringing the `Iri` class from the package into `lib/src/util/iri.dart` directly.
    * Identified that `package:iri` was over-decoding percent-encodings in its `toString()` and component getters (e.g., decoding `%25` to `%`), which broke W3C tests expecting canonical forms.
    * Implemented `_decodeIriComponent` in `lib/src/util/iri.dart` to selectively decode non-ASCII UTF-8 sequences while preserving ASCII percent-encodings.
    * Updated `lib/src/model/iri.dart` to wrap the local `impl.Iri`.
    * Verified that `test/codec/n_triples/n_triples_w3c_test.dart` now passes its canonicalization tests.
    * Swapped `package:iri` dependency for direct dependencies on `punycoder`, `unorm_dart`, and `meta`.

## Phase 1: Baseline and Dependency Setup (COMPLETED)
- [x] Run all tests to ensure the project is in a good state before starting modifications.
- [x] Add `iri: ^0.2.0` to `pubspec.yaml` using the `pub` tool.
- [x] Run `analyze_files` to ensure no immediate issues after adding the dependency.
- [x] Update the Journal with any findings.
- [x] Use `git diff` to verify changes, propose a commit message, and wait for approval.

## Phase 2: Local Integration and Fix
- [x] Fetch `iri_base.dart` from `package:iri`.
- [x] Write to `lib/src/util/iri.dart` and refactor for project needs.
- [x] Implement selective decoding (`_decodeIriComponent`) to fix percent-encoding issues.
- [x] Modify `lib/src/model/iri.dart` to wrap local `impl.Iri`.
- [x] Add `punycoder`, `unorm_dart`, and `meta` to `pubspec.yaml`.
- [x] Remove `iri` from `pubspec.yaml`.
- [x] Run `analyze_files` and `run_tests` to verify the fix.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [x] Run the `dart_fix` tool to clean up the code.
- [x] Run the `analyze_files` tool one more time and fix any issues.
- [x] Run any tests to make sure they all pass.
- [x] Run `dart_format` to make sure that the formatting is correct.
- [ ] Use `git diff` to verify the changes and create a suitable commit message.
- [ ] Wait for approval.

## Phase 3: Refactor Callers and Cleanup
- [ ] Search for all occurrences of `toPercentEncodedUri()` in the codebase and replace with `toUri()`.
- [ ] Identify and fix any code that assumes `Iri` is a `Uri` (e.g., passing `Iri` where `Uri` is expected) by adding `.toUri()`.
- [ ] Update documentation references to use the new `Iri` class.

## Phase 4: Finalization and Documentation
- [ ] Update `GEMINI.md` to reflect the new architecture (local `util/iri.dart` based on RFC 3987).
- [ ] Run all tests one last time.
- [ ] Ask the user to inspect the package and say if they are satisfied.
