import 'dart:convert';

import '../../model/triple.dart';
import 'turtle_decoder.dart';
import 'turtle_encoder.dart';

export 'turtle_decoder.dart';
export 'turtle_encoder.dart';

/// A global instance of [TurtleCodec] with default configuration.
const turtleCodec = TurtleCodec();

class TurtleCodec extends Codec<Iterable<Triple>, String> {
  /// Map of prefix labels to namespace IRIs.
  final Map<String, String> prefixes;

  /// Base IRI to use for relative IRI resolution.
  final String? baseUri;

  const TurtleCodec({
    this.prefixes = const {},
    this.baseUri,
  });

  @override
  Converter<String, Iterable<Triple>> get decoder =>
      TurtleDecoder(baseUri: baseUri);

  @override
  Converter<Iterable<Triple>, String> get encoder => TurtleEncoder(
    prefixes: prefixes,
    baseUri: baseUri,
  );
}
