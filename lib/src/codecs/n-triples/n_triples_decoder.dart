import 'dart:convert';

import '../../model/triple.dart';

/// A [Converter] that decodes N-Triples strings to [Iterable] of [Triple]s.
class NTriplesDecoder extends Converter<String, Iterable<Triple>> {
  const NTriplesDecoder();

  @override
  Iterable<Triple> convert(String input) {
    throw UnimplementedError();
  }
}
