import '../blank_node.dart';
import '../term.dart';
import '../triple.dart';
import '../triple_term.dart';

/// A strategy for handling isomorphism checks for a specific type [T] (e.g., Triple or Quad).
abstract interface class IsomorphismStrategy<T> {
  /// Returns `true` if [item] is ground (contains no blank nodes).
  bool isGround(T item);

  /// Recursively collects all blank nodes from [item] into [set].
  void collectBlankNodes(T item, Set<BlankNode> set);

  /// Returns a new instance of [T] with blank nodes mapped according to [mapping].
  T mapBlankNodes(T item, Map<BlankNode, BlankNode> mapping);
}

/// A generic solver for graph and dataset isomorphism.
///
/// This class finds a bijection between blank nodes in two sets of items [T].
class IsomorphismSolver<T> {
  final IsomorphismStrategy<T> _strategy;

  IsomorphismSolver(this._strategy);

  /// Checks if two collections of items are isomorphic.
  bool isIsomorphic(Iterable<T> items1, Iterable<T> items2) {
    // 1. Separation
    final g1Ground = <T>{};
    final g1NonGround = <T>[];
    for (final item in items1) {
      if (_strategy.isGround(item)) {
        g1Ground.add(item);
      } else {
        g1NonGround.add(item);
      }
    }

    final g2Ground = <T>{};
    final g2NonGround =
        <T>{}; // Use Set for fast lookup and existence check during mapping
    for (final item in items2) {
      if (_strategy.isGround(item)) {
        g2Ground.add(item);
      } else {
        g2NonGround.add(item);
      }
    }

    // 2. Ground Check
    if (g1Ground.length != g2Ground.length) return false;
    if (!g1Ground.containsAll(g2Ground)) return false;

    // 3. Non-Ground Count Check
    if (g1NonGround.length != g2NonGround.length) return false;

    // 4. Blank Node Collection
    final bNodes1 = <BlankNode>{};
    for (final item in g1NonGround) {
      _strategy.collectBlankNodes(item, bNodes1);
    }
    final bNodes2 = <BlankNode>{};
    for (final item in g2NonGround) {
      _strategy.collectBlankNodes(item, bNodes2);
    }

    if (bNodes1.length != bNodes2.length) return false;
    if (bNodes1.isEmpty) return true;

    // 5. Backtracking
    return _solve(
      bNodes1.toList(),
      bNodes2.toList(),
      {},
      g1NonGround,
      g2NonGround,
    );
  }

  /// Recursively solves for a valid blank node bijection using backtracking.
  ///
  /// [unmapped1] is the list of blank nodes from the first set that have not yet been mapped.
  /// [available2] is the list of blank nodes from the second set that are available to be mapped to.
  /// [mapping] is the current partial mapping being built.
  /// [items1] are the non-ground items from the first set.
  /// [items2] are the non-ground items from the second set (for validation).
  ///
  /// Returns `true` if a valid full bijection is found, `false` otherwise.
  bool _solve(
    List<BlankNode> unmapped1,
    List<BlankNode> available2,
    Map<BlankNode, BlankNode> mapping,
    List<T> items1,
    Set<T> items2,
  ) {
    if (unmapped1.isEmpty) {
      return _checkMapping(mapping, items1, items2);
    }

    final current = unmapped1.first;
    final rest1 = unmapped1.sublist(1);

    for (var i = 0; i < available2.length; i++) {
      final candidate = available2[i];

      mapping[current] = candidate;

      final rest2 = List<BlankNode>.from(available2)..removeAt(i);
      if (_solve(rest1, rest2, mapping, items1, items2)) {
        return true;
      }

      mapping.remove(current);
    }
    return false;
  }

  /// specific mapping.
  ///
  /// Applies the [mapping] to all items in [items1] and checks if the resulting
  /// items exist in [items2].
  bool _checkMapping(
    Map<BlankNode, BlankNode> mapping,
    List<T> items1,
    Set<T> items2,
  ) {
    for (final item1 in items1) {
      final mappedItem = _strategy.mapBlankNodes(item1, mapping);
      if (!items2.contains(mappedItem)) return false;
    }
    return true;
  }
}

/// Shared helper methods for strategies.
class IsomorphismHelpers {
  /// Collects blank nodes from an [RdfTerm].
  ///
  /// If the term is a [BlankNode], it is added to the [set].
  /// If the term is a [TripleTerm], the [recurseTriple] callback is invoked
  /// to recursively collect blank nodes from the nested triple.
  static void collectFromTerm(
    RdfTerm term,
    Set<BlankNode> set, {
    required void Function(Triple t, Set<BlankNode> set) recurseTriple,
  }) {
    if (term is BlankNode) {
      set.add(term);
    } else if (term is TripleTerm) {
      recurseTriple(term.triple, set);
    }
  }

  /// Maps blank nodes within an [RdfTerm] using the given [mapping].
  ///
  /// If the term is a [BlankNode], it is replaced with its mapped value.
  /// If the term is a [TripleTerm], the [mapTriple] callback is invoked
  /// to recursively map the nested triple.
  /// Otherwise, the term is returned as-is.
  static RdfTerm mapTerm(
    RdfTerm term,
    Map<BlankNode, BlankNode> mapping, {
    required Triple Function(Triple t, Map<BlankNode, BlankNode> mapping)
    mapTriple,
  }) {
    if (term is BlankNode) {
      return mapping[term]!;
    } else if (term is TripleTerm) {
      return TripleTerm(mapTriple(term.triple, mapping));
    } else {
      return term;
    }
  }
}
