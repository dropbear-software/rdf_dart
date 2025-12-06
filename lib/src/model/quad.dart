import 'iri.dart';
import 'term.dart';
import 'triple.dart';

/// An RDF Quad.
///
/// A quad consists of an RDF [Triple] and an optional [GraphName].
/// It represents a statement within a specific graph (or the default graph if null) in a dataset.
class Quad {
  /// The underlying triple.
  final Triple triple;

  /// The graph name of the quad.
  ///
  /// This is [Iri] or [BlankNode] for named graphs, or potentially `null`
  /// (or a default graph IRI) for the default graph depending on implementation.
  /// Strictly speaking in RDF 1.2 Dataset, it is an [Iri] or [BlankNode].
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
