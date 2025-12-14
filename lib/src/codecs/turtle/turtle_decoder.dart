import 'dart:convert';

import 'package:intl/intl.dart' as intl;

import '../../model/blank_node.dart';
import '../../model/iri.dart';
import '../../model/literal.dart';
import '../../model/term.dart';
import '../../model/triple.dart';
import '../../model/triple_term.dart';

/// A [Converter] that decodes Turtle strings to [Iterable] of [Triple]s.
class TurtleDecoder extends Converter<String, Iterable<Triple>> {
  final String? baseUri;

  const TurtleDecoder({this.baseUri});

  @override
  Iterable<Triple> convert(String input) sync* {
    final parser = _TurtleParser(input, baseUri: baseUri);
    yield* parser.parse();
  }
}

class _TurtleParser {
  final String _input;
  int _pos = 0;

  // State
  final Map<String, String> _namespaces = {};
  Iri? _base;
  final Map<String, BlankNode> _bnodeLabels = {};

  // Buffers for emitting triples
  final List<Triple> _triples = [];

  _TurtleParser(this._input, {String? baseUri}) {
    if (baseUri != null) {
      _base = Iri(baseUri);
    }
  }

  Iterable<Triple> parse() sync* {
    while (!_isAtEnd()) {
      _skipWhitespaceAndComments();
      if (_isAtEnd()) break;

      if (_startsWith('@prefix') || _startsWith('PREFIX')) {
        _parsePrefixID();
      } else if (_startsWith('@base') || _startsWith('BASE')) {
        _parseBase();
      } else if (_startsWith('@version') || _startsWith('VERSION')) {
        _parseVersion();
      } else {
        yield* _parseTriples();
      }
    }
  }

  void _parsePrefixID() {
    if (_consumeIf('@prefix')) {
      _skipWhitespaceAndComments();
      final prefix = _parsePNameNS();
      _skipWhitespaceAndComments();
      final iriPart = _parseIRIREF();
      _skipWhitespaceAndComments();
      _expect('.');
      _namespaces[prefix.substring(0, prefix.length - 1)] = iriPart.toString();
    } else {
      _expect('PREFIX');
      _skipWhitespaceAndComments();
      final prefix = _parsePNameNS();
      _skipWhitespaceAndComments();
      final iriPart = _parseIRIREF();
      // No dot for SPARQL style
      _namespaces[prefix.substring(0, prefix.length - 1)] = iriPart.toString();
    }
  }

  void _parseBase() {
    if (_consumeIf('@base')) {
      _skipWhitespaceAndComments();
      _base = _parseIRIREF();
      _skipWhitespaceAndComments();
      _expect('.');
    } else {
      _expect('BASE');
      _skipWhitespaceAndComments();
      _base = _parseIRIREF();
    }
  }

  void _parseVersion() {
    // We largely ignore version directives but must consume them
    if (_consumeIf('@version')) {
      _skipWhitespaceAndComments();
      _parseVersionSpecifier();
      _skipWhitespaceAndComments();
      _expect('.');
    } else {
      _expect('VERSION');
      _skipWhitespaceAndComments();
      _parseVersionSpecifier();
    }
  }

  void _parseVersionSpecifier() {
    // VersionSpecifier ::= STRING_LITERAL_QUOTE | STRING_LITERAL_SINGLE_QUOTE
    if (_startsWith('"""') || _startsWith("'''")) {
      throw FormatException(
        'Triple-quoted strings are not allowed in @version directive',
      );
    }
    if (_startsWith('"')) {
      _parseString(); // checks for "\""
    } else if (_startsWith("'")) {
      _parseString(); // checks for "'"
    } else {
      throw FormatException('Expected version string');
    }
  }

