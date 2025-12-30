import 'package:rdf_dart/rdf_dart.dart';

void main() {
  // 1. Create an empty Graph
  final graph = InMemoryGraph();

  // -- Vocabulary --

  // Our Custom Vocabulary
  final animal = Iri('http://example.org/Animal');
  final dog = Iri('http://example.org/Dog');

  final hasParent = Iri('http://example.org/hasParent');
  final hasFather = Iri('http://example.org/hasFather');
  final hasAge = Iri('http://example.org/hasAge');
  final likes = Iri('http://example.org/likes');
  final claims = Iri('http://example.org/claims');

  final fido = Iri('http://example.org/Fido');
  final rex = Iri('http://example.org/Rex');

  print('--- Setting up Graph ---');

  // 2. Define the Schema (The Rules of our World)

  // "Dog is a subclass of Animal"
  graph.add(Triple(subject: dog, predicate: Rdfs.subClassOf, object: animal));

  // "hasFather is a sub-property of hasParent"
  graph.add(
    Triple(
      subject: hasFather,
      predicate: Rdfs.subPropertyOf,
      object: hasParent,
    ),
  );

  // "Dog is a Class" (Triggers rdfs8 & rdfs10)
  graph.add(Triple(subject: dog, predicate: Rdf.type, object: Rdfs.Class));

  // "hasFather is a Property" (Triggers rdfs6)
  graph.add(
    Triple(subject: hasFather, predicate: Rdf.type, object: Rdf.Property),
  );

  graph.add(Triple(subject: hasAge, predicate: Rdf.type, object: Rdf.Property));
  graph.add(Triple(subject: rex, predicate: likes, object: fido));
  graph.add(
    Triple(
      subject: rex,
      predicate: claims,
      object: TripleTerm(Triple(subject: fido, predicate: likes, object: rex)),
    ),
  );

  // 3. Add Instance Data (The Facts)

  // "Fido is a Dog"
  graph.add(Triple(subject: fido, predicate: Rdf.type, object: dog));

  // "Fido has father Rex"
  graph.add(Triple(subject: fido, predicate: hasFather, object: rex));

  graph.add(
    Triple(
      subject: fido,
      predicate: hasAge,
      object: Literal("5", datatypeIri: Xsd.unsignedByte),
    ),
  );

  graph.add(
    Triple(
      subject: rex,
      predicate: hasAge,
      object: Literal("35", datatypeIri: Xsd.unsignedByte),
    ),
  );

  print('Initial Graph Size: ${graph.length} triples');
  print(nTriplesCodec.encode(graph.triples));

  // 4. Run the Reasoner
  print('\n--- Running Reasoner ---');
  final reasoner = RdfsReasoner(graph);
  reasoner.apply();

  // 5. Check the Results
  print(
    '\n--- Reasoning Complete. Final Graph Size: ${graph.length} triples ---',
  );
  print('Inferred Facts:');

  // Check Rule rdfs9 (Inheritance): Is Fido an Animal?
  final isAnimal = graph.contains(
    Triple(subject: fido, predicate: Rdf.type, object: animal),
  );
  print('1. Is Fido an Animal? ${isAnimal ? "YES (Inferred)" : "NO"}');

  // Check Rule rdfs7 (Property Logic): Does Fido have a parent Rex?
  final hasParentRex = graph.contains(
    Triple(subject: fido, predicate: hasParent, object: rex),
  );
  print(
    '2. Does Fido have a parent Rex? ${hasParentRex ? "YES (Inferred)" : "NO"}',
  );

  // Check Rule rdfs10 (Reflexivity): Is Dog a subClass of Dog?
  final dogIsDog = graph.contains(
    Triple(subject: dog, predicate: Rdfs.subClassOf, object: dog),
  );
  print(
    '3. Is Dog a subClass of itself? ${dogIsDog ? "YES (Inferred)" : "NO"}',
  );

  print('\nAll Triples in Graph:');

  print(nTriplesCodec.encode(graph.triples));

  print('\n -- Graph Edges --');
  print(graph.nodes);
}
