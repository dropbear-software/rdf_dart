import 'named_node.dart';
import 'term.dart';

/// An RDF Literal.
///
/// Literals are used for values such as strings, numbers, and dates.
/// A literal consists of a lexical form (string), a datatype IRI, and optionally
/// a language tag (if the datatype is `rdf:langString`).
class Literal implements Term, TripleObject {
  /// The lexical form of the literal.
  @override
  final String value;

  /// The datatype IRI of the literal.
  final NamedNode datatype;

  /// The language tag, if any.
  ///
  /// This must be non-null if and only if [datatype] is `rdf:langString`.
  final String? language;

  /// Creates a literal.
  ///
  /// [value] is the lexical form.
  /// [datatype] is the datatype IRI.
  /// [language] is the optional language tag.
  Literal(this.value, {required this.datatype, this.language});

  @override
  String toString() {
    if (language != null) {
      return '"$value"@$language';
    } else {
      return '"$value"^^$datatype';
    }
  }

  @override
  bool operator ==(
    Object other,
  ) => // Explicitly using core.Object due to name collision
      identical(this, other) ||
      other is Literal &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          datatype == other.datatype &&
          language == other.language;

  @override
  int get hashCode => Object.hash(value, datatype, language);
}
