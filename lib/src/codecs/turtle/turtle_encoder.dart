import 'dart:convert';
import 'package:intl/intl.dart';

import '../../model/blank_node.dart';
import '../../model/iri.dart';
import '../../model/literal.dart';
import '../../model/term.dart';
import '../../model/triple.dart';
import '../../model/triple_term.dart';
import '../../vocabulary/vocabulary.dart';

/// A [Converter] that encodes [Iterable] of [Triple]s to Turtle strings.
///
/// This encoder produces human-readable, terse output by utilizing:
/// * **Prefixes**: Shortens IRIs using the provided [prefixes] map.
/// * **Base URI**: Resolves IRIs relative to [baseUri] if provided.
/// * **Grouping**: Combines triples with shared subjects and predicates using `;` and `,`.
/// * **Inlining**: Nests single-reference blank nodes using `[ ... ]`.
/// * **Collections**: Represents `rdf:List` structures using `( ... )`.
/// * **RDF 1.2 Features**: Supports `TripleTerm` serialization and `{| ... |}` annotation syntax.
class TurtleEncoder extends Converter<Iterable<Triple>, String> {
  /// Map of prefix labels to namespace IRIs.
  final Map<String, String> prefixes;

  /// Base IRI to use for relative IRI resolution.
  final String? baseUri;

  /// Creates a [TurtleEncoder] with the given [prefixes] and [baseUri].
  const TurtleEncoder({this.prefixes = const {}, this.baseUri});

  @override
  String convert(Iterable<Triple> input) {
    final sb = StringBuffer();
    final writer = _TurtleWriter(sb, prefixes: prefixes, baseUri: baseUri);
    writer.writeGraph(input);
    return sb.toString();
  }
}

/// A pre-processor that analyzes an RDF graph to identify opportunities for
/// terse serialization.
///
/// It performs:
/// 1. **Reference Counting**: Identifies blank nodes that are only used once as objects.
/// 2. **List Detection**: Finds well-formed `rdf:List` structures.
/// 3. **Annotation Detection**: Identifies `rdf:reifies` patterns for annotation syntax.
class _TurtleGraphAnalyzer {
  /// Map of blank nodes to their incoming reference count.
  final Map<BlankNode, int> refCounts = {};

  /// Map of subjects to the triples they are part of.
  final Map<SubjectTerm, List<Triple>> subjectToTriples = {};

  /// Map of blank nodes representing list heads to their ordered member terms.
  final Map<BlankNode, List<ObjectTerm>> listMembers = {};

  /// Set of blank nodes that are part of a detected collection.
  final Set<BlankNode> nodesInLists = {};

  /// Map of triples to their reifier nodes (if any).
  final Map<Triple, Set<SubjectTerm>> tripleToReifiers = {};

  /// Set of reifiers that can be serialized using annotation syntax `{| ... |}`.
  final Set<SubjectTerm> annotationReifiers = {};

  /// Performs the analysis pass over the given [triples].
  void analyze(Iterable<Triple> triples) {
    for (final t in triples) {
      final s = t.subject;
      subjectToTriples.putIfAbsent(s, () => []).add(t);
      _incrementRef(t.object);

      // Detect reification for RDF 1.2
      if (t.predicate == Rdf.reifies && t.object is TripleTerm) {
        final reifiedTriple = (t.object as TripleTerm).triple;
        tripleToReifiers.putIfAbsent(reifiedTriple, () => {}).add(t.subject);
      }
    }

    // Detect lists (collections)
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

    // Detect annotation reifiers: reifiers that are blank nodes,
    // not referenced elsewhere, and have metadata properties.
    for (final entry in tripleToReifiers.entries) {
      for (final r in entry.value) {
        if (r is BlankNode && (refCounts[r] ?? 0) == 0) {
          final ts = subjectToTriples[r] ?? [];
          // It's an annotation if it has properties other than rdf:reifies
          if (ts.any((t) => t.predicate != Rdf.reifies)) {
            annotationReifiers.add(r);
          }
        }
      }
    }
  }

