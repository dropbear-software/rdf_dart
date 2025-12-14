import 'dart:convert';
import 'package:intl/intl.dart';

import '../../model/blank_node.dart';
import '../../model/iri.dart';
import '../../model/literal.dart';
import '../../model/term.dart';
import '../../model/triple.dart';
import '../../model/triple_term.dart';

/// A [Converter] that decodes N-Triples strings to [Iterable] of [Triple]s.
///
/// Implements the W3C N-Triples 1.2 specification.
class NTriplesDecoder extends Converter<String, Iterable<Triple>> {
  const NTriplesDecoder();

  @override
  /// [1] ntriplesDoc ::= statement? (EOL statement)* EOL?
  Iterable<Triple> convert(String input) sync* {
    // 1. Split by EOL (CR or LF)
    final lines = input.split(RegExp(r'[\r\n]+'));

    // bnodeLabels: Map[string -> blank node]
    final bnodeLabels = <String, BlankNode>{};

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final scanner = _NTriplesScanner(line, bnodeLabels);
      final triple = scanner.scan();
      if (triple != null) {
        yield triple;
      }
    }
  }
}

class _NTriplesScanner {
  final String line;
  final Map<String, BlankNode> bnodeLabels;
  int _index = 0;

  _NTriplesScanner(this.line, this.bnodeLabels);

  /// [2] statement ::= directive | triple
  /// [6] triple ::= subject predicate object '.'
  Triple? scan() {
    _skipWhitespace();
    if (_isAtEnd()) return null;
    if (line[_index] == '#') return null; // Comment line

    // Check for VERSION directive
    if (line.startsWith('VERSION', _index)) {
      _advance('VERSION'.length);
      _skipWhitespace();
      // Expect version specifier (STRING_LITERAL_QUOTE)
      _parseStringLiteral();
      // We process it but essentially ignore it for now as per spec
      return null;
    }

    final s = _parseSubject();
    _skipWhitespace();
    final p = _parsePredicate();
    _skipWhitespace();
    final o = _parseObject();
    _skipWhitespace();

    if (_index >= line.length || line[_index] != '.') {
      throw FormatException('Expected "." at end of triple', line, _index);
    }
    _advance(1); // consume '.'

    // Check for trailing comment or whitespace
    _skipWhitespace();
    if (!_isAtEnd() && line[_index] == '#') {
      // remainder is comment
      return Triple(subject: s, predicate: p, object: o);
    } else if (!_isAtEnd()) {
      throw FormatException('Unexpected content after triple', line, _index);
    }

    return Triple(subject: s, predicate: p, object: o);
  }

  /// [7] subject ::= IRIREF | BLANK_NODE_LABEL
  SubjectTerm _parseSubject() {
    if (_peek() == '<') {
      return _parseIri();
    } else if (_peek() == '_') {
      return _parseBlankNode();
    } else {
      throw FormatException(
        'Expected subject (IRI or BlankNode)',
        line,
        _index,
      );
    }
  }

  /// [8] predicate ::= IRIREF
  Iri _parsePredicate() {
    if (_peek() == '<') {
      return _parseIri();
    } else {
      throw FormatException('Expected predicate (IRI)', line, _index);
    }
  }

  /// [9] object ::= IRIREF | BLANK_NODE_LABEL | literal | tripleTerm
  ObjectTerm _parseObject() {
    final char = _peek();
    if (char == '<') {
      // could be IRI or TripleTerm '<<('
      if (_startsWith('<<(')) {
        return _parseTripleTerm();
      }
      return _parseIri();
    } else if (char == '_') {
      return _parseBlankNode();
    } else if (char == '"') {
      return _parseLiteral();
    } else {
      throw FormatException('Expected object', line, _index);
    }
  }

  /// [11] tripleTerm ::= '<<(' subject predicate object ')>>'
  TripleTerm _parseTripleTerm() {
    // Expected '<<('
    _advance(3);
    _skipWhitespace();
    final s = _parseSubject();
    _skipWhitespace();
    final p = _parsePredicate();
    _skipWhitespace();
    final o = _parseObject();
    _skipWhitespace();

    if (!_startsWith(')>>')) {
      throw FormatException('Expected ")>>" to close TripleTerm', line, _index);
    }
    _advance(3);

    return TripleTerm(Triple(subject: s, predicate: p, object: o));
  }

  /// [15] IRIREF
  Iri _parseIri() {
    // IRIREF ::= '<' ([^#x00-#x20<>"{}|^`\] | UCHAR)* '>'
    _advance(1); // <
    final sb = StringBuffer();
    while (!_isAtEnd()) {
      final char = line[_index];
      if (char == '>') {
        _advance(1);
        final iriValue = sb.toString();
        // Validate absolute IRI
        if (!iriValue.contains(':')) {
          throw FormatException(
            'IRI must be absolute: $iriValue',
            line,
            _index,
          );
        }
        // Further validation via Iri class if needed
        return Iri(iriValue);
      } else if (char == '\\') {
        _advance(1);
        if (_peek() == 'u' || _peek() == 'U') {
          sb.write(_parseUnicodeEscape());
        } else {
          throw FormatException('Invalid escape in IRI', line, _index - 1);
        }
      } else {
        // Start checking strictly prohibited chars
        final code = char.codeUnitAt(0);
        if (code <= 0x20 || '<>"{}\\^`|'.contains(char)) {
          throw FormatException(
            'Illegal character in IRI: $char',
            line,
            _index,
          );
        }
        sb.write(char);
        _advance(1);
      }
    }
    throw FormatException('Unterminated IRI', line, _index);
  }

