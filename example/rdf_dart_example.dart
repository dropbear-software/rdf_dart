import 'package:rdf_dart/rdf_dart.dart';

void main() {
  final s = NamedNode('http://example.org/subject');
  final p = NamedNode('http://example.org/predicate');
  final o = Literal(
    'Hello World',
    datatype: NamedNode('http://www.w3.org/2001/XMLSchema#string'),
  );

  final triple = Triple(subject: s, predicate: p, object: o);

  print('Created triple: $triple');
}