  Iterable<Triple> _parseTriples() sync* {
    final subject = _parseSubject();
    _skipWhitespaceAndComments();

    if (_peek() != '.') {
      _parsePredicateObjectList(subject);
    }

    _skipWhitespaceAndComments();
    _expect('.');

    // Yield all buffered triples
    yield* _triples;
    _triples.clear();
  }

  void _parsePredicateObjectList(RdfTerm subject) {
    var predicate = _parseVerb();
    _skipWhitespaceAndComments();
    _parseObjectList(subject, predicate);

    _skipWhitespaceAndComments();
    while (_consumeIf(';')) {
      _skipWhitespaceAndComments();
      final char = _peek();
      // Optional trailing semicolon or next verb
      // If we see ';' or '.', we have an empty verb-object list.
      // ']' is also possible end of BlankNodePropertyList
      if (char == ';' || char == '.' || char == ']') {
        continue;
      }

      // Parse next verb-object list
      predicate = _parseVerb();
      _skipWhitespaceAndComments();
      _parseObjectList(subject, predicate);
      _skipWhitespaceAndComments();
    }
  }

  void _parseObjectList(RdfTerm subject, RdfTerm predicate) {
    while (true) {
      final object = _parseObject();

      final t = Triple(
        subject: _toSubject(subject),
        predicate: _toPredicate(predicate),
        object: _toObject(object),
      );
      _triples.add(t);

      _skipWhitespaceAndComments();
      // Parsing annotations
      RdfTerm? activeReifier;

      while (true) {
        if (_startsWith('{|')) {
          _advance(2);
          _skipWhitespaceAndComments();

          // Use active reifier if available, otherwise create new
          final reifier = activeReifier ?? BlankNode(_newBNodeLabel());
          // Consume active reifier (subsequent blocks need new ones unless explicit)
          activeReifier = null;

          _triples.add(
            Triple(
              subject: _toSubject(reifier),
              predicate: Iri(
                'http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies',
              ),
              object: TripleTerm(t),
            ),
          );

          _parsePredicateObjectList(reifier);
          _skipWhitespaceAndComments();
          _expect('|}');
        } else if (_startsWith('~')) {
          _advance(1);
          _skipWhitespaceAndComments();
          RdfTerm reifier;
          final p = _peek();
          if (p == '<') {
            reifier = _parseIRIREF();
          } else if (p == '_') {
            reifier = _parseBlankNode();
          } else if (p == '[') {
            reifier = _parseAnon();
          } else if (p == ':' || _isPnCharsBase(p)) {
            reifier = _parsePrefixedName();
          } else {
            reifier = BlankNode(_newBNodeLabel());
          }

          _triples.add(
            Triple(
              subject: _toSubject(reifier),
              predicate: Iri(
                'http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies',
              ),
              object: TripleTerm(t),
            ),
          );

          // Set as active reifier for following blocks
          activeReifier = reifier;
        } else {
          break;
        }
        _skipWhitespaceAndComments();
      }

      _skipWhitespaceAndComments();
      if (_consumeIf(',')) {
        _skipWhitespaceAndComments();
        continue;
      } else {
        break;
      }
    }
  }

  // Term parsing methods

  RdfTerm _parseSubject() {
    return _parseTerm(inSubjectPosition: true);
  }

  bool _isKeywordA() {
    if (!_startsWith('a')) return false;
    // Look ahead to see if 'a' is followed by a separator or a name char.
    // If it is followed by a name char (which could lead to a colon), it is likely a prefix.
    var i = _pos + 1;
    while (i < _input.length) {
      final c = _input[i];
      if (_isWS(c) || '<>[]{}(),"\'#;'.contains(c)) {
        // Separator found, no colon seen -> 'a' is keyword
        return true;
      }
      if (c == ':') {
        // Colon found -> 'a' is start of prefix 'a:'
        return false;
      }
      // Continue scanning name/dot chars
      i++;
    }
    // EOF reached, treated as keyword 'a'
    return true;
  }

