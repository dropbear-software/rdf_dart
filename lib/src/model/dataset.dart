import 'blank_node.dart';
import 'graph.dart';
import 'impl/isomorphism_solver.dart';
import 'quad.dart';
import 'term.dart';
import 'triple.dart';

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
    RdfTerm? subject,
    RdfTerm? predicate,
    RdfTerm? object,

    /// The name of the graph to match.
    ///
    /// If [graphName] is `null` (the default), it acts as a wildcard, matching
    /// quads from **all** graphs (both the default graph and all named graphs).
    ///
    /// To match quads specifically in the default graph, you may need to filter
    /// the results manually or use a specific implementation-dependent method if available.
    GraphName? graphName,
  });

  /// Returns `true` if this dataset is isomorphic to [other].
  ///
  /// Two RDF datasets are isomorphic if there is a bijection between the
  /// blank nodes of the two datasets (including those used as graph names)
  /// such that a quad (s, p, o, g) is in one dataset if and only if
  /// the quad (M(s), M(p), M(o), M(g)) is in the other.
  bool isomorphic(Dataset other);
}

/// A mixin that provides default implementations for some [Dataset] members.
mixin DatasetMixin implements Dataset {
  @override
  bool isomorphic(Dataset other) {
    // Use quads for isomorphism check
    // We treat dataset as a set of quads.
    final solver = IsomorphismSolver<Quad>(_DatasetIsomorphismStrategy());
    return solver.isIsomorphic(quads, other.quads);
  }
}

class _DatasetIsomorphismStrategy implements IsomorphismStrategy<Quad> {
  @override
  bool isGround(Quad item) {
    if (!item.triple.isGround) return false;
    final gn = item.graphName;
    if (gn == null) return true;
    return gn.isGround;
  }

  @override
  void collectBlankNodes(Quad item, Set<BlankNode> set) {
    IsomorphismHelpers.collectFromTerm(
      item.subject,
      set,
      recurseTriple: collectTripleBNodes,
    );
    // Predicate is always an IRI, so no blank nodes to collect.
    IsomorphismHelpers.collectFromTerm(
      item.object,
      set,
      recurseTriple: collectTripleBNodes,
    );

    final gn = item.graphName;
    if (gn is BlankNode) {
      set.add(gn);
    }
  }

  /// Recursively collects blank nodes from a triple.
  void collectTripleBNodes(Triple t, Set<BlankNode> set) {
    IsomorphismHelpers.collectFromTerm(
      t.subject,
      set,
      recurseTriple: collectTripleBNodes,
    );
    // Predicate is always an IRI.
    IsomorphismHelpers.collectFromTerm(
      t.object,
      set,
      recurseTriple: collectTripleBNodes,
    );
  }

  @override
  Quad mapBlankNodes(Quad item, Map<BlankNode, BlankNode> mapping) {
    return Quad(
      Triple(
        subject:
            IsomorphismHelpers.mapTerm(
                  item.subject,
                  mapping,
                  mapTriple: mapTriple,
                )
                as SubjectTerm,
        predicate: item.predicate, // Predicate is always an IRI.
        object:
            IsomorphismHelpers.mapTerm(
                  item.object,
                  mapping,
                  mapTriple: mapTriple,
                )
                as ObjectTerm,
      ),
      item.graphName is BlankNode
          ? mapping[item.graphName] as GraphName?
          : item.graphName,
    );
  }

  Triple mapTriple(Triple t, Map<BlankNode, BlankNode> mapping) {
    return Triple(
      subject:
          IsomorphismHelpers.mapTerm(t.subject, mapping, mapTriple: mapTriple)
              as SubjectTerm,
      predicate: t.predicate, // Predicate is always an IRI.
      object:
          IsomorphismHelpers.mapTerm(t.object, mapping, mapTriple: mapTriple)
              as ObjectTerm,
    );
  }
}
