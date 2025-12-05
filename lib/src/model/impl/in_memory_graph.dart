import '../graph.dart';
import '../term.dart';
import '../triple.dart';

/// A set-based in-memory implementation of [Graph].
class InMemoryGraph implements Graph {
  final Set<Triple> _triples = {};

  @override
  Iterable<Triple> get triples => _triples;

  @override
  int get length => _triples.length;

  @override
  bool contains(Triple triple) => _triples.contains(triple);

  @override
  bool add(Triple triple) => _triples.add(triple);

  @override
  bool remove(Triple triple) => _triples.remove(triple);

  @override
  Iterable<Triple> match({Term? subject, Term? predicate, Term? object}) {
    return _triples.where((triple) {
      if (subject != null && triple.subject != subject) return false;
      if (predicate != null && triple.predicate != predicate) return false;
      if (object != null && triple.object != object) return false;
      return true;
    });
  }
}