  RdfTerm _parseTerm({bool inSubjectPosition = false}) {
    final char = _peek();
    if (char == '<') {
      if (_startsWith('<<(')) {
        return _parseTripleTerm();
      } else if (_startsWith('<<')) {
        return _parseReifiedTriple();
      } else {
        return _parseIRIREF();
      }
    } else if (char == '_') {
      return _parseBlankNode();
    } else if (char == '[') {
      return _parseBlankNodePropertyListOrAnon();
    } else if (char == '(') {
      return _parseCollection();
    } else if (char == '"' || char == "'") {
      return _parseLiteral();
    } else {
      // Potentially numeric or boolean or PrefixedName
      if (RegExp(r'[0-9\+\-\.]').hasMatch(char)) {
        // Could be numeric, OR starts with dot (which is invalid unless numeric 0.1)
        // If it starts with dot and is NOT numeric, it falls through?
        // _parseNumericLiteral throws if invalid.
        // We probably want to catch it if it's just a dot (terminator) and rethrow/let caller handle?
        // But parseTerm IS expected to return a Term. A dot is not a Term.
        try {
          return _parseNumericLiteral();
        } catch (_) {
          if (char == '.')
            rethrow; // Dot is definitely not a term, let explicit error happen or bubble up
          // If + or - and not numeric, could it be something else?
          // No, PrefixedName cannot start with + or -.
          rethrow;
        }
      }
      if (char == 't' || char == 'f') {
        if (_startsWith('true') || _startsWith('false')) {
          // Check if it's the boolean keyword (not prefix starting with true/false)
          final val = _startsWith('true') ? 'true' : 'false';
          final nextIdx = _pos + val.length;
          if (nextIdx >= _input.length || !_isPnChars(_input[nextIdx])) {
            return _parseBooleanLiteral();
          }
        }
      }
      return _parsePrefixedName();
    }
  }

  // Returns IRI from either IRIREF or PrefixedName
  Iri _parseIri() {
    if (_peek() == '<') {
      return _parseIRIREF();
    }
    return _parsePrefixedName();
  }

  Iri _parseIRIREF() {
    _expect('<');
    final sb = StringBuffer();
    while (!_isAtEnd()) {
      final char = _input[_pos];
      if (char == '>') {
        _pos++;
        var iriStr = sb.toString();
        if (_base != null) {
          try {
            var resolvedUri = Uri.parse(_base!.toString()).resolve(iriStr);
            // Workaround for Dart Uri bug where trailing dot segment may not be removed
            // before query or fragment (e.g. /path/.?q=v)
            if (resolvedUri.path.endsWith('/.')) {
              resolvedUri = resolvedUri.replace(
                path: resolvedUri.path.substring(
                  0,
                  resolvedUri.path.length - 1,
                ),
              );
            }
            iriStr = resolvedUri.toString();
          } catch (_) {}
        }
        return Iri(iriStr);
      } else if (char == '\\') {
        _pos++;
        if (_isAtEnd()) {
          throw FormatException('Unexpected end of input in IRIREF');
        }
        final escapeChar = _input[_pos];
        String encoded;
        if (escapeChar == 'u') {
          _pos++;
          encoded = _parseHex(4);
        } else if (escapeChar == 'U') {
          _pos++;
          encoded = _parseHex(8);
        } else {
          throw FormatException(
            'Invalid escape sequence in IRIREF: \\$escapeChar',
          );
        }
        // Check if the decoded character is valid in IRIREF?
        // Grammar says: ( [^#x00-#x20<>"{}|^`\] | UCHAR )*
        // This implies UCHAR *can* produce characters in the excluded set?
        // Usually, UCHAR escapes are used to represent characters that are otherwise not allowed directly.
        // However, standard RDF practice typically disallows control chars even if escaped?
        // Actually, the grammar is: ( [^...] | UCHAR )*.
        // This suggests if you use UCHAR, it's valid.
        // BUT, "The characters produced by the UCHAR escape sequence ... must be considered as having been written directly".
        // No, that's not what EBNF means. EBNF means either a char NOT in excluded set, OR a UCHAR sequence.
        // So `\u0020` IS valid because it matches `UCHAR`.
        // The exclusion list applies to RAW characters.
        // Let's re-read the test failure for `bad-01`.
        // `bad-01` has `\u0020` (space).
        // If the test EXPECTS failure, then space is NOT allowed even via UCHAR.
        // Let's check spec text if possible?
        // RDF 1.1 Turtle says: "Hex-encoded characters are expanded... The resulting string ... is resolved..."
        // IRI RFC says spaces are NOT allowed.
        // So even if grammar allows parsing `\u0020` into the STRING, the resulting IRI is invalid.
        // So validation should happen on the *result* or *during* parsing if we want Strict IRI validation.
        // The failure in `bad-01` (FormatException expected) implies we should Reject it.
        // So I will validate decoded chars too.
        // Checking disallowed set: 0x00-0x20, <, >, ", {, }, |, ^, `, \
        final invalidChars = RegExp(r'[\x00-\x20<>"{}|^`\\]');
        if (invalidChars.hasMatch(encoded)) {
          throw FormatException('Invalid character in IRIREF: $encoded');
        }
        sb.write(encoded);
      } else {
        // Raw character validation
        // disallowed: 0-20, <, >, ", {, }, |, ^, `, \
        // < is end check, \ is escape check.
        // So check others.
        if (char.codeUnitAt(0) <= 0x20 || '<>"{}|^`\\'.contains(char)) {
          throw FormatException('Invalid character in IRIREF: $char');
        }
        sb.write(char);
        _pos++;
      }
    }
    throw FormatException('Unterminated IRIREF');
  }

