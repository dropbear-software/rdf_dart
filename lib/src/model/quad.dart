import 'term.dart';
import 'triple.dart';

/// An RDF Quad.
///
/// A quad consists of an RDF [Triple] and an optional [GraphName].
/// It represents a statement within a specific graph (or the default graph if null) in a dataset.
class Quad {
  /// The underlying triple.
  final Triple triple;

  /// The name of the graph this triple belongs to, or null for the default graph.
  final GraphName? graphName;

  /// Creates a new [Quad].
  Quad(this.triple, [this.graphName]);

  /// Convenience accessor for the subject.
  Subject get subject => triple.subject;

  /// Convenience accessor for the predicate.
  Predicate get predicate => triple.predicate;

  /// Convenience accessor for the object.
  TripleObject get object => triple.object;

  @override
  String toString() {
    if (graphName != null) {
      return '$subject $predicate $object $graphName .';
    } else {
      return triple.toString();
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quad &&
          runtimeType == other.runtimeType &&
          triple == other.triple &&
          graphName == other.graphName;

  @override
  int get hashCode => Object.hash(triple, graphName);
}
