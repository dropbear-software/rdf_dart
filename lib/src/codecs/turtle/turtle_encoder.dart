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

  const TurtleEncoder({this.prefixes = const {}, this.baseUri});

  @override
  String convert(Iterable<Triple> input) {
    final sb = StringBuffer();
    final writer = _TurtleWriter(sb, prefixes: prefixes, baseUri: baseUri);
    writer.writeGraph(input);
    return sb.toString();
  }
}

class _TurtleGraphAnalyzer {
  final Map<BlankNode, int> refCounts = {};
  final Map<SubjectTerm, List<Triple>> subjectToTriples = {};

  // List detection
  final Map<BlankNode, List<ObjectTerm>> listMembers = {};
  final Set<BlankNode> nodesInLists = {};

  // Annotation detection
  final Map<Triple, Set<SubjectTerm>> tripleToReifiers = {};
  final Set<SubjectTerm> annotationReifiers = {};

  static final _rdfFirst = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#first',
  );
  static final _rdfRest = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#rest',
  );
  static final _rdfNil = Iri('http://www.w3.org/1999/02/22-rdf-syntax-ns#nil');
  static final _rdfType = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
  );
  static final _rdfList = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#List',
  );
  static final _rdfReifies = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies',
  );

  void analyze(Iterable<Triple> triples) {
    for (final t in triples) {
      final s = t.subject;
      subjectToTriples.putIfAbsent(s, () => []).add(t);
      _incrementRef(t.object);

      if (t.predicate == _rdfReifies && t.object is TripleTerm) {
        final reifiedTriple = (t.object as TripleTerm).triple;
        tripleToReifiers.putIfAbsent(reifiedTriple, () => {}).add(t.subject);
      }
    }

    // Detect lists
    for (final s in subjectToTriples.keys) {
      if (s is BlankNode && !nodesInLists.contains(s)) {
        final ts = subjectToTriples[s]!;
        if (_isPotentialListNode(ts)) {
          final elements = _collectList(s);
          if (elements != null) {
            listMembers[s] = elements;
          }
        }
      }
    }

    // Detect annotation reifiers
    for (final entry in tripleToReifiers.entries) {
      for (final r in entry.value) {
        if (r is BlankNode && (refCounts[r] ?? 0) == 0) {
          final ts = subjectToTriples[r] ?? [];
          // It's an annotation if it has properties other than rdf:reifies
          if (ts.any((t) => t.predicate != _rdfReifies)) {
            annotationReifiers.add(r);
          }
        }
      }
    }
  }

  bool _isPotentialListNode(List<Triple> ts) {
    bool hasFirst = false;
    bool hasRest = false;
    int count = 0;
    for (final t in ts) {
      if (t.predicate == _rdfFirst) {
        hasFirst = true;
      } else if (t.predicate == _rdfRest) {
        hasRest = true;
      } else if (t.predicate == _rdfType && t.object == _rdfList) {
        continue;
      } else {
        return false;
      }
      count++;
    }
    return hasFirst && hasRest && (count == 2);
  }

  List<ObjectTerm>? _collectList(BlankNode head) {
    final elements = <ObjectTerm>[];
    final visited = <BlankNode>{};
    var current = head;

    while (true) {
      if (visited.contains(current)) return null; // Cycle
      visited.add(current);

      final ts = subjectToTriples[current];
      if (ts == null || !_isPotentialListNode(ts)) return null;

      ObjectTerm? first;
      ObjectTerm? rest;
      for (final t in ts) {
        if (t.predicate == _rdfFirst) first = t.object;
        if (t.predicate == _rdfRest) rest = t.object;
      }

      if (first == null || rest == null) return null;
      elements.add(first);

      if (rest == _rdfNil) {
        nodesInLists.addAll(visited);
        return elements;
      }

      if (rest is! BlankNode) return null;
      if (refCounts[rest] != 1) return null;

      current = rest;
    }
  }

  void _incrementRef(RdfTerm term) {
    if (term is BlankNode) {
      refCounts[term] = (refCounts[term] ?? 0) + 1;
    } else if (term is TripleTerm) {
      _incrementRef(term.triple.subject);
      _incrementRef(term.triple.object);
    }
  }

  bool isListHead(BlankNode bnode) => listMembers.containsKey(bnode);
  bool isInternalListNode(BlankNode bnode) =>
      nodesInLists.contains(bnode) && !listMembers.containsKey(bnode);

  bool canInline(BlankNode bnode) {
    if (isInternalListNode(bnode)) return false;
    if (annotationReifiers.contains(bnode)) return false;
    return (refCounts[bnode] ?? 0) <= 1;
  }
}

class _TurtleWriter {
  final StringSink _sink;
  final Map<String, String> prefixes;
  final String? baseUri;

  int _indent = 0;
  final Set<BlankNode> _inlinedBNodes = {};
  final Set<SubjectTerm> _usedAsAnnotation = {};
  late _TurtleGraphAnalyzer _analyzer;

  static final _rdfReifies = Iri(
    'http://www.w3.org/1999/02/22-rdf-syntax-ns#reifies',
  );

  _TurtleWriter(this._sink, {this.prefixes = const {}, this.baseUri});

