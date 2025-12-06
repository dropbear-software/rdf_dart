import 'term.dart';
import 'triple.dart';

/// An RDF Graph is a set of RDF triples.
abstract interface class Graph {
  /// Returns all triples in the graph.
  Iterable<Triple> get triples;

  /// The number of triples in the graph.
  int get length;

  /// Returns true if the graph contains (asserts) the given [triple].
  bool contains(Triple triple);

  /// Adds a [triple] to the graph. Returns true if it was added.
  bool add(Triple triple);

  /// Removes a [triple] from the graph. Returns true if it was removed.
  bool remove(Triple triple);

  /// Returns a new iterable of triples matching the given pattern.
  /// null values are treated as wildcards.
  Iterable<Triple> match({
    Subject? subject,
    Predicate? predicate,
    TripleObject? object,
  });

  /// Removes all triples matching the given pattern.
  ///
  /// [subject], [predicate], and [object] can be specific terms or `null` (wildcard).
  void removeMatches(
    Subject? subject,
    Predicate? predicate,
    TripleObject? object,
  );

  /// The groundness of this graph.
  ///
  /// An [Graph] is said to be ground if all its asserted triples are ground.
  bool get isGround;
}

/// A mixin that provides default implementations for some [Graph] members.
mixin GraphMixin implements Graph {
  @override
  bool get isGround => triples.every((triple) => triple.isGround);
}
