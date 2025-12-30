# Design Document: RDF 1.2 Turtle Serializer

## Overview
The goal is to implement a fully compliant RDF 1.2 Turtle serializer for the `rdf_dart` package. Currently, the `TurtleEncoder` delegates to the `NTriplesEncoder`, which produces valid but verbose output. The new implementation will utilize the specific features of the Turtle language (terse syntax, prefixes, nesting, collections, and RDF 1.2 extensions) to produce human-readable and compact output.

## Problem Analysis
Turtle (Terse RDF Triple Language) is designed to be easy to write and read. The current implementation outputs N-Triples, which is a subset of Turtle but lacks the "terse" features:
- **Prefixes:** N-Triples uses full IRIs. Turtle allows `PREFIX` declarations and `prefix:localName` abbreviations.
- **Base IRI:** N-Triples does not use `@base`. Turtle allows relative IRIs.
- **Grouping:** N-Triples repeats the subject and predicate for every object. Turtle allows grouping via `;` (predicate lists) and `,` (object lists).
- **Blank Nodes:** N-Triples uses explicit `_:label` identifiers. Turtle allows `[]` for anonymous blank nodes and nesting.
- **Collections:** Turtle provides `( ... )` syntax for `rdf:List` structures.
- **RDF 1.2 Features:** Support for `<< ... >>` (triple terms) and `{| ... |}` (annotations).

## Design Considerations

### 1. Configuration & API
To support the requested features (prefixes, base IRI), the `TurtleEncoder` needs a configuration mechanism. Since `Converter` subclasses are typically stateless/immutable, we will pass configuration via the constructor.

**Proposed API:**
```dart
class TurtleEncoder extends Converter<Iterable<Triple>, String> {
  final Map<String, String> prefixes;
  final String? baseUri;
  final bool compact; // Toggles aggressive syntactic sugar (nesting, collections)

  const TurtleEncoder({
    this.prefixes = const {}, 
    this.baseUri,
    this.compact = true,
  });
  
  // ...
}
```

### 2. Architecture
Unlike N-Triples, which can be serialized in a single streaming pass (line-by-line), optimal Turtle serialization requires a holistic view of the graph to:
- Group triples by subject.
- Identify list structures (collections).
- Identify blank nodes that can be inlined (reference counting).
- Detect reification patterns for annotation syntax.

**Pipeline:**
1.  **Ingest:** Load the input `Iterable<Triple>` into an efficiently queryable structure (likely the existing `Graph` implementation or a temporary internal index).
2.  **Analyze (Pre-pass):**
    *   Compute reference counts for blank nodes to determine if they can be nested `[]`.
    *   Identify heads of RDF lists for `()` syntax.
    *   Index reified triples for `{| ... |}` syntax.
3.  **Serialize (Output):**
    *   Write `BASE` and `PREFIX` directives.
    *   Iterate through subjects (sorted for deterministic output).
    *   Apply syntactic sugar (Predicate Lists, Object Lists, Nesting).
    *   Use a `TurtleWriter` helper class to manage indentation and line wrapping.

### 3. Syntactic Sugar Strategy

#### Predicate and Object Lists
- **Strategy:** Group triples by Subject. Within that group, group by Predicate.
- **Output:**
  ```turtle
  :subject 
      :pred1 :obj1, :obj2 ;
      :pred2 :obj3 .
  ```

#### Relative IRIs and Prefixes
- **Base URI:** If provided, verify if an IRI starts with the base. If so, strip the base to produce a relative IRI.
- **Prefixes:** Iterate through provided `prefixes`. If an IRI matches a namespace, replace with `prefix:localName`.
- **Validation:** Ensure the `localName` is valid according to the Turtle grammar (PN_LOCAL). If not, fallback to full `<...>` IRI.

#### Blank Nodes & Nesting
- **Analysis:** Count incoming references to each Blank Node.
- **Rule:** If a Blank Node has exactly **one** incoming reference and is **not** the root of a cycle, it can be inlined using `[ ... ]`.
- **Recursion:** This logic applies recursively for nested structures.

#### Collections
- **Analysis:** Identify Blank Nodes that are subjects of `rdf:first` and `rdf:rest`.
- **Rule:** If a chain of these forms a valid list structure and the nodes are not referenced elsewhere, serialize as `( item1 item2 ... )`.

#### RDF 1.2 Annotations
- **Analysis:** Identify triples where the object is a `TripleTerm` (e.g., `_:r rdf:reifies <<( s p o )>>`).
- **Sugar:** If `_:r` is used as the subject of other triples (`_:r :assertedBy :bob`), output using annotation syntax:
  ```turtle
  s p o {| :assertedBy :bob |} .
  ```
- **Fallback:** If complex reification structures exist that don't fit the `{| |}` pattern, fallback to explicit reification triples.

## Detailed Logic

### `TurtleWriter` Class
A helper class to handle the output buffer, indentation levels, and context.

```dart
class TurtleWriter {
  final StringSink _sink;
  int _indent = 0;
  
  // Methods to write tokens, manage newlines, increase/decrease indent
}
```

### Relativization Logic
```dart
String relativize(Iri iri) {
  // 1. Try Base URI relativization
  // 2. Try Prefix Map replacement
  // 3. Return <absoluteIRI>
}
```

## References
- **RDF 1.2 Turtle Spec:** https://www.w3.org/TR/rdf12-turtle/
- **RDF 1.2 Concepts:** https://www.w3.org/TR/rdf12-concepts/
- **Turtle Grammar (BNF):** Local file `turtle.bnf`

## Summary
The implementation will upgrade `TurtleEncoder` from a proxy to a sophisticated graph serializer. It will prioritize readability and standard compliance, utilizing a multi-pass approach to handle complex syntactic sugars like nesting and collections. The API will remain clean but allow necessary configuration for prefixes and base URIs.
