import 'dart:convert';
import 'package:intl/intl.dart';

import '../../model/blank_node.dart';
import '../../model/iri.dart';
import '../../model/literal.dart';
import '../../model/term.dart';
import '../../model/triple.dart';
import '../../model/triple_term.dart';

/// A [Converter] that encodes [Iterable] of [Triple]s to Turtle strings.
class TurtleEncoder extends Converter<Iterable<Triple>, String> {
  /// Map of prefix labels to namespace IRIs.
  final Map<String, String> prefixes;

  /// Base IRI to use for relative IRI resolution.
  final String? baseUri;

  const TurtleEncoder({
    this.prefixes = const {},
    this.baseUri,
  });

  @override
  String convert(Iterable<Triple> input) {
    final sb = StringBuffer();
    final writer = _TurtleWriter(
      sb,
      prefixes: prefixes,
      baseUri: baseUri,
    );
    writer.writeGraph(input);
    return sb.toString();
  }
}

class _TurtleWriter {
  final StringSink _sink;
  final Map<String, String> prefixes;
  final String? baseUri;

  int _indent = 0;

  _TurtleWriter(
    this._sink,
    {
      this.prefixes = const {},
      this.baseUri,
    }
  );

  void writeGraph(Iterable<Triple> triples) {
    // 1. Write Directives
    if (baseUri != null) {
      _sink.write('BASE <$baseUri>\n');
    }
    final prefixList = prefixes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in prefixList) {
      _sink.write('PREFIX ${entry.key}: <${entry.value}>\n');
    }
    if (baseUri != null || prefixes.isNotEmpty) {
      _sink.write('\n');
    }

    // 2. Group by Subject
    final subjects = <SubjectTerm, Map<PredicateTerm, List<ObjectTerm>>>{};
    for (final t in triples) {
      subjects
          .putIfAbsent(t.subject, () => {})
          .putIfAbsent(t.predicate, () => [])
          .add(t.object);
    }

    // 3. Write each subject block
    final subjectList = subjects.keys.toList();
    // Deterministic sorting: BNodes after IRIs
    subjectList.sort((a, b) {
      if (a is Iri && b is! Iri) return -1;
      if (a is! Iri && b is Iri) return 1;
      return a.toString().compareTo(b.toString());
    });

    for (var i = 0; i < subjectList.length; i++) {
      final s = subjectList[i];
      final predicates = subjects[s]!;

      _writeSubject(s);
      _sink.write('\n');
      _indent++;

      final predicateList = predicates.keys.toList();
      // Deterministic sorting
      predicateList.sort((a, b) {
        final as = a.toString();
        final bs = b.toString();
        // rdf:type first
        if (as == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type') return -1;
        if (bs == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type') return 1;
        return as.compareTo(bs);
      });

      for (var j = 0; j < predicateList.length; j++) {
        final p = predicateList[j];
        final objects = predicates[p]!;

        _writeIndent();
        _writePredicate(p);
        _sink.write(' ');

        for (var k = 0; k < objects.length; k++) {
          _writeObject(objects[k]);
          if (k < objects.length - 1) {
            _sink.write(' ,\n');
            _writeIndent();
            _sink.write('    '); // Additional indent for object list items
          }
        }

        if (j < predicateList.length - 1) {
          _sink.write(' ;\n');
        } else {
          _sink.write(' .\n');
        }
      }
      _indent--;
      if (i < subjectList.length - 1) {
        _sink.write('\n');
      }
    }
  }

  void _writeSubject(SubjectTerm s) {
    if (s is Iri) {
      _writeIri(s);
    } else if (s is BlankNode) {
      _writeBlankNode(s);
    }
  }

  void _writePredicate(PredicateTerm p) {
    if (p is Iri) {
      if (p.toString() == 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type') {
        _sink.write('a');
      } else {
        _writeIri(p);
      }
    }
  }

  void _writeObject(ObjectTerm o) {
    if (o is Iri) {
      _writeIri(o);
    } else if (o is BlankNode) {
      _writeBlankNode(o);
    } else if (o is Literal) {
      _writeLiteral(o);
    } else if (o is TripleTerm) {
      _sink.write('<< ( ');
      _writeTriple(o.triple);
      _sink.write(' ) >>');
    }
  }

  void _writeTriple(Triple t) {
    _writeSubject(t.subject);
    _sink.write(' ');
    _writePredicate(t.predicate);
    _sink.write(' ');
    _writeObject(t.object);
  }

  void _writeIri(Iri iri) {
    _sink.write(_relativizeIri(iri));
  }

  String _relativizeIri(Iri iri) {
    final iriStr = iri.toString();

    // 1. Try Prefix replacement
    for (final entry in prefixes.entries) {
      final namespace = entry.value;
      if (iriStr.startsWith(namespace)) {
        final localName = iriStr.substring(namespace.length);
        if (_isValidLocalName(localName)) {
          return '${entry.key}:$localName';
        }
      }
    }

    // 2. Try Base URI stripping
    if (baseUri != null && iriStr.startsWith(baseUri!)) {
      final rel = iriStr.substring(baseUri!.length);
      // Ensure it doesn't contain > or other invalid chars for relative IRI
      if (!rel.contains('>')) {
        return '<$rel>';
      }
    }

    return '<$iriStr>';
  }

  bool _isValidLocalName(String localName) {
    if (localName.isEmpty) return true;
    // PN_LOCAL ::= ( PN_CHARS_U | ':' | [0-9] | PLX ) ( ( PN_CHARS | '.' | ':' | PLX )*  ( PN_CHARS | ':' | PLX ) ) ?
    // Simplified check: alphanumeric, underscore, hyphen. No dots at end.
    // We don't support PLX (escaping) in localName generation yet for simplicity.
    final regex = RegExp(r'^[a-zA-Z0-9_]([a-zA-Z0-9_\-\:]*[a-zA-Z0-9_\:])?$');
    return regex.hasMatch(localName);
  }

  void _writeBlankNode(BlankNode b) {
    _sink.write(b.toString());
  }

  void _writeLiteral(Literal l) {
    _sink.write('"');
    _sink.write(_escapeString(l.lexicalForm));
    _sink.write('"');
    if (l.languageTag != null) {
      _sink.write('@${l.languageTag}');
      if (l.baseDirection != null) {
        _sink.write('--${l.baseDirection == TextDirection.LTR ? 'ltr' : 'rtl'}');
      }
    } else if (l.datatypeIri.toString() != 'http://www.w3.org/2001/XMLSchema#string') {
      _sink.write('^^');
      _writeIri(l.datatypeIri);
    }
  }

  void _writeIndent() {
    _sink.write('    ' * _indent);
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
              code == 0x7F) {
            _writeUchar(code, sb);
          } else {
            sb.writeCharCode(code);
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