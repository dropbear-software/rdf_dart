import 'term.dart';

/// An asserted RDF Triple.
///
/// A triple consists of a [Subject], a [Predicate], and a [TripleObject].
/// It represents a statement in an RDF graph.
class Triple {
  /// The subject of the triple.
  final Subject subject;

  /// The predicate of the triple.
  final Predicate predicate;

  /// The object of the triple.
  final TripleObject object;

  /// Creates a new [Triple].
  ///
  /// The types of [subject], [predicate], and [object] are statically checked
  /// to ensure they are valid RDF terms for their respective positions.
  Triple({
    required this.subject,
    required this.predicate,
    required this.object,
  });

  @override
  String toString() => '$subject $predicate $object .';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Triple &&
          runtimeType == other.runtimeType &&
          subject == other.subject &&
          predicate == other.predicate &&
          object == other.object;

  @override
  int get hashCode => Object.hash(subject, predicate, object);

  /// The groundness of this triple.
  ///
  /// An [Triple] is said to be ground if its [subject], [predicate], and [object] are all ground.
  bool get isGround {
    return subject.isGround && predicate.isGround && object.isGround;
  }
}
