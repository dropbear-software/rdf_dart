import '../model/graph.dart';
import '../model/iri.dart';
import '../model/literal.dart';
import '../model/term.dart';
import '../model/triple.dart';
import '../vocabulary/vocabulary.dart';

/// The entailment regimes supported by the [RdfsReasoner].
enum EntailmentRegime {
  /// Simple entailment (structural matching only).
  simple,

  /// RDF entailment (adds RDF axiomatic triples and D-entailment).
  rdf,

  /// RDFS entailment (adds RDFS axiomatic triples, class/property hierarchies).
  rdfs,
}

/// A reasoner that computes the deductive closure of an RDF graph based on
/// RDF and RDFS entailment rules.
class RdfsReasoner {
  final Graph _graph;
  final EntailmentRegime _regime;
  final Set<Iri> _recognizedDatatypes;

  RdfsReasoner(
    this._graph, {
    EntailmentRegime regime = EntailmentRegime.rdfs,
    Set<Iri> recognizedDatatypes = const {},
  }) : _regime = regime,
       _recognizedDatatypes = recognizedDatatypes.isEmpty
           ? {
               Xsd.string,
               Xsd.boolean,
               Xsd.integer,
               Xsd.decimal,
               Xsd.dateTime,
               Rdf.langString,
               Rdf.XMLLiteral,
             }
           : recognizedDatatypes;

  /// Executes the reasoning process until no new triples can be inferred.
  void apply() {
    if (_regime == EntailmentRegime.simple) return;

    // 1. Add Axiomatic Triples (Base rules)
    _addRdfAxioms();
    if (_regime == EntailmentRegime.rdfs) {
      _addRdfsAxioms();
    }

    // 2. Loop until saturation
    bool changed = true;
    while (changed) {
      changed = false;

      // RDF Rules
      changed |= _applyRdfD1(); // Datatypes
      changed |= _applyRdfD2(); // (s p o) -> p type Property

      if (_regime != EntailmentRegime.simple) {
        changed |= _applyDatatypeCanonicalization();
      }

      if (_regime == EntailmentRegime.rdfs) {
        changed |= _applyRdfs1(); // Datatypes are rdfs:Datatype
        changed |= _applyRdfs2(); // domain
        changed |= _applyRdfs3(); // range
        changed |= _applyRdfs4(); // Resources
        changed |= _applyRdfs5(); // subPropertyOf transitivity
        changed |= _applyRdfs6(); // Property reflexivity
        changed |= _applyRdfs7(); // subPropertyOf data inheritance
        changed |= _applyRdfs8(); // Class -> subClassOf Resource
        changed |= _applyRdfs9(); // subClassOf inheritance
        changed |= _applyRdfs10(); // Class reflexivity
        changed |= _applyRdfs11(); // subClassOf transitivity
        changed |= _applyRdfs12(); // ContainerMembershipProperty
        changed |= _applyRdfs13(); // Datatype -> subClassOf Literal
        changed |= _applyContainerMembershipProperties(); // Detect rdf:_n
      }
    }
  }

  void _addRdfAxioms() {
    _addAxiom(Rdf.type, Rdf.type, Rdf.Property);
    _addAxiom(Rdf.subject, Rdf.type, Rdf.Property);
    _addAxiom(Rdf.predicate, Rdf.type, Rdf.Property);
    _addAxiom(Rdf.object, Rdf.type, Rdf.Property);
    _addAxiom(Rdf.first, Rdf.type, Rdf.Property);
    _addAxiom(Rdf.rest, Rdf.type, Rdf.Property);
    _addAxiom(Rdf.value, Rdf.type, Rdf.Property);
    _addAxiom(Rdf.nil, Rdf.type, Rdf.List);
  }

  void _addRdfsAxioms() {
    // Properties
    for (final p in [
      Rdf.type,
      Rdfs.domain,
      Rdfs.range,
      Rdfs.subClassOf,
      Rdfs.subPropertyOf,
      Rdfs.member,
      Rdfs.label,
      Rdfs.comment,
      Rdfs.seeAlso,
      Rdfs.isDefinedBy,
      Rdf.subject,
      Rdf.predicate,
      Rdf.object,
      Rdf.Statement,
      Rdf.first,
      Rdf.rest,
      Rdf.value,
      Rdf.reifies,
    ]) {
      _addAxiom(p, Rdf.type, Rdf.Property);
      _addAxiom(p, Rdfs.domain, Rdfs.Resource);
      _addAxiom(p, Rdfs.range, Rdfs.Resource);
    }

    _addAxiom(Rdfs.domain, Rdfs.domain, Rdf.Property);
    _addAxiom(Rdfs.domain, Rdfs.range, Rdfs.Class);

    _addAxiom(Rdfs.range, Rdfs.domain, Rdf.Property);
    _addAxiom(Rdfs.range, Rdfs.range, Rdfs.Class);

    _addAxiom(Rdfs.subPropertyOf, Rdfs.domain, Rdf.Property);
    _addAxiom(Rdfs.subPropertyOf, Rdfs.range, Rdf.Property);

    _addAxiom(Rdfs.subClassOf, Rdfs.domain, Rdfs.Class);
    _addAxiom(Rdfs.subClassOf, Rdfs.range, Rdfs.Class);

    _addAxiom(Rdf.type, Rdfs.domain, Rdfs.Resource);
    _addAxiom(Rdf.type, Rdfs.range, Rdfs.Class);

    // Classes
    _addAxiom(Rdfs.Resource, Rdf.type, Rdfs.Class);
    _addAxiom(Rdfs.Class, Rdf.type, Rdfs.Class);
    _addAxiom(Rdfs.Literal, Rdf.type, Rdfs.Class);
    _addAxiom(Rdfs.Datatype, Rdf.type, Rdfs.Class);
    _addAxiom(Rdf.Statement, Rdf.type, Rdfs.Class); // RDF Statement is a class
    _addAxiom(Rdf.Property, Rdf.type, Rdfs.Class);
    _addAxiom(Rdfs.ContainerMembershipProperty, Rdfs.subClassOf, Rdf.Property);
    _addAxiom(Rdfs.Proposition, Rdf.type, Rdfs.Class);

    _addAxiom(Rdf.reifies, Rdfs.range, Rdfs.Proposition);
  }