  String _parsePNameNS() {
    // Basic PNAME_NS parsing
    final start = _pos;
    while (!_isAtEnd()) {
      final c = _input[_pos];
      if (c == ':') {
        _pos++;
        return _input.substring(start, _pos);
      }
      if (_isWS(c)) break;
      _pos++;
    }
    throw FormatException('Invalid PNAME_NS');
  }

  Iri _parsePrefixedName() {
    final start = _pos;
    // Scan for colon to identify PNAME_NS
    final nsEnd = _input.indexOf(':', _pos);
    if (nsEnd == -1) {
      // No colon, so not a prefixed name.
      throw FormatException('Invalid PrefixedName');
    }

    // Verify prefix part (PNAME_NS without colon)
    // PN_PREFIX ::= PN_CHARS_BASE ((PN_CHARS|'.')* PN_CHARS)?
    final prefix = _input.substring(start, nsEnd);
    // Simple verification/lookup (the map lookup implicitly validates)
    // Actually we should validate char set?

    final namespace = _namespaces[prefix];
    if (namespace == null) {
      throw FormatException('Undefined prefix: $prefix');
    }

    _pos = nsEnd + 1; // Skip colon

    // PN_LOCAL parsing
    // ((PN_CHARS | '.' | ':' | PLX) ... )*
    // Must not end in '.'

    final sb = StringBuffer();
    // We scan greedily, then backtrack dots

    final localStart = _pos;
    while (!_isAtEnd()) {
      final char = _input[_pos];

      // Check for PLX (percent or escape)
      if (char == '%') {
        sb.write(char);
        _pos++;
        sb.write(_input[_pos]);
        _pos++; // HEX
        sb.write(_input[_pos]);
        _pos++; // HEX
        continue;
      }
      if (char == '\\') {
        // PN_LOCAL_ESC
        _pos++;
        sb.write(_parsePNLocalEsc());
        continue;
      }

      // Check standard chars
      // PN_CHARS | '.' | ':'
      if (_isWS(char) || '<>[]{}(),"\'#;'.contains(char)) {
        // Separators
        break;
      }
      // Note: '/' and other symbols are valid in PN_CHARS ?
      // PN_CHARS includes '-', 0-9, B7, etc.
      // And PN_CHARS_U includes underscores.
      // And PN_CHARS allows '.'

      // The exclusion list above is robust for standard delimiters.
      // If we encounter a char that IS a delimiter, stop.

      sb.write(char);
      _pos++;
    }

    // BACKTRACKING DOTS
    var localName = sb.toString();
    while (localName.endsWith('.')) {
      localName = localName.substring(0, localName.length - 1);
      _pos--;
    }

    return Iri('$namespace$localName');
  }

