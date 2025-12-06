// plain import is fine now

/// The base interface for all RDF terms.
///
/// This serves as a common root for all types that can appear in an RDF graph.
abstract interface class Term {}

/// A marker interface for terms that can appear in the subject position of a triple.
///
/// In RDF 1.2, this includes [Iri] and [BlankNode].
abstract interface class Subject implements Term {}

/// A marker interface for terms that can appear in the predicate position of a triple.
///
/// In RDF 1.2, this includes [Iri].
abstract interface class Predicate implements Term {}

/// A marker interface for terms that can appear in the object position of a triple.
///
/// In RDF 1.2, this includes [Iri], [BlankNode], [Literal], and [TripleTerm].
abstract interface class TripleObject implements Term {}

/// A marker interface for terms that can be used as a graph name in a dataset.
///
/// In RDF 1.2, this includes [Iri] and [BlankNode].
abstract interface class GraphName implements Term {}
