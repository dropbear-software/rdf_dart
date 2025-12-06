import 'package:intl/intl.dart' as intl;
import 'package:xsd/xsd.dart' as xsd;

import 'named_node.dart';
import 'term.dart';

/// An RDF Literal.
///
/// Literals are used for values such as strings, numbers, and dates.
/// A literal consists of:
/// 1. A [lexicalForm] (the string representation).
/// 2. A [datatype] IRI.
/// 3. An optional [language] tag (for `rdf:langString`).
/// 4. An optional [direction] (for `rdf:dirLangString`).
class Literal implements Term, TripleObject {
  /// The lexical form of the literal.
  final String lexicalForm;

  /// The datatype IRI of the literal.
  final NamedNode datatype;

  /// The language tag, if any.
  ///
  /// This must be non-null if and only if [datatype] is `rdf:langString`
  /// or `rdf:dirLangString`.
  final String? language;

  /// The base direction, if any.
  ///
  /// This must be non-null if and only if [datatype] is `rdf:dirLangString`.
  final intl.TextDirection? direction;

  /// The typed value of this literal, mapped from the lexical form.
  ///
  /// If the literal is ill-typed (the lexical form is not valid for the datatype),
  /// or if the datatype is not supported, this may be null (or the raw string,
  /// depending on xsd package behavior, strictly speaking for unknown datatypes
  /// it is not defined, for ill-typed it is 'ill-typed').
  ///
  /// In this implementation:
  /// - For supported XSD types, this returns the parsed Dart object (e.g. [int], [DateTime]).
  /// - If parsing fails (ill-typed), this returns `null`.
  /// - For `rdf:langString` / `rdf:dirLangString`, this returns the [lexicalForm].
  /// - For unknown datatypes, this returns the [lexicalForm].
  final Object? value;

  /// Creates a literal.
  ///
  /// [lexicalForm] is the string representation.
  /// [datatype] is the datatype IRI. Defaults to `xsd:string` if not provided,
  /// unless [language] is present (defaults to `rdf:langString`) or
  /// [direction] is present (defaults to `rdf:dirLangString`).
  factory Literal(
    String lexicalForm, {
    NamedNode? datatype,
    String? language,
    intl.TextDirection? direction,
  }) {
    // Determine datatype if not provided
    if (datatype == null) {
      if (direction != null) {
        datatype = NamedNode(
          'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString',
        );
      } else if (language != null) {
        datatype = NamedNode(
          'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
        );
      } else {
        datatype = NamedNode('http://www.w3.org/2001/XMLSchema#string');
      }
    }

    // Validate datatype vs language/direction constraints based on RDF 1.2
    // If and only if datatype is langString, language must be non-null and direction must be null.
    // If and only if datatype is dirLangString, language must be non-null and direction must be non-null.
    // Otherwise, language and direction must be null.

    final iri = datatype.iri.toString();
    if (iri == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString') {
      if (language == null) {
        throw FormatException(
          'Language tag must be provided for rdf:langString',
          lexicalForm,
        );
      }
      if (direction != null) {
        throw FormatException(
          'Direction must not be provided for rdf:langString',
          lexicalForm,
        );
      }
    } else if (iri ==
        'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString') {
      if (language == null) {
        throw FormatException(
          'Language tag must be provided for rdf:dirLangString',
          lexicalForm,
        );
      }
      if (direction == null) {
        throw FormatException(
          'Direction must be provided for rdf:dirLangString',
          lexicalForm,
        );
      }
    } else {
      // For all other datatypes, language and direction must be null
      if (language != null) {
        throw FormatException(
          'Language tag must not be provided for datatype $iri',
          lexicalForm,
        );
      }
      if (direction != null) {
        throw FormatException(
          'Direction must not be provided for datatype $iri',
          lexicalForm,
        );
      }
    }

    Object? parsedValue;
    // Attempt to map value using XSD package
    // Note: We need a registry of codecs or similar from the xsd package.
    // Assuming xsd package provides individual codecs but purely for known types.
    // For now, we will do a manual mapping based on the IRI string for built-ins.
    // Ideally, we'd have a `XsdCodec.forType(iri)` but that might not exist yet.
    // Let's implement a basic lookup here or in a helper.
    // For the "Proof of Concept to Production" shift, we'll start with manual mapping
    // or assume we refine this part later. For now, let's implement the structure.

    // Simple pass-through for now to satisfy the constructor API,
    // real mapping logic can be added in `_mapValue`.
    parsedValue = _mapValue(lexicalForm, datatype);

    return Literal._(lexicalForm, datatype, language, direction, parsedValue);
  }

  const Literal._(
    this.lexicalForm,
    this.datatype,
    this.language,
    this.direction,
    this.value,
  );

  static Object? _mapValue(String lexicalForm, NamedNode datatype) {
    // Basic mapping for common XSD types using package:xsd codecs
    // Note: In a full implementation, we might have a registry.
    // Here we manually map the most common ones.
    final iri = datatype.iri.toString();

    try {
      if (iri == 'http://www.w3.org/2001/XMLSchema#string') {
        return xsd.XsdStringCodec().decode(lexicalForm);
      } else if (iri == 'http://www.w3.org/2001/XMLSchema#boolean') {
        return xsd.XsdBooleanCodec().decode(lexicalForm);
      } else if (iri == 'http://www.w3.org/2001/XMLSchema#integer') {
        return xsd.XsdIntegerCodec().decode(lexicalForm);
      } else if (iri == 'http://www.w3.org/2001/XMLSchema#decimal') {
        return xsd.XsdDecimalCodec().decode(lexicalForm);
      } else if (iri == 'http://www.w3.org/2001/XMLSchema#double') {
        return xsd.XsdDoubleCodec().decode(lexicalForm);
      } else if (iri == 'http://www.w3.org/2001/XMLSchema#dateTime') {
        return xsd.XsdDateTimeCodec().decode(lexicalForm);
      }
      // TODO: Add more types (date, time, duration, etc.)
    } catch (e) {
      // Ill-typed literal
      return null;
    }

    // Default: return the lexical form if unknown datatype (or langString)
    return lexicalForm;
  }

  @override
  String toString() {
    if (direction != null && language != null) {
      // N-Triples doesn't standardly support direction yet, but for debug/roundtrip:
      return '"$lexicalForm"@$language--${direction == intl.TextDirection.LTR ? 'ltr' : 'rtl'}';
    } else if (language != null) {
      return '"$lexicalForm"@$language';
    } else {
      return '"$lexicalForm"^^$datatype';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Literal) return false;

    // 1. Lexical form (case-sensitive)
    if (lexicalForm != other.lexicalForm) return false;

    // 2. Datatype (IRI equality)
    if (datatype != other.datatype) return false;

    // 3. Language tag (case-insensitive)
    // "The two language tags are ... both present and compare equal"
    if (language != null) {
      if (other.language == null) return false;
      // Case-insensitive comparison
      if (language!.toLowerCase() != other.language!.toLowerCase()) {
        return false;
      }
    } else {
      if (other.language != null) return false;
    }

    // 4. Base direction
    if (direction != other.direction) return false;

    return true;
  }

  @override
  int get hashCode =>
      Object.hash(lexicalForm, datatype, language?.toLowerCase(), direction);
}