  /// Returns true if the set of triples [ts] suggests the node is an `rdf:List` element.
  bool _isPotentialListNode(List<Triple> ts) {
    bool hasFirst = false;
    bool hasRest = false;
    int count = 0;
    for (final t in ts) {
      if (t.predicate == Rdf.first) {
        hasFirst = true;
      } else if (t.predicate == Rdf.rest) {
        hasRest = true;
      } else if (t.predicate == Rdf.type && t.object == Rdf.List) {
        continue;
      } else {
        return false;
      }
      count++;
    }
    return hasFirst && hasRest && (count == 2);
  }

  /// Recursively collects the elements of a collection starting at [head].
  ///
  /// Returns `null` if the structure is not a valid, well-formed, acyclic list.
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
        if (t.predicate == Rdf.first) first = t.object;
        if (t.predicate == Rdf.rest) rest = t.object;
      }

      if (first == null || rest == null) return null;
      elements.add(first);

      if (rest == Rdf.nil) {
        nodesInLists.addAll(visited);
        return elements;
      }

      if (rest is! BlankNode) return null;
      if (refCounts[rest] != 1) return null;

      current = rest;
    }
  }

  /// Recursively increments reference counts for terms, delving into triple terms.
  void _incrementRef(RdfTerm term) {
    if (term is BlankNode) {
      refCounts[term] = (refCounts[term] ?? 0) + 1;
    } else if (term is TripleTerm) {
      _incrementRef(term.triple.subject);
      _incrementRef(term.triple.object);
    }
  }

  /// Returns true if [bnode] is the starting node of a detected collection.
  bool isListHead(BlankNode bnode) => listMembers.containsKey(bnode);

  /// Returns true if [bnode] is an internal part of a collection (not the head).
  bool isInternalListNode(BlankNode bnode) =>
      nodesInLists.contains(bnode) && !listMembers.containsKey(bnode);

  /// Returns true if [bnode] can be inlined using the `[ ... ]` syntax.
  bool canInline(BlankNode bnode) {
    if (isInternalListNode(bnode)) return false;
    if (annotationReifiers.contains(bnode)) return false;
    return (refCounts[bnode] ?? 0) <= 1;
  }
}

/// A stateful writer that handles the serialization of an RDF graph to Turtle.
///
/// It maintains indentation levels and tracks which blank nodes have been
/// inlined to avoid duplicate serialization of nested structures.
class _TurtleWriter {
  final StringSink _sink;
  final Map<String, String> prefixes;
  final String? baseUri;

  int _indent = 0;
  final Set<BlankNode> _inlinedBNodes = {};
  final Set<SubjectTerm> _usedAsAnnotation = {};
  late _TurtleGraphAnalyzer _analyzer;

  /// Creates a [_TurtleWriter] writing to [_sink].
  _TurtleWriter(this._sink, {this.prefixes = const {}, this.baseUri});

  /// Serializes the set of [triples] to the output sink.
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

    // 2. Determine "root" subjects: nodes that are not inlined inside others.
    final allSubjects = <SubjectTerm>{};
    for (final t in triples) {
      allSubjects.add(t.subject);
    }

    final rootSubjects = allSubjects.where((s) {
      if (s is BlankNode) {
        // Internal collection nodes and inlined objects are not root subjects.
        if (_analyzer.isInternalListNode(s)) return false;
        if (_analyzer.annotationReifiers.contains(s)) return false;
        if (_analyzer.isListHead(s)) {
          // List heads are roots only if not referenced as an object.
          return (_analyzer.refCounts[s] ?? 0) == 0;
        }
        return !_analyzer.canInline(s);
      }
      return true;
    }).toList();

