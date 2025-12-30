import '../model/iri.dart';

/// The RDF vocabulary.
class Rdf {
  Rdf._();

  static const String namespace = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#';

  static final type = Iri('${namespace}type');
  static final property = Iri('${namespace}Property');
  static final langString = Iri('${namespace}langString');
  static final dirLangString = Iri('${namespace}dirLangString');
  static final xmlLiteral = Iri('${namespace}XMLLiteral');
  static final subject = Iri('${namespace}subject');
  static final predicate = Iri('${namespace}predicate');
  static final object = Iri('${namespace}object');
  static final statement = Iri('${namespace}Statement');
  static final first = Iri('${namespace}first');
  static final rest = Iri('${namespace}rest');
  static final nil = Iri('${namespace}nil');
  static final list = Iri('${namespace}List');
  static final value = Iri('${namespace}value');
  static final reifies = Iri('${namespace}reifies');
}
