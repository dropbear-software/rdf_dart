# Design for replacing hand-rolled IRI implementation with `package:iri`

## Overview
The goal is to replace the custom IRI implementation in `rdf_dart` (`lib/src/util/iri.dart` and `lib/src/model/iri.dart`) with the dedicated `package:iri` from pub.dev. This will simplify the codebase, improve RFC 3987 compliance, and leverage a well-maintained community package.

## Detailed Analysis
The existing implementation is split into:
1.  `lib/src/util/iri.dart`: A base class `Iri` that `implements Uri` and wraps a `Uri`. It provides manual decoding of percent-encoded Unicode characters.
2.  `lib/src/model/iri.dart`: An RDF-specific wrapper `Iri` that extends the utility base class and implements RDF term interfaces (`SubjectTerm`, `PredicateTerm`, `ObjectTerm`, `GraphName`).

`package:iri` provides a similar `Iri` class that handles Unicode normalization (NFKC) and provides accessors for both Unicode-decoded and percent-encoded components. It also includes methods for resolution, replacement, and conversion to/from standard `Uri` objects.

By wrapping `package:iri.Iri` instead of extending it, we decouple `rdf_dart`'s internal model from the package's inheritance hierarchy while still exposing the same API.

## Detailed Design
1.  **Add Dependency**: Add `iri: ^0.2.0` to `pubspec.yaml`.
2.  **Modify `lib/src/model/iri.dart`**:
    -   Import `package:iri/iri.dart` as `iri_pkg`.
    -   Change `class Iri` to no longer extend `impl.Iri`.
    -   Add a private field `final iri_pkg.Iri _iri`.
    -   Continue implementing `SubjectTerm`, `PredicateTerm`, `ObjectTerm`, `GraphName`.
    -   Delegate all public `Iri` API methods and getters to the internal `_iri` instance.
    -   Specifically, ensure the following constructors are available:
        -   `factory Iri(String value)` -> `Iri.parse(value)`
        -   `static Iri parse(String value)` -> `iri_pkg.Iri.parse(value)`
        -   `const Iri.fromUri(Uri uri)` -> Use `iri_pkg.Iri.fromUri(uri)` (Note: `const` might not be possible if `iri_pkg.Iri.fromUri` isn't `const`).
        -   `factory Iri.fromComponents(...)` -> `iri_pkg.Iri(...)`
    -   Maintain existing RDF-specific logic like `isGround` (always `true`).
    -   Use `_iri == other._iri` for equality.
3.  **Delete `lib/src/util/iri.dart`**: This file becomes redundant and should be removed.
4.  **Update Callers**:
    -   Any code relying on `Iri` being a `Uri` will need to call `iri.toUri()`. (Initial analysis suggests minimal usage of `Iri` as `Uri` outside its own implementation).
    -   Use `package:iri.Iri.toUri()` directly for conversion to standard `Uri` objects.
    -   Replace `toPercentEncodedUri()` with `toUri()`.

## Diagram (Mermaid)
```mermaid
classDiagram
    class RdfTerm {
        <<interface>>
        +bool isGround
    }
    class SubjectTerm { <<interface>> }
    class PredicateTerm { <<interface>> }
    class ObjectTerm { <<interface>> }
    class GraphName { <<interface>> }
    
    RdfTerm <|-- SubjectTerm
    RdfTerm <|-- PredicateTerm
    RdfTerm <|-- ObjectTerm
    RdfTerm <|-- GraphName
    
    class Iri {
        -iri_pkg.Iri _iri
        +String scheme
        +String host
        +String path
        +toUri() Uri
        +toString() String
    }
    
    SubjectTerm <|.. Iri
    PredicateTerm <|.. Iri
    ObjectTerm <|.. Iri
    GraphName <|.. Iri
    
    Iri o-- "iri_pkg.Iri" : wraps
```

## Summary
The modification will replace a complex, hand-rolled IRI utility with a robust package, while maintaining the same public-facing API for RDF terms. This transition will involve wrapping `package:iri.Iri` and delegating its functionality.

## References
- [package:iri on pub.dev](https://pub.dev/packages/iri)
- [RFC 3987 - Internationalized Resource Identifiers (IRIs)](https://tools.ietf.org/html/rfc3987)
- [rdf_dart model documentation](lib/src/model/term.dart)
