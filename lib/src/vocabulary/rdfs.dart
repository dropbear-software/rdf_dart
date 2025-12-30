// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import '../model/iri.dart';

/// The RDFS vocabulary.
class Rdfs {
  Rdfs._();

  static const String namespace = 'http://www.w3.org/2000/01/rdf-schema#';

  static final Resource = Iri('${namespace}Resource');
  static final Class = Iri('${namespace}Class');
  static final subClassOf = Iri('${namespace}subClassOf');
  static final subPropertyOf = Iri('${namespace}subPropertyOf');
  static final comment = Iri('${namespace}comment');
  static final label = Iri('${namespace}label');
  static final domain = Iri('${namespace}domain');
  static final range = Iri('${namespace}range');
  static final seeAlso = Iri('${namespace}seeAlso');
  static final isDefinedBy = Iri('${namespace}isDefinedBy');
  static final Literal = Iri('${namespace}Literal');
  static final Datatype = Iri('${namespace}Datatype');
  static final ContainerMembershipProperty = Iri(
    '${namespace}ContainerMembershipProperty',
  );
  static final member = Iri('${namespace}member');
  static final Proposition = Iri('${namespace}Proposition');
}