  BlankNode _parseBlankNode() {
    if (_consumeIf('_:')) {
      final sb = StringBuffer();
      // BLANK_NODE_LABEL ::= '_:' ( PN_CHARS_U | [0-9] ) ((PN_CHARS|'.')* PN_CHARS)?

      // We assume first char check handled by parser flow or just greedy scan

      while (!_isAtEnd()) {
        final char = _input[_pos];
        if (_isWS(char) || '<>[]{}(),"\'#;'.contains(char)) break;
        // Note: dot '.' is NOT a separator here, it is allowed
        sb.write(char);
        _pos++;
      }

      var label = sb.toString();
      // Backtrack dots
      while (label.endsWith('.')) {
        label = label.substring(0, label.length - 1);
        _pos--;
      }

      if (label.isEmpty) throw FormatException('Empty BlankNode label');

      return _bnodeLabels.putIfAbsent(label, () => BlankNode(label));
    } else {
      throw FormatException('Expected BlankNode');
    }
  }

  RdfTerm _parseBlankNodePropertyListOrAnon() {
    _expect('[');
    _skipWhitespaceAndComments();
    if (_consumeIf(']')) {
      return BlankNode(_newBNodeLabel()); // ANON
    }

    final bnode = BlankNode(_newBNodeLabel());
    _parsePredicateObjectList(bnode);

    _skipWhitespaceAndComments();
    _expect(']');
    return bnode;
  }

  RdfTerm _parseCollection() {
    _expect('(');
    _skipWhitespaceAndComments();
    final items = <RdfTerm>[];
    while (!_isAtEnd() && _peek() != ')') {
      items.add(_parseObject());
      _skipWhitespaceAndComments();
    }
    _expect(')');

    RdfTerm current = Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#nil');
    for (var i = items.length - 1; i >= 0; i--) {
      final bnode = BlankNode(_newBNodeLabel());
      _triples.add(
        Triple(
          subject: bnode,
          predicate: Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#first'),
          object: _toObject(items[i]),
        ),
      );
      _triples.add(
        Triple(
          subject: bnode,
          predicate: Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#rest'),
          object: _toObject(current),
        ),
      );
      current = bnode;
    }
    return current;
  }

  TripleTerm _parseTripleTerm() {
    _expect('<<(');
    _skipWhitespaceAndComments();
    final s = _parseTtSubject();
    _skipWhitespaceAndComments();
    final p = _parseVerb();
    _skipWhitespaceAndComments();
    final o = _parseTtObject();
    _skipWhitespaceAndComments();
    _expect(')>>');
    return TripleTerm(
      Triple(
        subject: _toSubject(s),
        predicate: _toPredicate(p),
        object: _toObject(o),
      ),
    );
  }