  bool _addAxiom(SubjectTerm s, Iri p, ObjectTerm o) {
    final t = Triple(subject: s, predicate: p, object: o);
    if (!_graph.contains(t)) {
      _graph.add(t);
      return true;
    }
    return false;
  }

  /// Rule rdfD1: Generates datatypes for recognized literals.
  /// "For each pair `<s, l>` where s forms the datatype of l ... s rdf:type rdfs:Datatype"
  bool _applyRdfD1() {
    bool changed = false;
    for (final d in _recognizedDatatypes) {
      final t = Triple(subject: d, predicate: Rdf.type, object: Rdfs.Datatype);
      if (_graph.add(t)) changed = true;
    }
    return changed;
  }

  /// Rule rdfD2: If a triple (s p o) exists -> p rdf:type rdf:Property
  bool _applyRdfD2() {
    bool changed = false;
    for (final triple in _graph.triples.toList()) {
      final predicate = triple.predicate;
      if (_graph.add(
        Triple(
          subject: predicate as SubjectTerm,
          predicate: Rdf.type,
          object: Rdf.Property,
        ),
      )) {
        changed = true;
      }
    }
    return changed;
  }

  /// Rule rdfs1: If a recognized datatype IRI appears in the graph -> (iri rdf:type rdfs:Datatype)
  /// Note: RDF 1.1 Semantics subsumes this into D-entailment somewhat, but RDFS 1.1 keeps it.
  bool _applyRdfs1() {
    bool changed = false;
    for (final node in _graph.nodes) {
      if (node is Iri && _recognizedDatatypes.contains(node)) {
        if (_graph.add(
          Triple(subject: node, predicate: Rdf.type, object: Rdfs.Datatype),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs2() {
    bool changed = false;
    final domainTriples = _graph.match(predicate: Rdfs.domain);
    for (final t in domainTriples.toList()) {
      final p = t.subject;
      final c = t.object;
      if (p is! PredicateTerm) continue;
      final usages = _graph.match(predicate: p as PredicateTerm);
      for (final usage in usages.toList()) {
        if (_graph.add(
          Triple(subject: usage.subject, predicate: Rdf.type, object: c),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs3() {
    bool changed = false;
    final rangeTriples = _graph.match(predicate: Rdfs.range);
    for (final t in rangeTriples.toList()) {
      final p = t.subject;
      final c = t.object;
      if (p is! PredicateTerm) continue;
      final usages = _graph.match(predicate: p as PredicateTerm);
      for (final usage in usages.toList()) {
        final u = usage.object;
        if (u is SubjectTerm) {
          // Only Subjects can have types
          if (_graph.add(
            Triple(subject: u as SubjectTerm, predicate: Rdf.type, object: c),
          )) {
            changed = true;
          }
        }
      }
    }
    return changed;
  }

  bool _applyRdfs4() {
    bool changed = false;
    // Everything is a Resource.
    for (final node in _graph.nodes.toList()) {
      if (node is SubjectTerm) {
        if (_graph.add(
          Triple(subject: node, predicate: Rdf.type, object: Rdfs.Resource),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs5() {
    bool changed = false;
    final subPropTriples = _graph.match(predicate: Rdfs.subPropertyOf);
    // Transitivity
    for (final t1 in subPropTriples.toList()) {
      final u = t1.subject;
      final v = t1.object;
      if (v is! SubjectTerm) continue;
      final secondLegs = _graph.match(
        subject: v as SubjectTerm,
        predicate: Rdfs.subPropertyOf,
      );
      for (final t2 in secondLegs.toList()) {
        final x = t2.object;
        if (_graph.add(
          Triple(subject: u, predicate: Rdfs.subPropertyOf, object: x),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs6() {
    bool changed = false;
    // Reflexivity for properties
    final properties = _graph.match(predicate: Rdf.type, object: Rdf.Property);
    for (final t in properties.toList()) {
      final p = t.subject;
      if (p is ObjectTerm) {
        if (_graph.add(
          Triple(
            subject: p,
            predicate: Rdfs.subPropertyOf,
            object: p as ObjectTerm,
          ),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs7() {
    bool changed = false;
    // subPropertyOf inheritance
    final subPropTriples = _graph.match(predicate: Rdfs.subPropertyOf);
    for (final t in subPropTriples.toList()) {
      final p1 = t.subject;
      final p2 = t.object;
      if (p1 is! PredicateTerm || p2 is! PredicateTerm) continue;
      final data = _graph.match(predicate: p1 as PredicateTerm);
      for (final usage in data.toList()) {
        if (_graph.add(
          Triple(
            subject: usage.subject,
            predicate: p2 as PredicateTerm,
            object: usage.object,
          ),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs8() {
    bool changed = false;
    // Class subclass of Resource
    final classes = _graph.match(predicate: Rdf.type, object: Rdfs.Class);
    for (final t in classes.toList()) {
      if (_graph.add(
        Triple(
          subject: t.subject,
          predicate: Rdfs.subClassOf,
          object: Rdfs.Resource,
        ),
      )) {
        changed = true;
      }
    }
    return changed;
  }

  bool _applyRdfs9() {
    bool changed = false;
    // SubClass inheritance
    final subClassTriples = _graph.match(predicate: Rdfs.subClassOf);
    for (final t in subClassTriples.toList()) {
      final c1 = t.subject;
      final c2 = t.object;
      if (c1 is! ObjectTerm) continue;
      final instances = _graph.match(
        predicate: Rdf.type,
        object: c1 as ObjectTerm,
      );
      for (final i in instances.toList()) {
        if (_graph.add(
          Triple(subject: i.subject, predicate: Rdf.type, object: c2),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs10() {
    bool changed = false;
    // Class reflexivity
    final classes = _graph.match(predicate: Rdf.type, object: Rdfs.Class);
    for (final t in classes.toList()) {
      final c = t.subject;
      if (c is ObjectTerm) {
        if (_graph.add(
          Triple(
            subject: c,
            predicate: Rdfs.subClassOf,
            object: c as ObjectTerm,
          ),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs11() {
    bool changed = false;
    // SubClass transitivity
    final subClassTriples = _graph.match(predicate: Rdfs.subClassOf);
    for (final t1 in subClassTriples.toList()) {
      final u = t1.subject;
      final v = t1.object;
      if (v is! SubjectTerm) continue;
      final secondLegs = _graph.match(
        subject: v as SubjectTerm,
        predicate: Rdfs.subClassOf,
      );
      for (final t2 in secondLegs.toList()) {
        final x = t2.object;
        if (_graph.add(
          Triple(subject: u, predicate: Rdfs.subClassOf, object: x),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs12() {
    bool changed = false;
    // ContainerMembershipProperty
    final props = _graph.match(
      predicate: Rdf.type,
      object: Rdfs.ContainerMembershipProperty,
    );
    for (final t in props.toList()) {
      if (_graph.add(
        Triple(
          subject: t.subject,
          predicate: Rdfs.subPropertyOf,
          object: Rdfs.member,
        ),
      )) {
        changed = true;
      }
    }
    return changed;
  }

  bool _applyRdfs13() {
    bool changed = false;
    // Datatype subClassOf Literal
    final dts = _graph.match(predicate: Rdf.type, object: Rdfs.Datatype);
    for (final t in dts.toList()) {
      if (_graph.add(
        Triple(
          subject: t.subject,
          predicate: Rdfs.subClassOf,
          object: Rdfs.Literal,
        ),
      )) {
        changed = true;
      }
    }
    return changed;
  }

  bool _applyDatatypeCanonicalization() {
    bool changed = false;
    for (final triple in _graph.triples.toList()) {
      if (triple.object is Literal) {
        final literal = triple.object as Literal;
        if (_recognizedDatatypes.contains(literal.datatypeIri)) {
          final canonical = literal.canonical;
          if (canonical != literal) {
            if (_graph.add(
              Triple(
                subject: triple.subject,
                predicate: triple.predicate,
                object: canonical,
              ),
            )) {
              changed = true;
            }
          }
        }
      }
    }
    return changed;
  }

  static final _cmpRegExp = RegExp(
    r'^http://www.w3.org/1999/02/22-rdf-syntax-ns#_([1-9][0-9]*)$',
  );

  bool _applyContainerMembershipProperties() {
    bool changed = false;
    final candidates = <Iri>{};
    for (final t in _graph.triples) {
      if (t.subject is Iri) candidates.add(t.subject as Iri);
      if (t.predicate is Iri) candidates.add(t.predicate as Iri);
      if (t.object is Iri) candidates.add(t.object as Iri);
    }

    for (final node in candidates) {
      if (_cmpRegExp.hasMatch(node.toString())) {
        if (_graph.add(
          Triple(
            subject: node,
            predicate: Rdf.type,
            object: Rdfs.ContainerMembershipProperty,
          ),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }
}
