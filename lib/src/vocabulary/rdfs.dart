import '../model/iri.dart';

/// The RDFS vocabulary.
class Rdfs {
  Rdfs._();

  static const String namespace = 'http://www.w3.org/2000/01/rdf-schema#';

  static final resource = Iri('${namespace}Resource');
  // ignore: non_constant_identifier_names
  static final Class = Iri('${namespace}Class');
  static final subClassOf = Iri('${namespace}subClassOf');
  static final subPropertyOf = Iri('${namespace}subPropertyOf');
  static final comment = Iri('${namespace}comment');
  static final label = Iri('${namespace}label');
  static final domain = Iri('${namespace}domain');
  static final range = Iri('${namespace}range');
  static final seeAlso = Iri('${namespace}seeAlso');
  static final isDefinedBy = Iri('${namespace}isDefinedBy');
  static final literal = Iri('${namespace}Literal');
  static final datatype = Iri('${namespace}Datatype');
  static final containerMembershipProperty = Iri(
    '${namespace}ContainerMembershipProperty',
  );
  static final member = Iri('${namespace}member');
  static final proposition = Iri('${namespace}Proposition');
}
