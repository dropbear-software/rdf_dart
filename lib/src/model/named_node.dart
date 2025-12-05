import 'package:iri/iri.dart';
import 'term.dart';

/// An RDF Term acting as an IRI (Internationalized Resource Identifier).
///
/// A [NamedNode] can appear in the Subject, Predicate, or Object position of a triple.
/// It wraps an [Iri] from the `iri` package to ensure compliance with RFC specifications.
class NamedNode implements Term, Subject, Predicate, TripleObject, GraphName {
  /// The underlying IRI value.
  final IRI iri;

  /// Creates a [NamedNode] from a string.
  ///
  /// Throws if [value] is not a valid IRI.
  NamedNode(String value) : iri = IRI(value);

  /// Creates a [NamedNode] from an existing [IRI] object.
  NamedNode.fromIRI(this.iri);

  @override
  String get value => iri.toString();

  @override
  String toString() => '<$value>';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamedNode &&
          runtimeType == other.runtimeType &&
          iri == other.iri;

  @override
  int get hashCode => iri.hashCode;
}