  RdfTerm _parseReifiedTriple() {
    _expect('<<');
    _skipWhitespaceAndComments();
    final s = _parseRtSubject();
    _skipWhitespaceAndComments();
    final p = _parseVerb();
    _skipWhitespaceAndComments();
    final o = _parseRtObject();
    _skipWhitespaceAndComments();

    RdfTerm? reifier;
    if (_peek() != '>') {
      if (_startsWith('~')) {
        _advance(1);
        _skipWhitespaceAndComments();
        final p = _peek();
        if (p == '<') {
          reifier = _parseIRIREF();
        } else if (p == '[') {
          reifier = _parseAnon();
        } else if (p == '_') {
          reifier = _parseBlankNode();
        } else if (p == ':' || _isPnCharsBase(p)) {
          reifier = _parsePrefixedName();
        } else {
          reifier = BlankNode(_newBNodeLabel());
        }
      }
    }
    _skipWhitespaceAndComments();
    _expect('>>');

    final tt = TripleTerm(
      Triple(
        subject: _toSubject(s),
        predicate: _toPredicate(p),
        object: _toObject(o),
      ),
    );
    final r = reifier ?? BlankNode(_newBNodeLabel());

    _triples.add(
      Triple(
        subject: _toSubject(r),
        predicate: Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies'),
        object: tt,
      ),
    );

    return r;
  }

  RdfTerm _parseAnon() {
    _expect('[');
    _skipWhitespaceAndComments();
    _expect(']');
    return BlankNode(_newBNodeLabel());
  }

  // ttSubject ::= iri | BlankNode
  RdfTerm _parseTtSubject() {
    final char = _peek();
    if (char == '<') return _parseIRIREF();
    if (char == '_') return _parseBlankNode();
    if (char == '[') return _parseAnon(); // BlankNode includes ANON
    // PrefixedName
    if (RegExp(r'[a-zA-Z0-9\-\.\:]').hasMatch(char)) {
      // PNAME_NS or PNAME_LN. starts with PN_CHARS_BASE.
      // Check if it's not a keyword?
      return _parsePrefixedName();
    }
    throw FormatException('Invalid TripleTerm subject');
  }

  // ttObject ::= iri | BlankNode | literal | tripleTerm
  RdfTerm _parseTtObject() {
    final char = _peek();
    if (char == '<') {
      if (_startsWith('<<(')) return _parseTripleTerm();
      // tripleTerm vs IRI
      return _parseIRIREF();
    }
    if (char == '_') return _parseBlankNode();
    if (char == '[') return _parseAnon();
    if (char == '"' || char == "'") return _parseLiteral();
    if (RegExp(r'[0-9\+\-\.]').hasMatch(char)) return _parseNumericLiteral();
    if (char == 't' || char == 'f') {
      if (_startsWith('true') || _startsWith('false')) {
        return _parseBooleanLiteral();
      }
    }
    return _parsePrefixedName();
  }

  // rtSubject ::= iri | BlankNode | reifiedTriple
  RdfTerm _parseRtSubject() {
    final char = _peek();
    if (char == '<') {
      if (_startsWith('<<')) {
        if (_startsWith('<<(')) {
          throw FormatException('TripleTerm not allowed as rtSubject');
        }
        return _parseReifiedTriple();
      }
      return _parseIRIREF();
    }
    if (char == '_') return _parseBlankNode();
    if (char == '[') return _parseAnon();
    // PNAME
    if (RegExp(r'[a-zA-Z0-9\-\.\:]').hasMatch(char)) {
      return _parsePrefixedName();
    }
    throw FormatException('Invalid ReifiedTriple subject');
  }

  // rtObject ::= iri | BlankNode | literal | tripleTerm | reifiedTriple
  RdfTerm _parseRtObject() {
    final char = _peek();
    if (char == '<') {
      if (_startsWith('<<(')) return _parseTripleTerm();
      if (_startsWith('<<')) return _parseReifiedTriple();
      return _parseIRIREF();
    }
    if (char == '_') return _parseBlankNode();
    if (char == '[') return _parseAnon();
    if (char == '"' || char == "'") return _parseLiteral();
    if (RegExp(r'[0-9\+\-\.]').hasMatch(char)) return _parseNumericLiteral();
    if (char == 't' || char == 'f') {
      if (_startsWith('true') || _startsWith('false')) {
        return _parseBooleanLiteral();
      }
    }
    return _parsePrefixedName();
  }

