import 'term.dart';

/// An RDF Blank Node (a node without a global identifier).
///
/// Blank nodes can appear in the Subject or Object position of a triple.
class BlankNode implements Term, Subject, TripleObject, GraphName {
  /// The local identifier for this blank node.
  ///
  /// This identifier is only valid within the scope of the graph or dataset
  /// it belongs to.
  @override
  final String value;

  /// Creates a [BlankNode] with the given [value] (identifier).
  ///
  /// If no value is provided, one should ideally be generated, but for this
  /// abstract data model, we require an explicit ID or assume the caller generates it.
  /// (TODO: Add auto-generation if needed).
  BlankNode(this.value);

  @override
  String toString() => '_:$value';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlankNode &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
