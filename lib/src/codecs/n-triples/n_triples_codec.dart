import 'dart:convert';

import '../../model/triple.dart';
import 'n_triples_decoder.dart';
import 'n_triples_encoder.dart';

/// A global instance of [NTriplesCodec].
const nTriplesCodec = NTriplesCodec();

/// A [Codec] that encodes [Iterable] of [Triple]s to N-Triples strings and
/// decodes N-Triples strings to [Iterable] of [Triple]s.
class NTriplesCodec extends Codec<Iterable<Triple>, String> {
  const NTriplesCodec();

  @override
  Converter<Iterable<Triple>, String> get encoder => const NTriplesEncoder();

  @override
  Converter<String, Iterable<Triple>> get decoder => const NTriplesDecoder();
}
