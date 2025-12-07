import 'blank_node.dart';
import 'impl/isomorphism_solver.dart';
import 'term.dart';
import 'triple.dart';

/// An RDF Graph is a set of RDF triples.
abstract interface class Graph {
  /// Returns all triples in the graph.
  Iterable<Triple> get triples;

  /// The set of nodes of an RDF graph is the set of subjects and objects
  /// of the asserted triples of the graph
  Iterable<RdfTerm> get nodes;

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
    SubjectTerm? subject,
    PredicateTerm? predicate,
    ObjectTerm? object,
  });

  /// Removes all triples matching the given pattern.
  ///
  /// [subject], [predicate], and [object] can be specific terms or `null` (wildcard).
  void removeMatches(
    SubjectTerm? subject,
    PredicateTerm? predicate,
    ObjectTerm? object,
  );

  /// The groundness of this graph.
  ///
  /// An [Graph] is said to be ground if all its asserted triples are ground.
  bool get isGround;

  /// Returns `true` if this graph is isomorphic to [other].
  ///
  /// Two RDF graphs are isomorphic if there is a bijection between the
  /// blank nodes of the two graphs such that a triple (s, p, o) is in one
  /// graph if and only if the triple (M(s), M(p), M(o)) is in the other,
  /// where M is the mapping that updates blank nodes and is the identity
  /// for other terms.
  bool isomorphic(Graph other);
}

/// A mixin that provides default implementations for some [Graph] members.
mixin GraphMixin implements Graph {
  @override
  bool get isGround => triples.every((triple) => triple.isGround);

  @override
  Iterable<RdfTerm> get nodes {
    final Set<RdfTerm> nodes = {};
    for (final triple in triples) {
      nodes.add(triple.subject);
      nodes.add(triple.object);
    }
    return nodes;
  }

  @override
  bool isomorphic(Graph other) {
    if (length != other.length) return false;
    final solver = IsomorphismSolver<Triple>(_GraphIsomorphismStrategy());
    return solver.isIsomorphic(triples, other.triples);
  }
}

class _GraphIsomorphismStrategy implements IsomorphismStrategy<Triple> {
  @override
  bool isGround(Triple item) => item.isGround;

  @override
  void collectBlankNodes(Triple item, Set<BlankNode> set) {
    IsomorphismHelpers.collectFromTerm(
      item.subject,
      set,
      recurseTriple: collectBlankNodes,
    );
    // Predicate is always an IRI.
    IsomorphismHelpers.collectFromTerm(
      item.object,
      set,
      recurseTriple: collectBlankNodes,
    );
  }

  @override
  Triple mapBlankNodes(Triple item, Map<BlankNode, BlankNode> mapping) {
    return Triple(
      subject:
          IsomorphismHelpers.mapTerm(
                item.subject,
                mapping,
                mapTriple: mapBlankNodes,
              )
              as SubjectTerm,
      predicate:
          item.predicate, // Predicate is always an IRI, so no partial mapping.
      object:
          IsomorphismHelpers.mapTerm(
                item.object,
                mapping,
                mapTriple: mapBlankNodes,
              )
              as ObjectTerm,
    );
  }
}
