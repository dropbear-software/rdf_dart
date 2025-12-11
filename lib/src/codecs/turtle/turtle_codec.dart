import 'dart:convert';

import '../../model/triple.dart';
import 'turtle_decoder.dart';
import 'turtle_encoder.dart';

/// A global instance of [TurtleCodec].
const turtleCodec = TurtleCodec();

class TurtleCodec extends Codec<Iterable<Triple>, String> {
  const TurtleCodec();

  @override
  // TODO: implement decoder
  Converter<String, Iterable<Triple>> get decoder => const TurtleDecoder();

  @override
  // TODO: implement encoder
  Converter<Iterable<Triple>, String> get encoder => const TurtleEncoder();
}
