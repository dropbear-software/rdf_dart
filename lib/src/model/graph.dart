import 'blank_node.dart';
import 'term.dart';
import 'triple.dart';
import 'triple_term.dart';

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
    return _GraphIsomorphism.isIsomorphic(this, other);
  }
}

/// Helper class to check for graph isomorphism.
///
/// This class implements the backtracking algorithm needed to find a bijection
/// between blank nodes in two graphs.
class _GraphIsomorphism {
  /// Checks if [g1] and [g2] are isomorphic.
  ///
  /// This method performs the following checks:
  /// 1. Verifies that the number of triples in both graphs is equal.
  /// 2. Verifies that the ground triples (triples without blank nodes) are identical in both graphs.
  /// 3. Backtracking: Attempts to find a bijection between the blank nodes of [g1] and the blank nodes of [g2].
  static bool isIsomorphic(Graph g1, Graph g2) {
    // 1. Split into ground and non-ground triples
    final g1Ground = <Triple>{};
    final g1NonGround = <Triple>[];
    for (final t in g1.triples) {
      if (t.isGround) {
        g1Ground.add(t);
      } else {
        g1NonGround.add(t);
      }
    }

    final g2Ground = <Triple>{};
    final g2NonGround = <Triple>{}; // Use Set for fast lookup
    for (final t in g2.triples) {
      if (t.isGround) {
        g2Ground.add(t);
      } else {
        g2NonGround.add(t);
      }
    }

    // 2. Check Ground Triples
    // Ground triples must be identical in both graphs.
    if (g1Ground.length != g2Ground.length) return false;
    if (!g1Ground.containsAll(g2Ground)) return false;

    // 3. Check Non-Ground Count
    if (g1NonGround.length != g2NonGround.length) return false;

    // 4. Backtracking for Blank Nodes

    // Collect BNodes
    final bNodes1 = <BlankNode>{};
    for (final t in g1NonGround) {
      _collectBNodes(t, bNodes1);
    }
    final bNodes2 = <BlankNode>{};
    for (final t in g2NonGround) {
      _collectBNodes(t, bNodes2);
    }

    if (bNodes1.length != bNodes2.length) return false;
    if (bNodes1.isEmpty) return true;

    return _solve(
      bNodes1.toList(),
      bNodes2.toList(),
      {},
      g1NonGround,
      g2NonGround,
    );
  }

  /// Recursively collects all blank nodes from a triple.
  ///
  /// This includes blank nodes nested within [TripleTerm]s.
  static void _collectBNodes(Triple t, Set<BlankNode> set) {
    _collectFromTerm(t.subject, set);
    _collectFromTerm(t.predicate, set);
    _collectFromTerm(t.object, set);
  }

  /// Collects blank nodes from a term.
  ///
  /// If the term is a [BlankNode], it's added to the set.
  /// If the term is a [TripleTerm], we recurse into its inner triple.
  static void _collectFromTerm(RdfTerm term, Set<BlankNode> set) {
    if (term is BlankNode) {
      set.add(term);
    } else if (term is TripleTerm) {
      _collectBNodes(term.triple, set);
    }
  }

  /// Backtracking solver to find a valid blank node bijection.
  ///
  /// [unmapped1]: List of blank nodes from the first graph that we haven't mapped yet.
  /// [available2]: List of blank nodes from the second graph available to be mapped to.
  /// [mapping]: The current partial mapping from g1's bnodes to g2's bnodes.
  /// [triples1]: The non-ground triples of g1.
  /// [triples2]: The non-ground triples of g2.
  static bool _solve(
    List<BlankNode> unmapped1,
    List<BlankNode> available2,
    Map<BlankNode, BlankNode> mapping,
    List<Triple> triples1,
    Set<Triple> triples2,
  ) {
    if (unmapped1.isEmpty) {
      return _checkMapping(mapping, triples1, triples2);
    }

    final current = unmapped1.first;
    final rest1 = unmapped1.sublist(1);

    for (var i = 0; i < available2.length; i++) {
      final candidate = available2[i];

      mapping[current] = candidate;

      final rest2 = List<BlankNode>.from(available2)..removeAt(i);
      if (_solve(rest1, rest2, mapping, triples1, triples2)) {
        return true;
      }

      mapping.remove(current);
    }
    return false;
  }

  /// Verifies if a complete [mapping] results in g1's triples existing in g2.
  ///
  /// This applies the mapping to all non-ground triples in [triples1] and checks
  /// if the resulting triples are present in [triples2].
  static bool _checkMapping(
    Map<BlankNode, BlankNode> mapping,
    List<Triple> triples1,
    Set<Triple> triples2,
  ) {
    for (final t1 in triples1) {
      final mappedT1 = _mapTriple(t1, mapping);
      if (!triples2.contains(mappedT1)) return false;
    }
    return true;
  }

  /// Creates a new triple with blank nodes mapped according to [mapping].
  static Triple _mapTriple(Triple t, Map<BlankNode, BlankNode> mapping) {
    return Triple(
      subject: _mapTerm(t.subject, mapping) as SubjectTerm,
      predicate: _mapTerm(t.predicate, mapping) as PredicateTerm,
      object: _mapTerm(t.object, mapping) as ObjectTerm,
    );
  }

  /// Maps a term using [mapping] if it is a Blank Node.
  ///
  /// Recursively maps terms within [TripleTerm]s.
  static RdfTerm _mapTerm(RdfTerm term, Map<BlankNode, BlankNode> mapping) {
    if (term is BlankNode) {
      return mapping[term]!;
    } else if (term is TripleTerm) {
      return TripleTerm(_mapTriple(term.triple, mapping));
    } else {
      return term;
    }
  }
}
