import 'graph.dart';
import 'quad.dart';
import 'term.dart';

/// An RDF Dataset is a collection of RDF graphs.
abstract interface class Dataset {
  /// The default graph of this dataset.
  Graph get defaultGraph;

  /// All graph names currently in the dataset.
  Iterable<GraphName> get graphNames;

  /// Returns the graph associated with the given [graphName].
  ///
  /// Implementations should return a Graph view for the [graphName],
  /// creating it if it doesn't exist or providing a mechanism to add to it.
  Graph namedGraph(GraphName graphName);

  /// Adds a [quad] to the dataset.
  /// This adds the triple to the corresponding graph (default or named).
  bool add(Quad quad);

  /// Removes a [quad] from the dataset.
  bool remove(Quad quad);

  /// Returns all quads in the dataset.
  Iterable<Quad> get quads;

  /// Matches quads across the entire dataset.
  Iterable<Quad> match({
    Term? subject,
    Term? predicate,
    Term? object,
    GraphName? graphName,
  });
}
