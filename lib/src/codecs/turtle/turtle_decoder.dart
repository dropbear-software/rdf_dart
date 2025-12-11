import 'dart:convert';

import '../../model/triple.dart';

class TurtleDecoder extends Converter<String, Iterable<Triple>> {
  const TurtleDecoder();

  @override
  Iterable<Triple> convert(String input) {
    // TODO: implement convert
    throw UnimplementedError();
  }
}