  /// [16] BLANK_NODE_LABEL ::= '_:' ( PN_CHARS_U | [0-9] ) ((PN_CHARS|'.')* PN_CHARS)?
  BlankNode _parseBlankNode() {
    // BLANK_NODE_LABEL ::= '_:' ( PN_CHARS_U | [0-9] ) ((PN_CHARS|'.')* PN_CHARS)?
    if (!_startsWith('_:')) throw FormatException('Expected _:', line, _index);
    _advance(2);

    final start = _index;
    if (_isAtEnd()) {
      throw FormatException('Empty blank node label', line, _index);
    }

    final first = line[_index];
    if (!_isPnCharsU(first) && !RegExp(r'[0-9]').hasMatch(first)) {
      throw FormatException('Invalid start of blank node label', line, _index);
    }
    _advance(1);

    while (!_isAtEnd()) {
      final char = line[_index];
      if (_isPnChars(char) || char == '.') {
        _advance(1);
      } else {
        break;
      }
    }

    if (line[_index - 1] == '.') {
      throw FormatException('Blank node label cannot end with .', line, _index);
    }

    final label = line.substring(start, _index);

    return bnodeLabels.putIfAbsent(label, () => BlankNode(label));
  }

  /// [10] literal ::= STRING_LITERAL_QUOTE ('^^' IRIREF | LANG_DIR )?
  Literal _parseLiteral() {
    final value = _parseStringLiteral();

    // Allow whitespace between string and suffix (lang/type)
    _skipWhitespace();

    // Check for lang tag or datatype
    if (_peek() == '@') {
      _advance(1);
      final start = _index;
      if (_isAtEnd()) throw FormatException('Empty language tag', line, _index);

      while (!_isAtEnd()) {
        final char = line[_index];
        if (RegExp(r'[a-zA-Z0-9-]').hasMatch(char)) {
          _advance(1);
        } else {
          break;
        }
      }
      final rawTag = line.substring(start, _index);

      // Check for direction separator '--'
      final dirIndex = rawTag.indexOf('--');
      if (dirIndex != -1) {
        final lang = rawTag.substring(0, dirIndex);
        final dirStr = rawTag.substring(dirIndex + 2);

        // RDF 1.2 N-Triples: direction must be "ltr" or "rtl".
        // The negative test 'upper case LTR' implies strict lowercase requirement.

        if (dirStr == 'ltr') {
          return Literal(
            value,
            languageTag: lang,
            baseDirection: TextDirection.LTR,
          );
        } else if (dirStr == 'rtl') {
          return Literal(
            value,
            languageTag: lang,
            baseDirection: TextDirection.RTL,
          );
        } else {
          throw FormatException('Invalid direction: $dirStr', line, _index);
        }
      }

      return Literal(value, languageTag: rawTag);
    } else if (_startsWith('^^')) {
      _advance(2);
      // Allow whitespace between ^^ and IRI
      _skipWhitespace();
      final datatype = _parseIri();
      return Literal(value, datatypeIri: datatype);
    }

    return Literal(value);
  }

  /// [18] STRING_LITERAL_QUOTE ::= '"' ( [^#x22#x5C#xA#xD] | ECHAR | UCHAR )* '"'
  String _parseStringLiteral() {
    if (_peek() != '"') {
      throw FormatException('Expected string start "', line, _index);
    }
    _advance(1);

    final sb = StringBuffer();
    while (!_isAtEnd()) {
      final char = line[_index];
      if (char == '"') {
        _advance(1);
        return sb.toString();
      } else if (char == '\\') {
        _advance(1);
        final esc = line[_index];
        if (esc == 'u' || esc == 'U') {
          sb.write(_parseUnicodeEscape());
        } else {
          _advance(1);
          switch (esc) {
            case 't':
              sb.write('\t');
              break;
            case 'b':
              sb.write('\b');
              break;
            case 'n':
              sb.write('\n');
              break;
            case 'r':
              sb.write('\r');
              break;
            case 'f':
              sb.write('\f');
              break;
            case '"':
              sb.write('"');
              break;
            case '\'':
              sb.write('\'');
              break;
            case '\\':
              sb.write('\\');
              break;
            default:
              throw FormatException(
                'Invalid escape sequence \\$esc',
                line,
                _index,
              );
          }
        }
      } else {
        if (char == '\n' || char == '\r') {
          throw FormatException(
            'Unescaped newline in string literal',
            line,
            _index,
          );
        }
        sb.write(char);
        _advance(1);
      }
    }
    throw FormatException('Unterminated string literal', line, _index);
  }

  String _parseUnicodeEscape() {
    // expecting uXXXX or UXXXXXXXX
    final isLong = line[_index] == 'U';
    _advance(1); // consume u/U

    final length = isLong ? 8 : 4;
    if (_index + length > line.length) {
      throw FormatException('Incomplete unicode escape', line, _index);
    }

    final hexStr = line.substring(_index, _index + length);
    _advance(length);

    try {
      final code = int.parse(hexStr, radix: 16);
      return String.fromCharCode(code);
    } catch (e) {
      throw FormatException('Invalid unicode escape sequence', line, _index);
    }
  }

  void _skipWhitespace() {
    while (!_isAtEnd()) {
      final char = line[_index];
      if (char == ' ' || char == '\t') {
        _index++;
      } else {
        break;
      }
    }
  }

  void _advance(int count) {
    _index += count;
  }

  bool _isAtEnd() => _index >= line.length;

  String _peek() => _isAtEnd() ? '' : line[_index];

  bool _startsWith(String prefix) => line.startsWith(prefix, _index);

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
