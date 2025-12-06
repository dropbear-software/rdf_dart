import 'term.dart';

/// An RDF Blank Node (a node without a global identifier).
///
/// Blank nodes can appear in the Subject or Object position of a triple.
class BlankNode implements Term, Subject, TripleObject, GraphName {
  /// The local identifier for this blank node.
  ///
  /// This identifier is only valid within the scope of the graph or dataset
  /// it belongs to.
  final String id;

  /// Creates a [BlankNode] with the given [id].
  BlankNode(this.id);

  @override
  String toString() => '_:$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlankNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
