import '../dataset.dart';
import '../graph.dart';
import '../quad.dart';
import '../term.dart';
import 'in_memory_graph.dart';

/// A map-based in-memory implementation of [Dataset].
class InMemoryDataset implements Dataset {
  final Graph _defaultGraph = InMemoryGraph();
  final Map<GraphName, Graph> _namedGraphs = {};

  @override
  Graph get defaultGraph => _defaultGraph;

  @override
  Iterable<GraphName> get graphNames => _namedGraphs.keys;

  @override
  Graph namedGraph(GraphName graphName) {
    return _namedGraphs.putIfAbsent(graphName, () => InMemoryGraph());
  }

  @override
  bool add(Quad quad) {
    final graph = quad.graphName != null
        ? namedGraph(quad.graphName!)
        : _defaultGraph;
    return graph.add(quad.triple);
  }

  @override
  bool remove(Quad quad) {
    if (quad.graphName == null) {
      return _defaultGraph.remove(quad.triple);
    } else {
      final graph = _namedGraphs[quad.graphName];
      if (graph == null) return false;
      return graph.remove(quad.triple);
    }
  }

  @override
  Iterable<Quad> get quads {
    final defaultQuads = _defaultGraph.triples.map((t) => Quad(t));
    final namedQuads = _namedGraphs.entries.expand((entry) {
      return entry.value.triples.map((t) => Quad(t, entry.key));
    });
    return defaultQuads.followedBy(namedQuads);
  }

  @override
  Iterable<Quad> match({
    RdfTerm? subject,
    RdfTerm? predicate,
    RdfTerm? object,
    GraphName? graphName,
  }) {
    // If graphName is provided, only match in that graph.
    if (graphName != null) {
      if (!_namedGraphs.containsKey(graphName)) return [];

      // Validate types before passing to Graph.match
      if (subject != null && subject is! SubjectTerm) return [];
      if (predicate != null && predicate is! PredicateTerm) return [];
      if (object != null && object is! ObjectTerm) return [];

      return _namedGraphs[graphName]!
          .match(
            subject: subject as SubjectTerm?,
            predicate: predicate as PredicateTerm?,
            object: object as ObjectTerm?,
          )
          .map((t) => Quad(t, graphName));
    }

    // Otherwise, match in all graphs (including default).
    // Note: Implicitly, `graphName: null` acts as a wildcard, matching content in any graph.

    return quads.where((quad) {
      if (subject != null && quad.triple.subject != subject) return false;
      if (predicate != null && quad.triple.predicate != predicate) return false;
      if (object != null && quad.triple.object != object) return false;
      if (graphName != null && quad.graphName != graphName) return false;
      return true;
    });
  }
}
