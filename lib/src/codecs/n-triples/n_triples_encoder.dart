import 'dart:convert';

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
      }
    } else    if (literal.datatypeIri.toString() !=
        'http://www.w3.org/2001/XMLSchema#string') {
      sb.write('^^');
      _writeIri(literal.datatypeIri, sb);
    }
  
  }

  String _escapeIri(String s) {
    final sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final char = s[i];
      final code = char.codeUnitAt(0);
      if (code <= 0x20 || '<>"{}\\^`|'.contains(char)) {
        // Perform UCHAR escape
        _writeUchar(code, sb);
      } else {
        sb.write(char);
      }
    }
    return sb.toString();
  }

  String _escapeString(String s) {
    final sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final char = s[i];
      final code = char.codeUnitAt(0);

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
              code == 0x7F) {
            _writeUchar(code, sb);
          } else {
            sb.write(char);
          }
      }
    }
    return sb.toString();
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
