import 'term.dart';
import 'triple.dart';

/// An RDF 1.2 Triple Term.
///
/// A triple term is a [Triple] used as a resource (specifically as an [Object])
/// in another triple. It essentially "quotes" the triple.
///
/// Triple terms allow valid RDF-star (Triple Terms) syntax.
class TripleTerm implements Term, TripleObject {
  /// The underlying triple.
  final Triple triple;

  /// Creates a [TripleTerm] wrapping the given [triple].
  TripleTerm(this.triple);

  @override
  String toString() => '<<( $triple )>>';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripleTerm &&
          runtimeType == other.runtimeType &&
          triple == other.triple;

  @override
  int get hashCode => triple.hashCode;
}
