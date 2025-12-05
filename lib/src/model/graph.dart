import 'term.dart';
import 'triple.dart';

/// An RDF Graph is a set of RDF triples.
abstract interface class Graph {
  /// Returns all triples in the graph.
  Iterable<Triple> get triples;

  /// The number of triples in the graph.
  int get length;

  /// Returns true if the graph contains the given [triple].
  bool contains(Triple triple);

  /// Adds a [triple] to the graph. Returns true if it was added.
  bool add(Triple triple);

  /// Removes a [triple] from the graph. Returns true if it was removed.
  bool remove(Triple triple);

  /// Returns a new iterable of triples matching the given pattern.
  /// null values are treated as wildcards.
  Iterable<Triple> match({Term? subject, Term? predicate, Term? object});
}