  void writeGraph(Iterable<Triple> triples) {
    _analyzer = _TurtleGraphAnalyzer()..analyze(triples);

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

    // 2. Filter subjects
    final allSubjects = <SubjectTerm>{};
    for (final t in triples) {
      allSubjects.add(t.subject);
    }

    final rootSubjects = allSubjects.where((s) {
      if (s is BlankNode) {
        if (_analyzer.isInternalListNode(s)) return false;
        if (_analyzer.annotationReifiers.contains(s)) return false;
        if (_analyzer.isListHead(s)) {
          return (_analyzer.refCounts[s] ?? 0) == 0;
        }
        return !_analyzer.canInline(s);
      }
      return true;
    }).toList();

    // 3. Sort subjects
    rootSubjects.sort((a, b) {
      if (a is Iri && b is! Iri) return -1;
      if (a is! Iri && b is Iri) return 1;
      return a.toString().compareTo(b.toString());
    });

    for (var i = 0; i < rootSubjects.length; i++) {
      final s = rootSubjects[i];
      final triplesForSubject = triples.where((t) => t.subject == s).toList();
      if (triplesForSubject.isEmpty && s is! BlankNode) continue;

      _writeSubject(s);
      _sink.write('\n');
      _indent++;

      _writePredicateObjectList(triplesForSubject);

      _sink.write(' .\n');
      _indent--;

      if (i < rootSubjects.length - 1) {
        _sink.write('\n');
      }
    }
  }

  void _writePredicateObjectList(List<Triple> triples) {
    final predicates = <PredicateTerm, List<ObjectTerm>>{};
    for (final t in triples) {
      predicates.putIfAbsent(t.predicate, () => []).add(t.object);
    }

    final predicateList = predicates.keys.toList();
    predicateList.sort((a, b) {
      final as = a.toString();
      final bs = b.toString();
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
        final o = objects[k];
        _writeObject(o);

        // Check for annotations
        final currentTriple = triples.firstWhere(
          (t) => t.predicate == p && t.object == o,
        );
        final reifiers = _analyzer.tripleToReifiers[currentTriple];
        if (reifiers != null) {
          for (final r in reifiers) {
            if (_analyzer.annotationReifiers.contains(r) &&
                !_usedAsAnnotation.contains(r)) {
              _usedAsAnnotation.add(r);
              _sink.write(' {| ');
              final annotationTriples = _analyzer.subjectToTriples[r]!
                  .where((t) => t.predicate != _rdfReifies)
                  .toList();
              _writePredicateObjectList(annotationTriples);
              _sink.write(' |}');
            }
          }
        }

        if (k < objects.length - 1) {
          _sink.write(' ,\n');
          _writeIndent();
          _sink.write('    ');
        }
      }

      if (j < predicateList.length - 1) {
        _sink.write(' ;\n');
      }
    }
  }

  void _writeSubject(SubjectTerm s) {
    if (s is BlankNode && _analyzer.isListHead(s)) {
      _writeList(s);
      return;
    }
    if (s is BlankNode &&
        _analyzer.canInline(s) &&
        (_analyzer.refCounts[s] ?? 0) == 0) {
      _sink.write('[ ');
      final triples = _analyzer.subjectToTriples[s] ?? [];
      if (triples.isNotEmpty) {
        _sink.write('\n');
        _indent++;
        _writePredicateObjectList(triples);
        _indent--;
        _writeIndent();
      }
      _sink.write(']');
      return;
    }

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
    if (o is BlankNode && _analyzer.isListHead(o)) {
      _writeList(o);
      return;
    }

    if (o is BlankNode &&
        _analyzer.canInline(o) &&
        !_inlinedBNodes.contains(o)) {
      _inlinedBNodes.add(o);
      _sink.write('[ ');
      final triples = _analyzer.subjectToTriples[o] ?? [];
      if (triples.isNotEmpty) {
        _sink.write('\n');
        _indent++;
        _writePredicateObjectList(triples);
        _indent--;
        _writeIndent();
      }
      _sink.write(']');
      return;
    }

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

  void _writeList(BlankNode head) {
    final members = _analyzer.listMembers[head]!;
    _sink.write('( ');
    for (var i = 0; i < members.length; i++) {
      _writeObject(members[i]);
      if (i < members.length - 1) _sink.write(' ');
    }
    _sink.write(' )');
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
    for (final entry in prefixes.entries) {
      final namespace = entry.value;
      if (iriStr.startsWith(namespace)) {
        final localName = iriStr.substring(namespace.length);
        if (_isValidLocalName(localName)) {
          return '${entry.key}:$localName';
        }
      }
    }
    if (baseUri != null && iriStr.startsWith(baseUri!)) {
      final rel = iriStr.substring(baseUri!.length);
      if (!rel.contains('>')) {
        return '<$rel>';
      }
    }
    return '<$iriStr>';
  }

  bool _isValidLocalName(String localName) {
    if (localName.isEmpty) return true;
    final regex = RegExp(r'^[a-zA-Z0-9_]([a-zA-Z0-9_\-:]*[a-zA-Z0-9_:])?$');
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
        _sink.write(
          '--${l.baseDirection == TextDirection.LTR ? 'ltr' : 'rtl'}',
        );
      }
    } else if (l.datatypeIri.toString() !=
        'http://www.w3.org/2001/XMLSchema#string') {
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
