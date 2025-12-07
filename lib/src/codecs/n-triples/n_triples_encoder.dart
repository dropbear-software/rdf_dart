import 'dart:convert';
import 'package:intl/intl.dart';

import '../../model/blank_node.dart';
import '../../model/iri.dart';
import '../../model/literal.dart';
import '../../model/term.dart';
import '../../model/triple.dart';
import '../../model/triple_term.dart';

/// A [Converter] that encodes [Iterable] of [Triple]s to N-Triples strings.
///
/// This encoder produces Canonical N-Triples by default.
class NTriplesEncoder extends Converter<Iterable<Triple>, String> {
  const NTriplesEncoder();

  @override
  String convert(Iterable<Triple> input) {
    final sb = StringBuffer();
    for (final triple in input) {
      if (triple.predicate is! Iri) {
        throw FormatException('Predicate must be an IRI in N-Triples', triple);
      }
      _writeTripleComponents(
        triple.subject,
        triple.predicate as Iri,
        triple.object,
        sb,
      );
      sb.write(' .\n');
    }
    return sb.toString();
  }

  void _writeTripleComponents(
    SubjectTerm s,
    Iri p,
    ObjectTerm o,
    StringBuffer sb,
  ) {
    _writeSubject(s, sb);
    sb.write(' ');
    _writePredicate(p, sb);
    sb.write(' ');
    _writeObject(o, sb);
  }

  void _writeSubject(SubjectTerm subject, StringBuffer sb) {
    if (subject is Iri) {
      _writeIri(subject, sb);
    } else if (subject is BlankNode) {
      _writeBlankNode(subject, sb);
    } else {
      throw ArgumentError('Invalid subject type: ${subject.runtimeType}');
    }
  }

  void _writePredicate(Iri predicate, StringBuffer sb) {
    _writeIri(predicate, sb);
  }

  void _writeObject(ObjectTerm object, StringBuffer sb) {
    if (object is Iri) {
      _writeIri(object, sb);
    } else if (object is BlankNode) {
      _writeBlankNode(object, sb);
    } else if (object is Literal) {
      _writeLiteral(object, sb);
    } else if (object is TripleTerm) {
      _writeTripleTerm(object, sb);
    } else {
      throw ArgumentError('Invalid object type: ${object.runtimeType}');
    }
  }

  void _writeTripleTerm(TripleTerm term, StringBuffer sb) {
    if (term.triple.predicate is! Iri) {
      throw FormatException('Predicate in TripleTerm must be an IRI', term);
    }

    sb.write('<<(');
    sb.write(' ');
    _writeTripleComponents(
      term.triple.subject,
      term.triple.predicate as Iri,
      term.triple.object,
      sb,
    );
    sb.write(' )>>');
  }

  void _writeIri(Iri iri, StringBuffer sb) {
    sb.write('<');
    sb.write(_escapeIri(iri.toString()));
    sb.write('>');
  }

  void _writeBlankNode(BlankNode bnode, StringBuffer sb) {
    if (!bnode.id.startsWith('_:')) {
      sb.write('_:');
    }
    sb.write(bnode.id);
  }

  void _writeLiteral(Literal literal, StringBuffer sb) {
    sb.write('"');
    sb.write(_escapeString(literal.lexicalForm));
    sb.write('"');
    if (literal.languageTag != null) {
      if (literal.languageTag!.isNotEmpty) {
        sb.write('@');
        sb.write(literal.languageTag!.toLowerCase()); // Canonical: lowercase
        if (literal.baseDirection != null) {
          sb.write('--');
          sb.write(literal.baseDirection == TextDirection.LTR ? 'ltr' : 'rtl');
        }
      }
    } else if (literal.datatypeIri.toString() !=
        'http://www.w3.org/2001/XMLSchema#string') {
      sb.write('^^');
      _writeIri(literal.datatypeIri, sb);
    }
  }

  String _escapeIri(String s) {
    final sb = StringBuffer();
    for (final code in s.runes) {
      // Check prohibited chars for IRI: 0x00-0x20, <, >, ", {, }, |, ^, `, \
      // Note: s.runes gives integer codepoints.
      // Prohibited set check needs to be careful with integer comparison.
      if (code <= 0x20 ||
          code == 60 || // <
          code == 62 || // >
          code == 34 || // "
          code == 123 || // {
          code == 125 || // }
          code == 124 || // |
          code == 94 || // ^
          code == 96 || // `
          code == 92 || // \
          !_isXml11Char(code)) {
        _writeUchar(code, sb);
      } else {
        sb.writeCharCode(code);
      }
    }
    return sb.toString();
  }

  String _escapeString(String s) {
    final sb = StringBuffer();
    for (final code in s.runes) {
      switch (code) {
        case 0x08:
          sb.write(r'\b');
          break;
        case 0x09:
          sb.write(r'\t');
          break;
        case 0x0A:
          sb.write(r'\n');
          break;
        case 0x0C:
          sb.write(r'\f');
          break;
        case 0x0D:
          sb.write(r'\r');
          break;
        case 0x22:
          sb.write(r'\"');
          break;
        case 0x5C:
          sb.write(r'\\');
          break;
        default:
          if (code >= 0x00 && code <= 0x07 ||
              code == 0x0B ||
              (code >= 0x0E && code <= 0x1F) ||
              code == 0x7F ||
              !_isXml11Char(code)) {
            _writeUchar(code, sb);
          } else {
            sb.writeCharCode(code);
          }
      }
    }
    return sb.toString();
  }

  bool _isXml11Char(int code) {
    // XML 1.1 Char production:
    // [#x1-#xD7FF] | [#xE000-#xFFFD] | [#x10000-#x10FFFF]
    return (code >= 0x1 && code <= 0xD7FF) ||
        (code >= 0xE000 && code <= 0xFFFD) ||
        (code >= 0x10000 && code <= 0x10FFFF);
  }

  void _writeUchar(int code, StringBuffer sb) {
    if (code <= 0xFFFF) {
      sb.write(r'\u');
      sb.write(code.toRadixString(16).toUpperCase().padLeft(4, '0'));
    } else {
      sb.write(r'\U');
      sb.write(code.toRadixString(16).toUpperCase().padLeft(8, '0'));
    }
  }
}
