// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import '../model/iri.dart';

/// The RDF vocabulary.
class Rdf {
  Rdf._();

  static const String namespace = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

  static final type = Iri('${namespace}type');
  static final Property = Iri('${namespace}Property');
  static final langString = Iri('${namespace}langString');
  static final dirLangString = Iri('${namespace}dirLangString');
  static final XMLLiteral = Iri('${namespace}XMLLiteral');
  static final subject = Iri('${namespace}subject');
  static final predicate = Iri('${namespace}predicate');
  static final object = Iri('${namespace}object');
  static final Statement = Iri('${namespace}Statement');
  static final first = Iri('${namespace}first');
  static final rest = Iri('${namespace}rest');
  static final nil = Iri('${namespace}nil');
  static final List = Iri('${namespace}List');
  static final value = Iri('${namespace}value');
  static final reifies = Iri('${namespace}reifies');
}
