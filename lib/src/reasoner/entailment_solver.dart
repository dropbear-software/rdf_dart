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

  static final _xsdDouble = Iri('http://www.w3.org/2001/XMLSchema#double');
  static final _xsdFloat = Iri('http://www.w3.org/2001/XMLSchema#float');

  final Set<Iri> _recognizedDatatypes;

  EntailmentSolver({Set<Iri> recognizedDatatypes = const {}})
    : _recognizedDatatypes = recognizedDatatypes;

  /// Returns `true` if [target] entails [query].
  bool entails(Graph target, Graph query) {
    // 1. Separate constructs in Query (E)
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
    final quotedSubjectBNodes = <BlankNode>{};
    for (final triple in queryNonGround) {
      _scanForQuotedSubjects(triple.subject, quotedSubjectBNodes);
      _scanForQuotedSubjects(triple.object, quotedSubjectBNodes);
    }

    // Convert to list for backtracking
    final variables = queryBNodes.toList();

    // 3. Identify domain of values from Target (S)
    // M maps variables to Terms in S.
    // We must collect ALL terms appearing in S, including those nested inside TripleTerms.
    final targetTerms = _collectAllTerms(target);

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

  /// Recursively collects all terms from the graph, delving into TripleTerms.
  List<RdfTerm> _collectAllTerms(Graph graph) {
    final terms = <RdfTerm>{};
    for (final t in graph.triples) {
      _collectTermsFromTerm(t.subject, terms);
      _collectTermsFromTerm(t.predicate, terms);
      _collectTermsFromTerm(t.object, terms);
    }
    return terms.toList();
  }

  void _collectTermsFromTerm(RdfTerm term, Set<RdfTerm> terms) {
    if (terms.add(term)) {
      if (term is TripleTerm) {
        _collectTermsFromTerm(term.triple.subject, terms);
        _collectTermsFromTerm(term.triple.predicate, terms);
        _collectTermsFromTerm(term.triple.object, terms);
      }
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
      if (s is TripleTerm) {
        if (p == _rdfType && o == _rdfsProposition) {
          continue; // Valid entailment
        }
        return false;
      }

      // Safe to cast to valid Subject/Object terms now
      if (s is! SubjectTerm || o is! ObjectTerm) {
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

    // If datatypes are NOT recognized, we rely on exact graph match (above).
    if (_recognizedDatatypes.isEmpty) return false;

    // D-Entailment logic:
    // We iterate over the target graph to find a "D-equivalent" triple.
    // A triple T1 matches T2 if:
    // s1 == s2 AND p1 == p2 AND o1 is D-equivalent to o2.
    // (We only check Object D-equivalence here as D-entailment primarily affects Literals)

    final candidates = targetGraph.match(
      subject: queryTriple.subject,
      predicate: queryTriple.predicate,
    );

    for (final t in candidates) {
      if (_termsAreDEquivalent(queryTriple.object, t.object)) {
        return true;
      }
    }
    return false;
  }

  /// Returns true if [qTerm] and [tTerm] are equivalent under D-entailment.
  bool _termsAreDEquivalent(ObjectTerm qTerm, ObjectTerm tTerm) {
    // 1. Exact match
    if (qTerm == tTerm) return true;

    // 2. Literal Value Match
    if (qTerm is Literal && tTerm is Literal) {
      if (_recognizedDatatypes.contains(qTerm.datatypeIri) &&
          _recognizedDatatypes.contains(tTerm.datatypeIri)) {
        // Strict check for Signed Zeros in Float/Double
        if (_isSignedZeroMismatch(qTerm, tTerm)) {
          return false;
        }

        // Standard Value Equality
        if (qTerm.value != null && qTerm.value == tTerm.value) {
          return true;
        }
      }
      return false;
    }

    // 3. TripleTerm Recursive Match
    // In D-Interpretation, I(TripleTerm(t)) uses I(components).
    // So <<( s p "042"^^int )>> denotes same resource as <<( s p "42"^^int )>>.
    if (qTerm is TripleTerm && tTerm is TripleTerm) {
      return _triplesAreDEquivalent(qTerm.triple, tTerm.triple);
    }

    return false;
  }

  bool _triplesAreDEquivalent(Triple qTriple, Triple tTriple) {
    // Predicates must match exactly (IRIs)
    if (qTriple.predicate != tTriple.predicate) return false;

    // Subjects: SubjectTerm (IRI or BlankNode)
    // IRIs/BNodes do not have D-entailment variations (unless we considered owl:sameAs etc, which we don't here).
    // So exact match required.
    if (qTriple.subject != tTriple.subject) return false;

    // Objects: Can be Literals or TripleTerms -> Recurse
    return _termsAreDEquivalent(qTriple.object, tTriple.object);
  }

  bool _isSignedZeroMismatch(Literal q, Literal t) {
    // If both are numeric and one is zero, check sign.
    // We only care if types are float/double where -0.0 is distinct.
    final qIsFloat = q.datatypeIri == _xsdDouble || q.datatypeIri == _xsdFloat;
    final tIsFloat = t.datatypeIri == _xsdDouble || t.datatypeIri == _xsdFloat;

    if (!qIsFloat || !tIsFloat) return false;

    final qVal = q.value;
    final tVal = t.value;

    if (qVal is num && tVal is num) {
      // Check if both are zero
      if (qVal == 0 && tVal == 0) {
        // In Dart, 0.0 == -0.0 is true.
        // We use double.negativeZero check or toString check.
        // identical(0.0, -0.0) is false on VM, but can be true on JS/web depending on implementation.
        // Robust way: 1/0.0 = Inf, 1/-0.0 = -Inf.
        final qIsNeg = 1 / qVal.toDouble() < 0;
        final tIsNeg = 1 / tVal.toDouble() < 0;
        return qIsNeg != tIsNeg; // Mismatch if signs differ
      }
    }
    return false;
  }

  Triple _mapTriple(Triple t, Map<BlankNode, RdfTerm> mapping) {
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
      return TripleTerm(_mapTriple(term.triple, mapping));
    } else {
      return term;
    }
  }
}
