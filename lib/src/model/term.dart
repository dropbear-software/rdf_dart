/// The base interface for all RDF terms.
///
/// This serves as a common root for all types that can appear in an RDF graph.
abstract interface class RdfTerm {
  /// The groundness of this term.
  ///
  /// An [RdfTerm] is said to be ground if it is an [Iri], a [Literal],
  /// or a [TripleTerm] where its subject, predicate, and object are all ground.
  /// [BlankNode]s are never ground.
  bool get isGround;
}

/// A marker interface for terms that can appear in the subject position of a triple.
///
/// In RDF 1.2, this includes [Iri] and [BlankNode].
abstract interface class Subject implements RdfTerm {}

/// A marker interface for terms that can appear in the predicate position of a triple.
///
/// In RDF 1.2, this includes [Iri].
abstract interface class Predicate implements RdfTerm {}

/// A marker interface for terms that can appear in the object position of a triple.
///
/// In RDF 1.2, this includes [Iri], [BlankNode], [Literal], and [TripleTerm].
abstract interface class TripleObject implements RdfTerm {}

/// A marker interface for terms that can be used as a graph name in a dataset.
///
/// In RDF 1.2, this includes [Iri] and [BlankNode].
abstract interface class GraphName implements RdfTerm {}