    // 3. Sort subjects for deterministic output.
    rootSubjects.sort((a, b) {
      if (a is Iri && b is! Iri) return -1;
      if (a is! Iri && b is Iri) return 1;
      return a.toString().compareTo(b.toString());
    });

    // 4. Write each subject block.
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

  /// Writes a list of predicates and their objects for a shared subject.
  void _writePredicateObjectList(List<Triple> triples) {
    // Group by predicate
    final predicates = <PredicateTerm, List<ObjectTerm>>{};
    for (final t in triples) {
      predicates.putIfAbsent(t.predicate, () => []).add(t.object);
    }

    final predicateList = predicates.keys.toList();
    // Sort predicates, prioritizing rdf:type (shorthand 'a').
    predicateList.sort((a, b) {
      if (a == Rdf.type) return -1;
      if (b == Rdf.type) return 1;
      return a.toString().compareTo(b.toString());
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

        // Check for RDF 1.2 Annotation syntax opportunities.
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
                  .where((t) => t.predicate != Rdf.reifies)
                  .toList();
              _writePredicateObjectList(annotationTriples);
              _sink.write(' |}');
            }
          }
        }

        if (k < objects.length - 1) {
          _sink.write(' ,\n');
          _writeIndent();
          _sink.write('    '); // Extra alignment for object list items
        }
      }

      if (j < predicateList.length - 1) {
        _sink.write(' ;\n');
      }
    }
  }

  /// Writes the subject term, handling potential inlining or collections.
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

  /// Writes the predicate term, using 'a' for rdf:type.
  void _writePredicate(PredicateTerm p) {
    if (p == Rdf.type) {
      _sink.write('a');
    } else if (p is Iri) {
      _writeIri(p);
    }
  }

  /// Writes the object term, recursing into nested structures if appropriate.
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

  /// Writes an `rdf:List` using the `( ... )` collection syntax.
  void _writeList(BlankNode head) {
    final members = _analyzer.listMembers[head]!;
    _sink.write('( ');
    for (var i = 0; i < members.length; i++) {
      _writeObject(members[i]);
      if (i < members.length - 1) _sink.write(' ');
    }
    _sink.write(' )');
  }

  /// Writes a raw triple (s p o) without a terminator.
  void _writeTriple(Triple t) {
    _writeSubject(t.subject);
    _sink.write(' ');
    _writePredicate(t.predicate);
    _sink.write(' ');
    _writeObject(t.object);
  }

  /// Writes an IRI, applying relativization or prefix shortening.
  void _writeIri(Iri iri) {
    _sink.write(_relativizeIri(iri));
  }

  /// Returns the shortened or relative string representation of [iri].
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
      // Ensure the relative path doesn't break Turtle parsing.
      if (!rel.contains('>')) {
        return '<$rel>';
      }
    }

    // Default: return full IRI in brackets.
    return '<$iriStr>';
  }

  /// Validates [localName] against the Turtle `PN_LOCAL` grammar.
  bool _isValidLocalName(String localName) {
    if (localName.isEmpty) return true;
    // Implementation note: This regex approximates the Turtle PN_LOCAL production
    // without supporting escaping (PLX) for simplicity in generation.
    final regex = RegExp(r'^[a-zA-Z0-9_]([a-zA-Z0-9_\-:]*[a-zA-Z0-9_:])?$');
    return regex.hasMatch(localName);
  }

  /// Writes a blank node identifier.
  void _writeBlankNode(BlankNode b) {
    _sink.write(b.toString());
  }

  /// Writes a literal, including quotes, escaping, and datatype/lang tags.
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
    } else if (l.datatypeIri != Xsd.string) {
      _sink.write('^^');
      _writeIri(l.datatypeIri);
    }
  }

  /// Outputs spaces for the current indentation level.
  void _writeIndent() {
    _sink.write('    ' * _indent);
  }

  /// Escapes special characters in the literal's lexical form.
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

  /// Writes a Unicode character as a numeric escape sequence.
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
