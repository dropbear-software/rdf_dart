import '../model/graph.dart';
import '../model/iri.dart';
import '../model/literal.dart';
import '../model/term.dart';
import '../model/triple.dart';

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

  // -- Vocabulary Constants --
  // RDF
  static final _rdfType = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
  );
  static final _rdfProperty = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#Property',
  );
  static final _rdfLangString = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
  );
  static final _rdfXmlLiteral = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#XMLLiteral',
  );
  static final _rdfSubject = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#subject',
  );
  static final _rdfPredicate = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate',
  );
  static final _rdfObject = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#object',
  );
  static final _rdfStatement = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#Statement',
  );
  static final _rdfFirst = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#first',
  );
  static final _rdfRest = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#rest',
  );
  static final _rdfNil = Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#nil');
  static final _rdfList = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#List',
  );
  static final _rdfValue = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#value',
  );

  // RDFS
  static final _rdfsDomain = Iri('http://www.w3.org/2000/01/rdf-schema#domain');
  static final _rdfsRange = Iri('http://www.w3.org/2000/01/rdf-schema#range');
  static final _rdfsSubClassOf = Iri(
    'http://www.w3.org/2000/01/rdf-schema#subClassOf',
  );
  static final _rdfsSubPropertyOf = Iri(
    'http://www.w3.org/2000/01/rdf-schema#subPropertyOf',
  );
  static final _rdfsLiteral = Iri(
    'http://www.w3.org/2000/01/rdf-schema#Literal',
  );
  static final _rdfsDatatype = Iri(
    'http://www.w3.org/2000/01/rdf-schema#Datatype',
  );
  static final _rdfsContainerMembershipProperty = Iri(
    'http://www.w3.org/2000/01/rdf-schema#ContainerMembershipProperty',
  );
  static final _rdfsMember = Iri('http://www.w3.org/2000/01/rdf-schema#member');
  static final _rdfsClass = Iri('http://www.w3.org/2000/01/rdf-schema#Class');
  static final _rdfsResource = Iri(
    'http://www.w3.org/2000/01/rdf-schema#Resource',
  );
  static final _rdfsLabel = Iri('http://www.w3.org/2000/01/rdf-schema#label');
  static final _rdfsComment = Iri(
    'http://www.w3.org/2000/01/rdf-schema#comment',
  );
  static final _rdfsSeeAlso = Iri(
    'http://www.w3.org/2000/01/rdf-schema#seeAlso',
  );
  static final _rdfsIsDefinedBy = Iri(
    'http://www.w3.org/2000/01/rdf-schema#isDefinedBy',
  );

  // XSD
  static final _xsdString = Iri('http://www.w3.org/2001/XMLSchema#string');
  static final _xsdBoolean = Iri('http://www.w3.org/2001/XMLSchema#boolean');
  static final _xsdInteger = Iri('http://www.w3.org/2001/XMLSchema#integer');
  static final _xsdDecimal = Iri('http://www.w3.org/2001/XMLSchema#decimal');
  static final _xsdDateTime = Iri('http://www.w3.org/2001/XMLSchema#dateTime');

  RdfsReasoner(
    this._graph, {
    EntailmentRegime regime = EntailmentRegime.rdfs,
    Set<Iri> recognizedDatatypes = const {},
  }) : _regime = regime,
       _recognizedDatatypes = recognizedDatatypes.isEmpty
           ? {
               _xsdString,
               _xsdBoolean,
               _xsdInteger,
               _xsdDecimal,
               _xsdDateTime,
               _rdfLangString,
               _rdfXmlLiteral,
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
    _addAxiom(_rdfType, _rdfType, _rdfProperty);
    _addAxiom(_rdfSubject, _rdfType, _rdfProperty);
    _addAxiom(_rdfPredicate, _rdfType, _rdfProperty);
    _addAxiom(_rdfObject, _rdfType, _rdfProperty);
    _addAxiom(_rdfFirst, _rdfType, _rdfProperty);
    _addAxiom(_rdfRest, _rdfType, _rdfProperty);
    _addAxiom(_rdfValue, _rdfType, _rdfProperty);
    _addAxiom(_rdfNil, _rdfType, _rdfList);
  }

  void _addRdfsAxioms() {
    // Properties
    for (final p in [
      _rdfType,
      _rdfsDomain,
      _rdfsRange,
      _rdfsSubClassOf,
      _rdfsSubPropertyOf,
      _rdfsMember,
      _rdfsLabel,
      _rdfsComment,
      _rdfsSeeAlso,
      _rdfsIsDefinedBy,
      _rdfSubject,
      _rdfPredicate,
      _rdfObject,
      _rdfStatement,
      _rdfFirst,
      _rdfRest,
      _rdfValue,
    ]) {
      _addAxiom(p, _rdfType, _rdfProperty);
      _addAxiom(p, _rdfsDomain, _rdfsResource);
      _addAxiom(p, _rdfsRange, _rdfsResource);
    }

    _addAxiom(_rdfsDomain, _rdfsDomain, _rdfProperty);
    _addAxiom(_rdfsDomain, _rdfsRange, _rdfsClass);

    _addAxiom(_rdfsRange, _rdfsDomain, _rdfProperty);
    _addAxiom(_rdfsRange, _rdfsRange, _rdfsClass);

    _addAxiom(_rdfsSubPropertyOf, _rdfsDomain, _rdfProperty);
    _addAxiom(_rdfsSubPropertyOf, _rdfsRange, _rdfProperty);

    _addAxiom(_rdfsSubClassOf, _rdfsDomain, _rdfsClass);
    _addAxiom(_rdfsSubClassOf, _rdfsRange, _rdfsClass);

    _addAxiom(_rdfType, _rdfsDomain, _rdfsResource);
    _addAxiom(_rdfType, _rdfsRange, _rdfsClass);

    // Classes
    _addAxiom(_rdfsResource, _rdfType, _rdfsClass);
    _addAxiom(_rdfsClass, _rdfType, _rdfsClass);
    _addAxiom(_rdfsLiteral, _rdfType, _rdfsClass);
    _addAxiom(_rdfsDatatype, _rdfType, _rdfsClass);
    _addAxiom(_rdfStatement, _rdfType, _rdfsClass); // RDF Statement is a class
    _addAxiom(_rdfProperty, _rdfType, _rdfsClass);
    _addAxiom(_rdfsContainerMembershipProperty, _rdfsSubClassOf, _rdfProperty);
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
  /// "For each pair <s, l> where s forms the datatype of l ... s rdf:type rdfs:Datatype"
  bool _applyRdfD1() {
    bool changed = false;
    for (final d in _recognizedDatatypes) {
      final t = Triple(subject: d, predicate: _rdfType, object: _rdfsDatatype);
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
          predicate: _rdfType,
          object: _rdfProperty,
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
          Triple(subject: node, predicate: _rdfType, object: _rdfsDatatype),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs2() {
    bool changed = false;
    final domainTriples = _graph.match(predicate: _rdfsDomain);
    for (final t in domainTriples.toList()) {
      final p = t.subject;
      final c = t.object;
      if (p is! PredicateTerm) continue;
      final usages = _graph.match(predicate: p as PredicateTerm);
      for (final usage in usages.toList()) {
        if (_graph.add(
          Triple(subject: usage.subject, predicate: _rdfType, object: c),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs3() {
    bool changed = false;
    final rangeTriples = _graph.match(predicate: _rdfsRange);
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
            Triple(subject: u as SubjectTerm, predicate: _rdfType, object: c),
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
          Triple(subject: node, predicate: _rdfType, object: _rdfsResource),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }

  bool _applyRdfs5() {
    bool changed = false;
    final subPropTriples = _graph.match(predicate: _rdfsSubPropertyOf);
    // Transitivity
    for (final t1 in subPropTriples.toList()) {
      final u = t1.subject;
      final v = t1.object;
      if (v is! SubjectTerm) continue;
      final secondLegs = _graph.match(
        subject: v as SubjectTerm,
        predicate: _rdfsSubPropertyOf,
      );
      for (final t2 in secondLegs.toList()) {
        final x = t2.object;
        if (_graph.add(
          Triple(subject: u, predicate: _rdfsSubPropertyOf, object: x),
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
    final properties = _graph.match(predicate: _rdfType, object: _rdfProperty);
    for (final t in properties.toList()) {
      final p = t.subject;
      if (p is ObjectTerm) {
        if (_graph.add(
          Triple(
            subject: p,
            predicate: _rdfsSubPropertyOf,
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
    final subPropTriples = _graph.match(predicate: _rdfsSubPropertyOf);
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
    final classes = _graph.match(predicate: _rdfType, object: _rdfsClass);
    for (final t in classes.toList()) {
      if (_graph.add(
        Triple(
          subject: t.subject,
          predicate: _rdfsSubClassOf,
          object: _rdfsResource,
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
    final subClassTriples = _graph.match(predicate: _rdfsSubClassOf);
    for (final t in subClassTriples.toList()) {
      final c1 = t.subject;
      final c2 = t.object;
      if (c1 is! ObjectTerm) continue;
      final instances = _graph.match(
        predicate: _rdfType,
        object: c1 as ObjectTerm,
      );
      for (final i in instances.toList()) {
        if (_graph.add(
          Triple(subject: i.subject, predicate: _rdfType, object: c2),
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
    final classes = _graph.match(predicate: _rdfType, object: _rdfsClass);
    for (final t in classes.toList()) {
      final c = t.subject;
      if (c is ObjectTerm) {
        if (_graph.add(
          Triple(
            subject: c,
            predicate: _rdfsSubClassOf,
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
    final subClassTriples = _graph.match(predicate: _rdfsSubClassOf);
    for (final t1 in subClassTriples.toList()) {
      final u = t1.subject;
      final v = t1.object;
      if (v is! SubjectTerm) continue;
      final secondLegs = _graph.match(
        subject: v as SubjectTerm,
        predicate: _rdfsSubClassOf,
      );
      for (final t2 in secondLegs.toList()) {
        final x = t2.object;
        if (_graph.add(
          Triple(subject: u, predicate: _rdfsSubClassOf, object: x),
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
      predicate: _rdfType,
      object: _rdfsContainerMembershipProperty,
    );
    for (final t in props.toList()) {
      if (_graph.add(
        Triple(
          subject: t.subject,
          predicate: _rdfsSubPropertyOf,
          object: _rdfsMember,
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
    final dts = _graph.match(predicate: _rdfType, object: _rdfsDatatype);
    for (final t in dts.toList()) {
      if (_graph.add(
        Triple(
          subject: t.subject,
          predicate: _rdfsSubClassOf,
          object: _rdfsLiteral,
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
    for (final node in _graph.nodes) {
      if (node is Iri && _cmpRegExp.hasMatch(node.toString())) {
        if (_graph.add(
          Triple(
            subject: node,
            predicate: _rdfType,
            object: _rdfsContainerMembershipProperty,
          ),
        )) {
          changed = true;
        }
      }
    }
    return changed;
  }
}
