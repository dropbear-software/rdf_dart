import 'term.dart';
import 'dart:math';

/// An RDF Blank Node (a node without a global identifier).
///
/// Blank nodes can appear in the Subject or Object position of a triple.
class BlankNode implements SubjectTerm, ObjectTerm, GraphName {
  /// The local identifier for this blank node.
  ///
  /// This identifier acts as a "Blank Node Identifier" (or Label) in concrete syntaxes
  /// like N-Triples. It is locally scoped to the graph or dataset it belongs to.
  ///
  /// This implementation enforces strict N-Triples `BLANK_NODE_LABEL` grammar
  /// compatibility for the identifier to ensure safe serialization.
  final String id;

  /// Creates a [BlankNode] with the given [id].
  ///
  /// If [value] is provided, it is validated against the N-Triples
  /// `BLANK_NODE_LABEL` grammar. Throws [ArgumentError] if valid.
  ///
  /// If [value] is not provided (or null), a random valid identifier is generated.
  BlankNode([String? value])
    : id = value != null
          ? _BlankNodeIdentifier.check(value)
          : _BlankNodeIdentifier.random();

  @override
  String toString() => '_:$id';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlankNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  /// Always returns false for BlankNodes.
  bool get isGround => false;
}

/// A validation helper for Blank Node Identifiers based on N-Triples grammar.
///
/// This does not store the state (which `BlankNode` does), but validates
/// string identifiers against the `BLANK_NODE_LABEL` production rule from
/// the N-Triples specification.
///
/// See: https://www.w3.org/TR/n-triples/#grammar-production-BLANK_NODE_LABEL
class _BlankNodeIdentifier {
  // ignore: avoid_classes_with_only_static_members
  /// The maximum length allowed for a blank node identifier.
  ///
  /// While the N-Triples grammar does not impose a length limit, we enforce
  /// a generous limit to prevent denial-of-service (DoS) attacks via
  /// memory exhaustion with excessively long identifiers.
  static const int maxLength = 1024;

  /// Validates [value] against the N-Triples `BLANK_NODE_LABEL` grammar.
  ///
  /// The [value] should *not* include the `_:` prefix.
  ///
  /// Throws [ArgumentError] if the identifier is invalid.
  static void validate(String value) {
    if (value.isEmpty) {
      throw FormatException('Blank Node identifier cannot be empty.');
    }
    if (value.length > maxLength) {
      throw FormatException(
        'Blank Node identifier exceeds maximum length of $maxLength characters.',
      );
    }
    if (!_blankNodeLabelRegex.hasMatch(value)) {
      throw FormatException(
        'Invalid Blank Node identifier format. Must match N-Triples BLANK_NODE_LABEL grammar.',
      );
    }
  }

  /// Validates [value] and returns it if valid.
  ///
  /// Useful for initializer lists.
  static String check(String value) {
    validate(value);
    return value;
  }

  /// Generates a random valid blank node identifier.
  static String random() {
    final random = Random.secure();
    final length = 32;
    final buffer = StringBuffer();
    // Start with a safe char (letter)
    buffer.writeCharCode((65 + random.nextInt(26)));
    for (var i = 1; i < length; i++) {
      // Alphanumeric mixed
      if (random.nextBool()) {
        buffer.writeCharCode((65 + random.nextInt(26)));
      } else {
        buffer.writeCharCode((48 + random.nextInt(10)));
      }
    }
    return buffer.toString();
  }

  // --- Grammar Definitions ---

  // PN_CHARS_BASE
  static const _pnCharsBase =
      r'A-Z'
      r'a-z'
      r'\u00C0-\u00D6'
      r'\u00D8-\u00F6'
      r'\u00F8-\u02FF'
      r'\u0370-\u037D'
      r'\u037F-\u1FFF'
      r'\u200C-\u200D'
      r'\u2070-\u218F'
      r'\u2C00-\u2FEF'
      r'\u3001-\uD7FF'
      r'\uF900-\uFDCF'
      r'\uFDF0-\uFFFD'
      r'\u{10000}-\u{EFFFF}';

  // PN_CHARS_U ::= PN_CHARS_BASE | '_'
  static const _pnCharsU = '${_pnCharsBase}_';

  // PN_CHARS ::= PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
  static const _pnChars =
      '$_pnCharsU'
      r'\-'
      r'0-9'
      r'\u00B7'
      r'\u0300-\u036F'
      r'\u203F-\u2040';

  // BLANK_NODE_LABEL ::= '_:' ( PN_CHARS_U | [0-9] ) ((PN_CHARS|'.')* PN_CHARS)?
  // We match the part AFTER '_:'.
  // Start: ( PN_CHARS_U | [0-9] )
  // Rest: ((PN_CHARS|'.')* PN_CHARS)?
  static final RegExp _blankNodeLabelRegex = RegExp(
    '^'
    '[${_pnCharsU}0-9]' // First char
    r'('
    r'(?:'
    r'['
    '$_pnChars'
    r']' // PN_CHARS
    r'|'
    r'\.' // '.'
    r')*'
    r'['
    '$_pnChars'
    r']' // Must end with PN_CHARS
    r')?'
    r'$',
    unicode: true,
  );
}
