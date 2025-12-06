import 'dart:convert' as convert;
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

  // TODO: https://github.com/dropbear-software/xsd/issues/78
  static final Map<String, convert.Codec> _xsdCodecs = {
    'http://www.w3.org/2001/XMLSchema#string': xsd.XsdStringCodec(),
    'http://www.w3.org/2001/XMLSchema#boolean': xsd.XsdBooleanCodec(),
    'http://www.w3.org/2001/XMLSchema#decimal': xsd.XsdDecimalCodec(),
    'http://www.w3.org/2001/XMLSchema#integer': xsd.XsdIntegerCodec(),
    'http://www.w3.org/2001/XMLSchema#double': xsd.XsdDoubleCodec(),
    'http://www.w3.org/2001/XMLSchema#float': xsd.XsdFloatCodec(),
    'http://www.w3.org/2001/XMLSchema#date': xsd.XsdDateCodec(),
    'http://www.w3.org/2001/XMLSchema#dateTime': xsd.XsdDateTimeCodec(),
    'http://www.w3.org/2001/XMLSchema#gYear': xsd.GregorianYearCodec(),
    'http://www.w3.org/2001/XMLSchema#gYearMonth': xsd.YearMonthCodec(),
    'http://www.w3.org/2001/XMLSchema#gMonth': xsd.GregorianMonthCodec(),
    'http://www.w3.org/2001/XMLSchema#gMonthDay': xsd.GregorianMonthDayCodec(),
    'http://www.w3.org/2001/XMLSchema#gDay': xsd.XsdGDayCodec(),
    'http://www.w3.org/2001/XMLSchema#duration': xsd.XsdDurationCodec(),
    'http://www.w3.org/2001/XMLSchema#byte': xsd.XsdByteCodec(),
    'http://www.w3.org/2001/XMLSchema#short': xsd.XsdShortCodec(),
    'http://www.w3.org/2001/XMLSchema#int': xsd.XsdIntCodec(),
    'http://www.w3.org/2001/XMLSchema#long': xsd.XsdLongCodec(),
    'http://www.w3.org/2001/XMLSchema#unsigedByte': xsd.XsdUnsignedByteCodec(),
    'http://www.w3.org/2001/XMLSchema#unsigedShort':
        xsd.XsdUnsignedShortCodec(),
    'http://www.w3.org/2001/XMLSchema#unsigedInt': xsd.XsdUnsignedIntCodec(),
    'http://www.w3.org/2001/XMLSchema#unsigedLong': xsd.XsdUnsignedLongCodec(),
    'http://www.w3.org/2001/XMLSchema#positiveInteger':
        xsd.XmlPositiveIntegerCodec(),
    'http://www.w3.org/2001/XMLSchema#nonNegativeInteger':
        xsd.XsdNonNegativeIntegerCodec(),
    'http://www.w3.org/2001/XMLSchema#negativeInteger':
        xsd.XsdNegativeIntegerCodec(),
    'http://www.w3.org/2001/XMLSchema#nonPositiveInteger':
        xsd.XsdNonPositiveIntegerCodec(),
    'http://www.w3.org/2001/XMLSchema#hexBinary': xsd.XsdHexbinaryCodec(),
    'http://www.w3.org/2001/XMLSchema#base64Binary': xsd.XsdBase64BinaryCodec(),
    'http://www.w3.org/2001/XMLSchema#anyURI': xsd.XsdAnyUriCodec(),
    'http://www.w3.org/2001/XMLSchema#language': xsd.XsdLanguageCodec(),
    'http://www.w3.org/2001/XMLSchema#normalizedString':
        xsd.XsdNormalizedStringCodec(),
    'http://www.w3.org/2001/XMLSchema#token': xsd.XsdTokenCodec(),
    'http://www.w3.org/2001/XMLSchema#NMTOKEN': xsd.XsdNmtokenCodec(),
    'http://www.w3.org/2001/XMLSchema#Name': xsd.XsdNameCodec(),
    'http://www.w3.org/2001/XMLSchema#NCName': xsd.XsdNcnameCodec(),
  };

  static Object? _mapValue(String lexicalForm, NamedNode datatype) {
    // Basic mapping for common XSD types using package:xsd codecs
    final iri = datatype.iri.toString();
    final codec = _xsdCodecs[iri];

    if (codec != null) {
      try {
        return codec.decode(lexicalForm);
      } catch (_) {
        // Ill-typed literal
        return null;
      }
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
