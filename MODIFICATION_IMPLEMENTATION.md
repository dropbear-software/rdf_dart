# Implementation Plan - Replace hand-rolled IRI with `package:iri`

This plan outlines the steps to replace the internal IRI implementation with `package:iri`.

## Journal
* **Phase 1: Baseline and Dependency Setup**
    * Ran all tests. Found 3 pre-existing failures in `test/semantics_test.dart` related to RDF 1.2 and reification/literals.
    * Added `iri: ^0.2.0` to `pubspec.yaml`.
    * Ran `analyze_files`, no new issues were introduced.

## Phase 1: Baseline and Dependency Setup
- [x] Run all tests to ensure the project is in a good state before starting modifications.
- [x] Add `iri: ^0.2.0` to `pubspec.yaml` using the `pub` tool.
- [x] Run `analyze_files` to ensure no immediate issues after adding the dependency.
- [x] Update the Journal with any findings.
- [x] Use `git diff` to verify changes, propose a commit message, and wait for approval.

## Phase 2: Implement Wrapped `Iri` in `lib/src/model/iri.dart`
- [ ] Modify `lib/src/model/iri.dart` to wrap `package:iri.Iri`.
- [ ] Implement the following constructors by delegating to `iri_pkg.Iri`:
    - `factory Iri(String value)`
    - `static Iri parse(String value)`
    - `Iri.fromUri(Uri uri)` (Note: will lose `const` if `iri_pkg.Iri` doesn't support it).
    - `factory Iri.fromComponents(...)`
- [ ] Implement delegation for core properties and methods:
    - `scheme`, `host`, `path`, `query`, `fragment`, `userInfo`, `port`, `pathSegments`, `queryParameters`.
    - `toString()`, `toUri()`, `resolve(String reference)`, `replace(...)`.
- [ ] Ensure RDF interfaces are preserved: `SubjectTerm`, `PredicateTerm`, `ObjectTerm`, `GraphName`.
- [ ] Maintain `isGround` returning `true`.
- [ ] Implement `operator ==` and `hashCode` using the internal `_iri` instance.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart_fix` tool to clean up the code.
- [ ] Run the `analyze_files` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart_format` to make sure that the formatting is correct.
- [ ] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see if anything has changed.
- [ ] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state in the Journal.
- [ ] Use `git diff` to verify the changes and create a suitable commit message.
- [ ] Wait for approval.

## Phase 3: Refactor Callers and Cleanup
- [ ] Search for all occurrences of `toPercentEncodedUri()` in the codebase and replace with `toUri()`.
- [ ] Identify and fix any code that assumes `Iri` is a `Uri` (e.g., passing `Iri` where `Uri` is expected) by adding `.toUri()`.
- [ ] Delete `lib/src/util/iri.dart`.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart_fix` tool to clean up the code.
- [ ] Run the `analyze_files` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart_format` to make sure that the formatting is correct.
- [ ] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see if anything has changed.
- [ ] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state in the Journal.
- [ ] Use `git diff` to verify the changes and create a suitable commit message.
- [ ] Wait for approval.

## Phase 4: Finalization and Documentation
- [ ] Update `README.md` if any user-facing changes were made (though API should remain mostly the same).
- [ ] Update `GEMINI.md` to reflect the new architecture (removal of `util/iri.dart` and use of `package:iri`).
- [ ] Run all tests one last time.
- [ ] Ask the user to inspect the package and say if they are satisfied.
- [ ] Update the Journal with final thoughts.

---
**Note:** After completing a task, if you added any TODOs to the code or didn't fully implement anything, make sure to add new tasks so that you can come back and complete them later.
