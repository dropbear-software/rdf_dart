import 'package:rdf_dart/rdf_dart.dart';

void main(List<String> args) async {
  final fileContents = '''
PREFIX : <http://example/>

:s :p :o ~ :i1 ~:i2 {| :r :z |} .

''';

  final results = Set<Triple>.from(turtleCodec.decode(fileContents));
  final graph = InMemoryGraph()..addAll(results);

  print(nTriplesCodec.encode(graph.triples));
}
