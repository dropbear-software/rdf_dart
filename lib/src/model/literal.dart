import 'dart:convert' as convert;
import 'package:intl/intl.dart' as intl;
import 'package:intl/locale.dart';
import 'package:xsd/xsd.dart' as xsd;

import 'iri.dart';
import 'term.dart';

/// An RDF Literal.
///
/// Literals are used for values such as strings, numbers, and dates.
/// A literal consists of:
/// 1. A [lexicalForm] (the string representation).
/// 2. A [datatypeIri] identifying the datatype.
/// 3. An optional [languageTag] (for `rdf:langString`).
/// 4. An optional [baseDirection] (for `rdf:dirLangString`).
class Literal implements ObjectTerm {
  /// The lexical form of the literal.
  final String lexicalForm;

  /// The datatype IRI of the literal.
  final Iri datatypeIri;

  /// The language tag, if any.
  ///
  /// This must be non-null if and only if [datatypeIri] is `rdf:langString`
  /// or `rdf:dirLangString`.
  final String? languageTag;

  /// The base direction, if any.
  ///
  /// This must be non-null if and only if [datatypeIri] is `rdf:dirLangString`.
  final intl.TextDirection? baseDirection;

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
  /// [datatypeIri] is the datatype IRI. Defaults to `xsd:string` if not provided,
  /// unless [languageTag] is present (defaults to `rdf:langString`) or
  /// [baseDirection] is present (defaults to `rdf:dirLangString`).
  factory Literal(
    String lexicalForm, {
    Iri? datatypeIri,
    String? languageTag,
    intl.TextDirection? baseDirection,
  }) {
    // Determine datatype if not provided
    if (datatypeIri == null) {
      if (baseDirection != null) {
        datatypeIri = Iri(
          'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString',
        );
      } else if (languageTag != null) {
        datatypeIri = Iri(
          'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString',
        );
      } else {
        datatypeIri = Iri('http://www.w3.org/2001/XMLSchema#string');
      }
    }

    // Validate datatype vs language/direction constraints based on RDF 1.2
    // If and only if datatype is langString, language must be non-null and direction must be null.
    // If and only if datatype is dirLangString, language must be non-null and direction must be non-null.
    // Otherwise, language and direction must be null.

    final iri = datatypeIri.value.toString();
    if (iri == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#langString') {
      if (languageTag == null) {
        throw FormatException(
          'Language tag must be provided for rdf:langString',
          lexicalForm,
        );
      }
      if (baseDirection != null) {
        throw FormatException(
          'Direction must not be provided for rdf:langString',
          lexicalForm,
        );
      }
    } else if (iri ==
        'http://www.w3.org/1999/02/22-rdf-syntax-ns#dirLangString') {
      if (languageTag == null) {
        throw FormatException(
          'Language tag must be provided for rdf:dirLangString',
          lexicalForm,
        );
      }
      if (baseDirection == null) {
        throw FormatException(
          'Direction must be provided for rdf:dirLangString',
          lexicalForm,
        );
      }
    } else {
      // For all other datatypes, language and direction must be null
      if (languageTag != null) {
        throw FormatException(
          'Language tag must not be provided for datatype $iri',
          lexicalForm,
        );
      }
      if (baseDirection != null) {
        throw FormatException(
          'Direction must not be provided for datatype $iri',
          lexicalForm,
        );
      }
    }

    // Validate language tag if present
    if (languageTag != null && Locale.tryParse(languageTag) == null) {
      throw FormatException('Invalid language tag: $languageTag', languageTag);
    }

    Object? parsedValue;
    // Attempt to map value using XSD package
    parsedValue = _mapValue(lexicalForm, datatypeIri);

    return Literal._(
      lexicalForm,
      datatypeIri,
      languageTag,
      baseDirection,
      parsedValue,
    );
  }

  const Literal._(
    this.lexicalForm,
    this.datatypeIri,
    this.languageTag,
    this.baseDirection,
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

  static Object? _mapValue(String lexicalForm, Iri datatypeIri) {
    // Basic mapping for common XSD types using package:xsd codecs
    final iri = datatypeIri.value.toString();
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
    if (baseDirection != null && languageTag != null) {
      // N-Triples doesn't standardly support direction yet, but for debug/roundtrip:
      return '"$lexicalForm"@$languageTag--${baseDirection == intl.TextDirection.LTR ? 'ltr' : 'rtl'}';
    } else if (languageTag != null) {
      return '"$lexicalForm"@$languageTag';
    } else {
      return '"$lexicalForm"^^$datatypeIri';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Literal) return false;

    // 1. Lexical form (case-sensitive)
    if (lexicalForm != other.lexicalForm) return false;

    // 2. Datatype (IRI equality)
    if (datatypeIri != other.datatypeIri) return false;

    // 3. Language tag (case-insensitive)
    // "The two language tags are ... both present and compare equal"
    if (languageTag != null) {
      if (other.languageTag == null) return false;
      // Case-insensitive comparison
      if (languageTag!.toLowerCase() != other.languageTag!.toLowerCase()) {
        return false;
      }
    } else {
      if (other.languageTag != null) return false;
    }

    // 4. Base direction
    if (baseDirection != other.baseDirection) return false;

    return true;
  }

  @override
  int get hashCode => Object.hash(
    lexicalForm,
    datatypeIri,
    languageTag?.toLowerCase(),
    baseDirection,
  );

  @override
  /// Always returns true for Literals.
  bool get isGround => true;
}
