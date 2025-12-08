import '../model/blank_node.dart';
import '../model/graph.dart';
import '../model/iri.dart';
import '../model/literal.dart';
import '../model/term.dart';
import '../model/triple.dart';
import '../model/triple_term.dart';

class RDFSReasoner {
  final Graph _graph;

  // -- Vocabulary Constants --
  static final _rdfType = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
  );
  static final _rdfProperty = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#Property',
  );
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

  static final _rdfsProposition = Iri(
    'http://www.w3.org/2000/01/rdf-schema#Proposition',
  );

  // "D": The set of datatypes this reasoner explicitly recognizes/supports
  static final _recognizedDatatypes = {
    Iri('http://www.w3.org/2001/XMLSchema#string'),
    Iri('http://www.w3.org/2001/XMLSchema#integer'),
    Iri('http://www.w3.org/2001/XMLSchema#boolean'),
    Iri('http://www.w3.org/2001/XMLSchema#dateTime'),
    Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#langString'),
    // Add others you want to support
  };

  RDFSReasoner(this._graph);

  /// Executes the reasoning process until no new triples can be inferred.
  void apply() {
    bool changed = true;
    int pass = 1;

    while (changed) {
      changed = false;
      // We OR the results so that if ANY rule adds a triple, we loop again.
      // Order matters slightly for efficiency, but eventually, all valid facts will be found.

      changed |= _applyRdfD2();
      changed |= _applyRdfs1();
      changed |= _applyRdfs2();
      changed |= _applyRdfs3();
      changed |= _applyRdfs4();
      changed |= _applyRdfs5();
      changed |= _applyRdfs6();
      changed |= _applyRdfs7();
      changed |= _applyRdfs8();
      changed |= _applyRdfs9();
      changed |= _applyRdfs10();
      changed |= _applyRdfs11();
      changed |= _applyRdfs12();
      changed |= _applyRdfs13();
      changed |= _applyRdfs14();

      if (changed) {
        print('Pass $pass completed. New inferences found.');
        pass++;
      }
    }
  }

  /// Rule rdfD2: If a triple (s p o) exists -> p rdf:type rdf:Property
  bool _applyRdfD2() {
    bool changed = false;

    for (final triple in _graph.triples.toList()) {
      final predicate = triple.predicate;

      final inferred = Triple(
        subject:
            predicate as SubjectTerm, // Safe cast required for Dart type system
        predicate: _rdfType,
        object: _rdfProperty,
      );

      if (_graph.add(inferred)) {
        changed = true;
        print('Rule rdfD2 inferred: $inferred');
      }
    }
    return changed;
  }

  /// Rule rdfs1: If a recognized datatype IRI appears in the graph -> (iri rdf:type rdfs:Datatype)
  bool _applyRdfs1() {
    bool changed = false;
    final usedDatatypes = <Iri>{};

    // 1. Scan the graph to find used datatypes
    // We must check Literals specifically, as that is where datatypes hide.
    for (final triple in _graph.triples) {
      final object = triple.object;

      // Check Literals
      if (object is Literal) {
        usedDatatypes.add(object.datatypeIri);
      }

      // Also check if the IRI is used explicitly as a Subject or Object node
      // (e.g., someone wrote: ex:myProperty rdfs:range xsd:integer)
      if (triple.subject is Iri) usedDatatypes.add(triple.subject as Iri);
      if (triple.object is Iri) usedDatatypes.add(triple.object as Iri);
      if (triple.predicate is Iri) usedDatatypes.add(triple.predicate as Iri);
    }

    // 2. Intersect "Used" with "Recognized"
    // We only reason about types we know (D).
    final recognizedAndUsed = usedDatatypes.intersection(_recognizedDatatypes);

    for (final datatypeIri in recognizedAndUsed) {
      // 3. Infer that it is a rdfs:Datatype
      final inferred = Triple(
        subject: datatypeIri,
        predicate: _rdfType,
        object: _rdfsDatatype,
      );

      if (_graph.add(inferred)) {
        changed = true;
        print('Rule rdfs1 inferred: $inferred');
      }
    }
    return changed;
  }

  /// Rule rdfs2: If (aaa rdfs:domain xxx) and (uuu aaa yyy) -> (uuu rdf:type xxx)
  bool _applyRdfs2() {
    bool changed = false;

    // 1. Find all domain declarations
    final domainTriples = _graph.match(predicate: _rdfsDomain);

    for (final t in domainTriples.toList()) {
      final property = t.subject; // 'aaa'
      final domainClass = t.object; // 'xxx'

      // Ideally check if property is PredicateTerm, but graph.match handles type safety
      if (property is! PredicateTerm) continue;

      // 2. Find all usages of that property
      final usages = _graph.match(predicate: property as PredicateTerm);

      for (final usage in usages.toList()) {
        final instance = usage.subject; // 'uuu'

        // 3. Infer the type
        final inferred = Triple(
          subject: instance,
          predicate: _rdfType,
          object: domainClass,
        );

        if (_graph.add(inferred)) changed = true;
      }
    }
    return changed;
  }

  /// Rule rdfs3: If (aaa rdfs:range xxx) and (uuu aaa vvv) -> (vvv rdf:type xxx)
  bool _applyRdfs3() {
    bool changed = false;
    final rangeTriples = _graph.match(predicate: _rdfsRange);

    for (final t in rangeTriples.toList()) {
      final property = t.subject;
      final rangeClass = t.object;

      if (property is! PredicateTerm) continue;

      final usages = _graph.match(predicate: property as PredicateTerm);

      for (final usage in usages.toList()) {
        final value = usage.object; // 'vvv'

        // Literals cannot be subjects, so we can only add rdf:type if value is a SubjectTerm (IRI or BNode)
        if (value is SubjectTerm) {
          final inferred = Triple(
            subject: value as SubjectTerm,
            predicate: _rdfType,
            object: rangeClass,
          );
          if (_graph.add(inferred)) changed = true;
        }
      }
    }
    return changed;
  }

  /// Rule rdfs4: Everything that appears in the graph is an rdfs:Resource
  bool _applyRdfs4() {
    bool changed = false;
    final allTerms = <RdfTerm>{};

    // 1. Harvest every term from every triple recursively
    for (final triple in _graph.triples) {
      _collectTermsRecursively(triple, allTerms);
    }

    // 2. Assert that they are Resources
    for (final term in allTerms) {
      // Constraint Check: Your library (correctly) enforces that Literals
      // cannot be the Subject of a triple.
      // So we only generate this fact if the term is capable of being a Subject.
      if (term is SubjectTerm) {
        final inferred = Triple(
          subject: term,
          predicate: _rdfType,
          object: _rdfsResource,
        );

        if (_graph.add(inferred)) {
          changed = true;
          // This rule is very noisy, so you might want to comment out this print
          print('Rule rdfs4 inferred: $inferred');
        }
      }
    }
    return changed;
  }

  /// Rule rdfs5: (Transitivity of subPropertyOf)
  /// If (p1 subPropertyOf p2) and (p2 subPropertyOf p3) -> (p1 subPropertyOf p3)
  bool _applyRdfs5() {
    bool changed = false;

    // 1. Find all subproperty relations: ?p1 rdfs:subPropertyOf ?p2
    final subPropTriples = _graph.match(predicate: _rdfsSubPropertyOf);

    // This nested loop approach is O(N^2) relative to the number of subProperty assertions.
    // For most ontologies (which have few property definitions compared to data), this is fine.
    for (final t1 in subPropTriples.toList()) {
      final p1 = t1.subject;
      final p2 = t1.object;

      // Ensure valid types for the next query
      if (p2 is! SubjectTerm) continue;

      // 2. Find relations where ?p2 is the subproperty: ?p2 rdfs:subPropertyOf ?p3
      final parentRelations = _graph.match(
        subject: p2 as SubjectTerm,
        predicate: _rdfsSubPropertyOf,
      );

      for (final t2 in parentRelations.toList()) {
        final p3 = t2.object;

        // 3. Create the inferred shortcut: ?p1 rdfs:subPropertyOf ?p3
        // Only if p3 is valid in Object position (which it always is)
        final inferred = Triple(
          subject: p1, // p1 was a subject in t1, so it's a SubjectTerm
          predicate: _rdfsSubPropertyOf,
          object: p3,
        );

        if (_graph.add(inferred)) {
          changed = true;
          print('Rule rdfs5 inferred: $inferred');
        }
      }
    }
    return changed;
  }

  /// Rule rdfs6: If (x rdf:type rdf:Property) -> (x rdfs:subPropertyOf x)
  bool _applyRdfs6() {
    bool changed = false;

    // 1. Find everything defined as a Property
    final propertyDefinitions = _graph.match(
      predicate: _rdfType,
      object: _rdfProperty,
    );

    for (final t in propertyDefinitions.toList()) {
      final property = t.subject;

      // 2. Infer that it is a subProperty of itself
      // property is a SubjectTerm (from t.subject).
      // We cast it to ObjectTerm for the object position (IRIs and BNodes implement both).
      if (property is ObjectTerm) {
        final inferred = Triple(
          subject: property,
          predicate: _rdfsSubPropertyOf,
          object: property as ObjectTerm,
        );

        if (_graph.add(inferred)) {
          changed = true;
          print('Rule rdfs6 inferred: $inferred');
        }
      }
    }
    return changed;
  }

  /// Rule rdfs10: If (x rdf:type rdf:Class) -> (x rdfs:subClassOf x)
  bool _applyRdfs10() {
    bool changed = false;

    // 1. Find everything defined as a Class
    final propertyDefinitions = _graph.match(
      predicate: _rdfType,
      object: _rdfsClass,
    );

    for (final t in propertyDefinitions.toList()) {
      final property = t.subject;

      // 2. Infer that it is a subClass of itself
      // property is a SubjectTerm (from t.subject).
      // We cast it to ObjectTerm for the object position (IRIs and BNodes implement both).
      if (property is ObjectTerm) {
        final inferred = Triple(
          subject: property,
          predicate: _rdfsSubClassOf,
          object: property as ObjectTerm,
        );

        if (_graph.add(inferred)) {
          changed = true;
          print('Rule rdfs10 inferred: $inferred');
        }
      }
    }
    return changed;
  }

  /// Rule rdfs7: If (aaa rdfs:subPropertyOf bbb) and (uuu aaa yyy) -> (uuu bbb yyy)
  bool _applyRdfs7() {
    bool changed = false;
    final subPropTriples = _graph.match(predicate: _rdfsSubPropertyOf);

    for (final t in subPropTriples.toList()) {
      final subProp = t.subject; // 'aaa'
      final superProp = t.object; // 'bbb'

      if (subProp is! PredicateTerm || superProp is! PredicateTerm) continue;

      // Find data using the sub-property
      final usages = _graph.match(predicate: subProp as PredicateTerm);

      for (final usage in usages.toList()) {
        final inferred = Triple(
          subject: usage.subject,
          predicate: superProp as PredicateTerm,
          object: usage.object,
        );
        if (_graph.add(inferred)) changed = true;
      }
    }
    return changed;
  }

  /// Rule rdfs9: If (xxx rdfs:subClassOf yyy) and (zzz rdf:type xxx) -> (zzz rdf:type yyy)
  bool _applyRdfs9() {
    bool changed = false;
    final subClassTriples = _graph.match(predicate: _rdfsSubClassOf);

    for (final t in subClassTriples.toList()) {
      final subClass = t.subject; // 'xxx'
      final superClass = t.object; // 'yyy'

      if (subClass is! ObjectTerm) continue;

      // Find instances of the subclass
      final instances = _graph.match(
        predicate: _rdfType,
        object: subClass as ObjectTerm,
      );

      for (final instance in instances.toList()) {
        final inferred = Triple(
          subject: instance.subject,
          predicate: _rdfType,
          object: superClass,
        );
        if (_graph.add(inferred)) changed = true;
      }
    }
    return changed;
  }

  /// Rule rdfs11: (Transitivity of subClassOf)
  /// If (xxx subClassOf yyy) and (yyy subClassOf zzz) -> (xxx subClassOf zzz)
  bool _applyRdfs11() {
    bool changed = false;
    final subClassTriples = _graph.match(predicate: _rdfsSubClassOf);

    // This is O(N^2) in the worst case, be careful with large ontologies
    for (final t1 in subClassTriples.toList()) {
      final classX = t1.subject;
      final classY = t1.object;

      // Find what Y is a subclass of
      if (classY is! SubjectTerm) continue;

      final superClassesOfY = _graph.match(
        subject: classY as SubjectTerm,
        predicate: _rdfsSubClassOf,
      );

      for (final t2 in superClassesOfY.toList()) {
        final classZ = t2.object;

        final inferred = Triple(
          subject: classX,
          predicate: _rdfsSubClassOf,
          object: classZ,
        );
        if (_graph.add(inferred)) changed = true;
      }
    }
    return changed;
  }

  // Rule rdfs8: If (x rdf:type rdfs:Class) -> (x rdfs:subClassOf rdfs:Resource)
  bool _applyRdfs8() {
    bool changed = false;

    // 1. Find everything defined as a Class
    final classDefinitions = _graph.match(
      predicate: _rdfType,
      object: _rdfsClass,
    );

    for (final t in classDefinitions.toList()) {
      final classDefinition = t.subject;

      // 2. Infer that it is a subclass of rdfs:Resource
      final inferred = Triple(
        subject: classDefinition,
        predicate: _rdfsSubClassOf,
        object: _rdfsResource,
      );

      if (_graph.add(inferred)) {
        changed = true;
        print('Rule rdfs8 inferred: $inferred');
      }
    }
    return changed;
  }

  // Rule rdfs12: If (x rdf:type rdfs:ContainerMembershipProperty) -> (x rdfs:subPropertyOf rdfs:member)
  bool _applyRdfs12() {
    bool changed = false;

    // 1. Find everything defined as a ContainerMembershipProperty
    final definitions = _graph.match(
      predicate: _rdfType,
      object: _rdfsContainerMembershipProperty,
    );

    for (final t in definitions.toList()) {
      final property = t.subject; // Renamed from 'datatype' for clarity

      // 2. Infer that it is a subproperty of rdfs:member
      final inferred = Triple(
        subject: property,
        predicate: _rdfsSubPropertyOf,
        object: _rdfsMember,
      );

      if (_graph.add(inferred)) {
        changed = true;
        print('Rule rdfs12 inferred: $inferred');
      }
    }
    return changed;
  }

  /// Rule rdfs13: If (x rdf:type rdfs:Datatype) -> (x rdfs:subClassOf rdfs:Literal)
  bool _applyRdfs13() {
    bool changed = false;

    // 1. Find everything defined as a Datatype
    final datatypeDefinitions = _graph.match(
      predicate: _rdfType,
      object: _rdfsDatatype,
    );

    for (final t in datatypeDefinitions.toList()) {
      final datatype = t.subject;

      // 2. Infer that it is a subclass of rdfs:Literal
      // We know datatype is a SubjectTerm because it is the subject of 't'
      final inferred = Triple(
        subject: datatype,
        predicate: _rdfsSubClassOf,
        object: _rdfsLiteral,
      );

      if (_graph.add(inferred)) {
        changed = true;
        print('Rule rdfs13 inferred: $inferred');
      }
    }
    return changed;
  }

  /// Rule rdfs14: Unpacks TripleTerms into Blank Nodes of type rdfs:Proposition.
  bool _applyRdfs14() {
    bool changed = false;

    final termToProposition = <TripleTerm, BlankNode>{};
    final tripleTermOccurrences = <Triple, Set<TripleTerm>>{};

    // 1. Identify all TripleTerms used in the graph
    for (final triple in _graph.triples) {
      final termsInTriple = <TripleTerm>{};
      _collectTripleTerms(triple, termsInTriple);

      if (termsInTriple.isNotEmpty) {
        tripleTermOccurrences[triple] = termsInTriple;
      }
    }

    // 2. Generate Inferences
    for (final entry in tripleTermOccurrences.entries) {
      final sourceTriple = entry.key;
      final foundTerms = entry.value;

      for (final term in foundTerms) {
        final propositionNode = termToProposition.putIfAbsent(term, () {
          final newBNode = BlankNode();
          final propDecl = Triple(
            subject: newBNode,
            predicate: _rdfType,
            object: _rdfsProposition,
          );
          if (_graph.add(propDecl)) changed = true;
          return newBNode;
        });

        final newTriple = _substituteInTriple(
          sourceTriple,
          term,
          propositionNode,
        );

        if (_graph.add(newTriple)) {
          changed = true;
          print('Rule rdfs14 inferred: $newTriple');
        }
      }
    }
    return changed;
  }

  /// Helper: Recursively find all TripleTerms appearing in a Triple.
  void _collectTripleTerms(Triple triple, Set<TripleTerm> accumulator) {
    // In RDF 1.2, Subjects cannot be TripleTerms.
    // We only inspect the Object.
    if (triple.object is TripleTerm) {
      final tt = triple.object as TripleTerm;
      accumulator.add(tt);
      // Recurse: The triple inside the TripleTerm might have an Object that is ALSO a TripleTerm
      _collectTripleTerms(tt.triple, accumulator);
    }
  }

  /// Helper: Create a new Triple where [target] is replaced by [replacement].
  /// Corrected: Subject is passed through as-is.
  Triple _substituteInTriple(
    Triple source,
    TripleTerm target,
    BlankNode replacement,
  ) {
    // 1. Subject never changes in standard RDF 1.2 substitution
    final newSubject = source.subject;

    // 2. Check Object
    ObjectTerm newObject = source.object;

    if (source.object == target) {
      // Found it! Replace with the Blank Node.
      newObject = replacement;
    } else if (source.object is TripleTerm) {
      // Recursive step: It's a TripleTerm, but not the one we are looking for.
      // We must drill down into IT to see if our target is nested deeper.
      newObject = TripleTerm(
        _substituteInTriple(
          (source.object as TripleTerm).triple,
          target,
          replacement,
        ),
      );
    }

    return Triple(
      subject: newSubject,
      predicate: source.predicate,
      object: newObject,
    );
  }

  /// Recursive helper to find all terms "appearing in" a triple.
  void _collectTermsRecursively(Triple triple, Set<RdfTerm> distinctTerms) {
    // 1. The immediate Subject, Predicate, and Object "appear in" the triple.
    distinctTerms.add(triple.subject);
    distinctTerms.add(triple.predicate);
    distinctTerms.add(triple.object);

    // 2. The Recursive Step (RDF 1.2)
    // If the object is a TripleTerm, we must look inside it.
    if (triple.object is TripleTerm) {
      final nestedTriple = (triple.object as TripleTerm).triple;
      _collectTermsRecursively(nestedTriple, distinctTerms);
    }
  }
}
