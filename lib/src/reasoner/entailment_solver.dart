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
  static final _rdfType = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
  );
  static final _rdfsProposition = Iri(
    'http://www.w3.org/2000/01/rdf-schema#Proposition',
  );

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

    // Identify which variables appear as subjects inside TripleTerms.
    // These MUST map to SubjectTerms (IRI or BlankNode) to form valid Triples.
    // They cannot map to Literals or TripleTerms.
    final quotedSubjectBNodes = <BlankNode>{};
    for (final triple in queryNonGround) {
      _scanForQuotedSubjects(triple.subject, quotedSubjectBNodes);
      _scanForQuotedSubjects(triple.object, quotedSubjectBNodes);
    }

    // Convert to list for backtracking
    final variables = queryBNodes.toList();

    // 3. Identify domain of values from Target (S)
    // M maps variables to Terms in S.
    final targetTerms = target.nodes.toList();

    // 4. Backtracking Search
    return _solve(
      variables,
      0,
      {}, // Empty mapping initially
      queryNonGround,
      target,
      targetTerms,
      quotedSubjectBNodes,
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

  void _scanForQuotedSubjects(RdfTerm term, Set<BlankNode> set) {
    if (term is TripleTerm) {
      final inner = term.triple;
      if (inner.subject is BlankNode) {
        set.add(inner.subject as BlankNode);
      }
      _scanForQuotedSubjects(inner.subject, set);
      _scanForQuotedSubjects(inner.object, set);
    }
  }

  bool _solve(
    List<BlankNode> variables,
    int index,
    Map<BlankNode, RdfTerm> mapping,
    List<Triple> queryPattern,
    Graph targetGraph,
    List<RdfTerm> candidates,
    Set<BlankNode> quotedSubjectBNodes,
  ) {
    // Base Case: All variables mapped
    if (index >= variables.length) {
      return _checkMapping(mapping, queryPattern, targetGraph);
    }

    final currentVar = variables[index];
    final isQuotedSubject = quotedSubjectBNodes.contains(currentVar);

    // Try mapping currentVar to each candidate
    for (final candidate in candidates) {
      // Constraint Check:
      // If the variable appears as a subject inside a TripleTerm,
      // it MUST map to a SubjectTerm (IRI or BlankNode).
      // It cannot map to a Literal or TripleTerm, as strict RDF 1.2
      // does not allow these in the subject position.
      if (isQuotedSubject && candidate is! SubjectTerm) {
        continue;
      }

      mapping[currentVar] = candidate;

      if (_solve(
        variables,
        index + 1,
        mapping,
        queryPattern,
        targetGraph,
        candidates,
        quotedSubjectBNodes,
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
      final s = _mapTerm(triple.subject, mapping);
      final p =
          triple.predicate; // Predicate is constant in Query Triple pattern
      final o = _mapTerm(triple.object, mapping);

      // --- RDF 1.2 Entailment: TripleTerm is a Proposition ---
      // Check specific entailment cases where TripleTerm might effectively be a subject
      // (e.g., rdf:type rdfs:Proposition), even if it's not a valid SubjectTerm
      // for an asserted triple construction.
      if (s is TripleTerm) {
        if (p == _rdfType && o == _rdfsProposition) {
          continue; // Valid entailment
        }
        // TripleTerm cannot be a subject of any other asserted triple in strict RDF 1.2
        return false;
      }

      // Safe to cast to valid Subject/Object terms now
      if (s is! SubjectTerm || o is! ObjectTerm) {
        // Literal as Subject => Invalid in standard RDF.
        return false;
      }

      final mappedTriple = Triple(subject: s, predicate: p, object: o);

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
    // Maps a Triple inside a TripleTerm.
    // Since this constructs a Triple, the subject MUST be a SubjectTerm.
    // Our _solve loop constraints ensure that any variable mapping to t.subject
    // is a SubjectTerm.
    return Triple(
      subject: _mapTerm(t.subject, mapping) as SubjectTerm,
      predicate: t.predicate,
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
