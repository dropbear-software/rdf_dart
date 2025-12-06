import 'package:iri/iri.dart' as iri_pkg;
import 'term.dart';

/// An RDF Term acting as an IRI (Internationalized Resource Identifier).
///
/// An [Iri] can appear in the Subject, Predicate, or Object position of a triple.
/// It wraps an [iri_pkg.Iri] from the `iri` package to ensure compliance with RFC specifications.
class Iri implements Term, Subject, Predicate, TripleObject, GraphName {
  /// The underlying IRI value.
  final iri_pkg.IRI value;

  /// Creates an [Iri] from a string.
  ///
  /// The string is parsed into an [iri_pkg.IRI].
  Iri(String value) : value = iri_pkg.IRI(value);

  /// Creates an [Iri] from an existing [iri_pkg.IRI] object.
  Iri.fromIri(this.value);

  @override
  String toString() => '<$value>';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Iri && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
