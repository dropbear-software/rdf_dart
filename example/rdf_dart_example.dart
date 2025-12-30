import 'package:rdf_dart/rdf_dart.dart';

void main() {
  final s = Iri('http://example.org/subject');
  final p = Iri('http://example.org/predicate');
  final o = Literal('Hello World', datatypeIri: Xsd.string);

  final triple = Triple(subject: s, predicate: p, object: o);

  print('Created triple: $triple');
}