  Literal _parseLiteral() {
    if (_peek() == '"' || _peek() == "'") {
      return _parseRDFLiteral();
    } else {
      throw FormatException('Expected Literal');
    }
  }

  Literal _parseRDFLiteral() {
    final val = _parseString();
    _skipWhitespaceAndComments();

    if (_startsWith('^^')) {
      _advance(2);
      _skipWhitespaceAndComments();
      final dt = _parseIri();
      return Literal(val, datatypeIri: dt);
    } else if (_startsWith('@')) {
      _advance(1);
      final start = _pos;
      while (_pos < _input.length) {
        final c = _input[_pos];
        if (RegExp(r'[a-zA-Z0-9\-]').hasMatch(c)) {
          _pos++;
        } else {
          break;
        }
      }
      final tag = _input.substring(start, _pos);
      final dirIdx = tag.indexOf('--');
      if (dirIdx != -1) {
        final lang = tag.substring(0, dirIdx);
        final dir = tag.substring(dirIdx + 2);
        if (dir != 'ltr' && dir != 'rtl') {
          throw FormatException('Invalid literal direction: $dir');
        }
        final direction = dir == 'ltr'
            ? intl.TextDirection.LTR
            : intl.TextDirection.RTL;
        return Literal(val, languageTag: lang, baseDirection: direction);
      }
      return Literal(val, languageTag: tag);
    }
    return Literal(val);
  }

  String _parseString() {
    if (_startsWith('"""')) {
      _advance(3);
      return _readStringUntil('"""');
    } else if (_startsWith("'''")) {
      _advance(3);
      return _readStringUntil("'''");
    } else if (_startsWith('"')) {
      _advance(1);
      return _readStringUntil('"');
    } else if (_startsWith("'")) {
      _advance(1);
      return _readStringUntil("'");
    }
    throw FormatException('Expected String property at $_pos');
  }

  String _readStringUntil(String delimiter) {
    final sb = StringBuffer();
    while (!_isAtEnd()) {
      if (_startsWith(delimiter)) {
        _advance(delimiter.length);
        return sb.toString();
      }

      final char = _input[_pos];
      if (char == '\\') {
        _advance(1);
        if (_isAtEnd()) throw FormatException('Unterminated string escape');
        sb.write(_parseEscape());
      } else {
        sb.write(char);
        _advance(1);
      }
    }
    throw FormatException('Unterminated string at $_pos');
  }

  RdfTerm _parseNumericLiteral() {
    final start = _pos;
    if (_peek() == '+' || _peek() == '-') {
      _advance(1);
    }
    bool hasDigits = false;
    while (_isDigit(_peek())) {
      _advance(1);
      hasDigits = true;
    }
    bool isDecimal = false;
    if (_peek() == '.') {
      if (_isDigit(_peek(1))) {
        isDecimal = true;
        _advance(1);
        while (_isDigit(_peek())) {
          _advance(1);
        }
      }
    }
    bool isDouble = false;
    if (_peek().toLowerCase() == 'e') {
      isDouble = true;
      _advance(1);
      if (_peek() == '+' || _peek() == '-') _advance(1);
      while (_isDigit(_peek())) {
        _advance(1);
      }
    }
    final lexical = _input.substring(start, _pos);
    if (isDouble) {
      return Literal(
        lexical,
        datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#double'),
      );
    } else if (isDecimal) {
      return Literal(
        lexical,
        datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#decimal'),
      );
    } else {
      if (!hasDigits && lexical.length <= 1) {
        throw FormatException('Invalid numeric literal');
      }
      return Literal(
        lexical,
        datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#integer'),
      );
    }
  }

  RdfTerm _parseBooleanLiteral() {
    if (_consumeIf('true')) {
      return Literal(
        'true',
        datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#boolean'),
      );
    }
    if (_consumeIf('false')) {
      return Literal(
        'false',
        datatypeIri: Iri('http://www.w3.org/2001/XMLSchema#boolean'),
      );
    }
    throw FormatException('Expected boolean');
  }

