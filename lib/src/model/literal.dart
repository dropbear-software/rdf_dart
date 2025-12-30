import 'dart:convert' as convert;
import 'package:intl/intl.dart' as intl;
import 'package:intl/locale.dart';
import 'package:xsd/xsd.dart' as xsd;

import 'iri.dart';
import 'term.dart';
import '../vocabulary/vocabulary.dart';

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
        datatypeIri = Rdf.dirLangString;
      } else if (languageTag != null) {
        datatypeIri = Rdf.langString;
      } else {
        datatypeIri = Xsd.string;
      }
    }

    // Validate datatype vs language/direction constraints based on RDF 1.2
    // If and only if datatype is langString, language must be non-null and direction must be null.
    // If and only if datatype is dirLangString, language must be non-null and direction must be non-null.
    // Otherwise, language and direction must be null.

    if (datatypeIri == Rdf.langString) {
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
    } else if (datatypeIri == Rdf.dirLangString) {
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
          'Language tag must not be provided for datatype $datatypeIri',
          lexicalForm,
        );
      }
      if (baseDirection != null) {
        throw FormatException(
          'Direction must not be provided for datatype $datatypeIri',
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
  static final Map<Iri, convert.Codec> _xsdCodecs = {
    Xsd.string: xsd.XsdStringCodec(),
    Xsd.boolean: xsd.XsdBooleanCodec(),
    Xsd.decimal: xsd.XsdDecimalCodec(),
    Xsd.integer: xsd.XsdIntegerCodec(),
    Xsd.double: xsd.XsdDoubleCodec(),
    Xsd.float: xsd.XsdFloatCodec(),
    Xsd.date: xsd.XsdDateCodec(),
    Xsd.dateTime: xsd.XsdDateTimeCodec(),
    Xsd.gYear: xsd.GregorianYearCodec(),
    Xsd.gYearMonth: xsd.YearMonthCodec(),
    Xsd.gMonth: xsd.GregorianMonthCodec(),
    Xsd.gMonthDay: xsd.GregorianMonthDayCodec(),
    Xsd.gDay: xsd.XsdGDayCodec(),
    Xsd.duration: xsd.XsdDurationCodec(),
    Xsd.byte: xsd.XsdByteCodec(),
    Xsd.short: xsd.XsdShortCodec(),
    Xsd.int: xsd.XsdIntCodec(),
    Xsd.long: xsd.XsdLongCodec(),
    Xsd.unsignedByte: xsd.XsdUnsignedByteCodec(),
    Xsd.unsignedShort: xsd.XsdUnsignedShortCodec(),
    Xsd.unsignedInt: xsd.XsdUnsignedIntCodec(),
    Xsd.unsignedLong: xsd.XsdUnsignedLongCodec(),
    Xsd.positiveInteger: xsd.XmlPositiveIntegerCodec(),
    Xsd.nonNegativeInteger: xsd.XsdNonNegativeIntegerCodec(),
    Xsd.negativeInteger: xsd.XsdNegativeIntegerCodec(),
    Xsd.nonPositiveInteger: xsd.XsdNonPositiveIntegerCodec(),
    Xsd.hexBinary: xsd.XsdHexbinaryCodec(),
    Xsd.base64Binary: xsd.XsdBase64BinaryCodec(),
    Xsd.anyURI: xsd.XsdAnyUriCodec(),
    Xsd.language: xsd.XsdLanguageCodec(),
    Xsd.normalizedString: xsd.XsdNormalizedStringCodec(),
    Xsd.token: xsd.XsdTokenCodec(),
    Xsd.nmToken: xsd.XsdNmtokenCodec(),
    Xsd.name: xsd.XsdNameCodec(),
    Xsd.ncName: xsd.XsdNcnameCodec(),
  };

  static Object? _mapValue(String lexicalForm, Iri datatypeIri) {
    // Basic mapping for common XSD types using package:xsd codecs
    final codec = _xsdCodecs[datatypeIri];

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
      return '"$lexicalForm"^^<$datatypeIri>';
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

  /// Returns the canonical form of this literal.
  ///
  /// If the literal has a supported datatype, this returns a new [Literal]
  /// with the canonical lexical form of the value.
  /// Otherwise, it returns `this`.
  Literal get canonical {
    if (value == null) return this;

    final codec = _xsdCodecs[datatypeIri];

    if (codec != null) {
      try {
        // Re-encode to get canonical form
        final canonicalLexical = codec.encode(value);
        if (canonicalLexical != lexicalForm) {
          return Literal(
            canonicalLexical,
            datatypeIri: datatypeIri,
            // Language/Direction should be null if codec exists, usually.
            // Except maybe langString? But langString doesn't have a codec in the map above.
          );
        }
      } catch (_) {
        // Ignore encoding errors, return as is
      }
    }
    return this;
  }
}
