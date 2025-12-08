import '../model/blank_node.dart';
import '../model/graph.dart';
import '../model/impl/isomorphism_solver.dart'; // For IsomorphismHelpers
import '../model/iri.dart';
import '../model/literal.dart';
import '../model/term.dart';
import '../model/triple.dart';
import '../model/triple_term.dart';

/// Solves whether [target] entails [query] under Simple Entailment.
///
/// Simple Entailment holds if there is a mapping M from the blank nodes of
/// [query] to the terms of [target] such that the graph obtained by applying
/// M to [query] is a subgraph of [target].
class EntailmentSolver {
  final Set<Iri> _recognizedDatatypes;

  EntailmentSolver({Set<Iri> recognizedDatatypes = const {}})
    : _recognizedDatatypes = recognizedDatatypes;

  /// Returns `true` if [target] entails [query].
  bool entails(Graph target, Graph query) {
    // 1. Separate constructs in Query (E)
    // "E is an instance of a subgraph of S"
    // This implies that every triple in E, once mapped, must exist in S.
    // Structural constraints:
    // - Ground triples in E must exist in S exactly.
    // - Non-ground triples in E must map to triples in S.

    final queryNonGround = <Triple>[];

    // fast exit for ground triples
    for (final triple in query.triples) {
      if (triple.isGround) {
        if (!_matchesTriple(triple, target)) {
          return false;
        }
      } else {
        queryNonGround.add(triple);
      }
    }

    if (queryNonGround.isEmpty) {
      return true;
    }

    // 2. Identify variables (Blank Nodes) in Query
    final queryBNodes = <BlankNode>{};
    for (final triple in queryNonGround) {
      IsomorphismHelpers.collectFromTerm(
        triple.subject,
        queryBNodes,
        recurseTriple: _collectBNodesFromTriple,
      );
      IsomorphismHelpers.collectFromTerm(
        triple.object,
        queryBNodes,
        recurseTriple: _collectBNodesFromTriple,
      );
    }

    // Convert to list for backtracking
    final variables = queryBNodes.toList();

    // 3. Identify domain of values from Target (S)
    // M maps variables to Terms in S.
    // We can restrict candidates:
    // - A variable in subject position in E must map to a SubjectTerm in S.
    // - A variable in object position in E must map to an ObjectTerm in S.
    // For simplicity, we create a unified list of all terms in S.
    final targetTerms = target.nodes.toList();

    // 4. Backtracking Search
    return _solve(
      variables,
      0,
      {}, // Empty mapping initially
      queryNonGround,
      target,
      targetTerms,
    );
  }

  void _collectBNodesFromTriple(Triple t, Set<BlankNode> set) {
    IsomorphismHelpers.collectFromTerm(
      t.subject,
      set,
      recurseTriple: _collectBNodesFromTriple,
    );
    IsomorphismHelpers.collectFromTerm(
      t.object,
      set,
      recurseTriple: _collectBNodesFromTriple,
    );
  }

  bool _solve(
    List<BlankNode> variables,
    int index,
    Map<BlankNode, RdfTerm> mapping,
    List<Triple> queryPattern,
    Graph targetGraph,
    List<RdfTerm> candidates,
  ) {
    // Base Case: All variables mapped
    if (index >= variables.length) {
      return _checkMapping(mapping, queryPattern, targetGraph);
    }

    final currentVar = variables[index];

    // Try mapping currentVar to each candidate
    for (final candidate in candidates) {
      // Basic Type Check Optimization?
      // If currentVar appears as subject, candidate must be SubjectTerm.
      // (This is strictly always true for nodes from a valid RDF Graph,
      // except maybe Literals which can't be subjects)

      mapping[currentVar] = candidate;

      // Optimization: Fail fast if the partial mapping is already invalid?
      // Only useful if we check triples that are fully grounded by current mapping.
      // For now, simple standard backtracking.

      if (_solve(
        variables,
        index + 1,
        mapping,
        queryPattern,
        targetGraph,
        candidates,
      )) {
        return true;
      }

      mapping.remove(currentVar);
    }

    return false;
  }

  bool _checkMapping(
    Map<BlankNode, RdfTerm> mapping,
    List<Triple> queryPattern,
    Graph targetGraph,
  ) {
    for (final triple in queryPattern) {
      final mappedTriple = _mapTriple(triple, mapping);
      if (!_matchesTriple(mappedTriple, targetGraph)) {
        return false;
      }
    }
    return true;
  }

  bool _matchesTriple(Triple queryTriple, Graph targetGraph) {
    if (targetGraph.contains(queryTriple)) return true;

    // D-Entailment check: Value-based matching for recognized literals
    if (_recognizedDatatypes.isNotEmpty) {
      if (queryTriple.object is Literal &&
          _recognizedDatatypes.contains(
            (queryTriple.object as Literal).datatypeIri,
          )) {
        final qLit = queryTriple.object as Literal;
        final candidates = targetGraph.match(
          subject: queryTriple.subject,
          predicate: queryTriple.predicate,
        );
        for (final t in candidates) {
          if (t.object is Literal) {
            final tLit = t.object as Literal;
            if (_recognizedDatatypes.contains(tLit.datatypeIri)) {
              if (qLit.value == tLit.value) return true;
            }
          }
        }
      }
    }
    return false;
  }

  Triple _mapTriple(Triple t, Map<BlankNode, RdfTerm> mapping) {
    return Triple(
      subject: _mapTerm(t.subject, mapping) as SubjectTerm,
      predicate: t
          .predicate, // Predicates are always IRIs in strict RDF, but TripleTerm might contain vars?
      // Wait, TripleTerm is in Object.
      // In RDF 1.2, predicate must be IRI. So no BNode there.
      object: _mapTerm(t.object, mapping) as ObjectTerm,
    );
  }

  RdfTerm _mapTerm(RdfTerm term, Map<BlankNode, RdfTerm> mapping) {
    if (term is BlankNode) {
      return mapping[term] ?? term;
    } else if (term is TripleTerm) {
      // Recursive mapping for TripleTerms
      return TripleTerm(_mapTriple(term.triple, mapping));
    } else {
      return term;
    }
  }
}
