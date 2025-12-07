import 'dart:convert';

import '../../model/triple.dart';

/// A [Converter] that encodes [Iterable] of [Triple]s to N-Triples strings.
class NTriplesEncoder extends Converter<Iterable<Triple>, String> {
  const NTriplesEncoder();

  @override
  String convert(Iterable<Triple> input) {
    throw UnimplementedError();
  }
}