  bool _isDigit(String char) =>
      char.isNotEmpty && char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;

  String _parseEscape() {
    if (_isAtEnd()) {
      throw FormatException('Unexpected end of input in escape sequence');
    }
    final c = _input[_pos];
    _advance(1);
    switch (c) {
      case 't':
        return '\t';
      case 'b':
        return '\b';
      case 'n':
        return '\n';
      case 'r':
        return '\r';
      case 'f':
        return '\f';
      case '"':
        return '"';
      case "'":
        return "'";
      case '\\':
        return '\\';
      case 'u':
        return _parseHex(4);
      case 'U':
        return _parseHex(8);
      default:
        throw FormatException('Invalid escape sequence \\$c');
    }
  }

  String _parseHex(int length) {
    if (_pos + length > _input.length) {
      throw FormatException('Unexpected end of input in hex escape');
    }
    final hexStr = _input.substring(_pos, _pos + length);
    _advance(length);
    try {
      final code = int.parse(hexStr, radix: 16);
      return String.fromCharCode(code);
    } catch (e) {
      throw FormatException('Invalid hex sequence $hexStr');
    }
  }

  String _parsePNLocalEsc() {
    final c = _input[_pos++];
    return c;
  }

  // Helpers
  void _expect(String token) {
    if (!_startsWith(token)) throw FormatException('Expected $token at $_pos');
    _advance(token.length);
  }

  bool _consumeIf(String token) {
    if (_startsWith(token)) {
      _advance(token.length);
      return true;
    }
    return false;
  }

  bool _startsWith(String token) => _input.startsWith(token, _pos);
  String _peek([int offset = 0]) =>
      (_pos + offset < _input.length) ? _input[_pos + offset] : '';
  void _advance(int n) => _pos += n;
  bool _isAtEnd() => _pos >= _input.length;
  bool _isWS(String char) => ' \t\r\n'.contains(char);

  void _skipWhitespaceAndComments() {
    while (!_isAtEnd()) {
      final char = _input[_pos];
      if (_isWS(char)) {
        _pos++;
      } else if (char == '#') {
        while (!_isAtEnd() && _input[_pos] != '\n' && _input[_pos] != '\r') {
          _pos++;
        }
      } else {
        break;
      }
    }
  }

  // Type coercions
  RdfTerm _parseObject() => _parseTerm();

  SubjectTerm _toSubject(RdfTerm t) {
    if (t is SubjectTerm) return t;
    throw FormatException('Invalid subject type: ${t.runtimeType}');
  }

  Iri _toPredicate(RdfTerm t) {
    if (t is Iri) return t;
    throw FormatException('Invalid predicate type: ${t.runtimeType}');
  }

  ObjectTerm _toObject(RdfTerm t) {
    if (t is ObjectTerm) return t;
    throw FormatException('Invalid object type: ${t.runtimeType}');
  }

  RdfTerm _parseVerb() {
    if (_isKeywordA()) {
      _advance(1);
      return Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#type');
    }
    return _parseTerm();
  }

  int _bnodeCounter = 0;
  String _newBNodeLabel() => 'b${_bnodeCounter++}';

  bool _isPnCharsU(String char) {
    return _isPnCharsBase(char) || char == '_';
  }

  bool _isPnCharsBase(String char) {
    return RegExp(
      r'[A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD\u{10000}-\u{EFFFF}]',
      unicode: true,
    ).hasMatch(char);
  }

  bool _isPnChars(String char) {
    if (_isPnCharsU(char)) return true;
    if (char == '-' || RegExp(r'[0-9]').hasMatch(char)) return true;
    if (char == '\u00B7') return true;
    return RegExp(r'[\u0300-\u036F\u203F-\u2040]').hasMatch(char);
  }
}
