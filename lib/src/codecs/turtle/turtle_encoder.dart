import 'dart:convert';

import '../../model/triple.dart';
import '../n-triples/n_triples_encoder.dart';

/// A [Converter] that encodes [Iterable] of [Triple]s to Turtle strings.
///
/// Currently produces N-Triples compatible output, which is a valid subset of Turtle.
class TurtleEncoder extends Converter<Iterable<Triple>, String> {
  const TurtleEncoder();

  @override
  String convert(Iterable<Triple> input) {
    // N-Triples is a subset of Turtle, so this is a valid implementation.
    // In the future, this can be enhanced to support prefixes, nesting, etc.
    return const NTriplesEncoder().convert(input);
  }
}
