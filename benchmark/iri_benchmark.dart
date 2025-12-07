import 'package:iri/iri.dart';
import 'dart:core';
import 'package:rdf_dart/src/model/internationalised_resource_identifier.dart'
    as new_iri;

void main() {
  const iterations = 1000;
  final urisToParse = [
    'http://example.com',
    'https://www.google.com/search?q=dart',
    'mailto:user@example.com',
    'urn:isbn:978-0-123-45678-9',
    '/relative/path/to/resource',
    'file:/home/user/file.txt',
    'http://[2001:db8::1]:80',
    'http://example.com/path#fragment',
    'scheme:path?query#fragment',
    // Add a complex IRI to test decoding cost
    'http://éxample.com/rèsource?quèry=valü%20&encoded=%C3%A9',
  ];

  print('Running benchmark with $iterations iterations per URI...');

  // Warmup
  print('Warming up...');
  for (var i = 0; i < 1000; i++) {
    for (var s in urisToParse) {
      Uri.parse(s);
      try {
        IRI(s);
      } catch (_) {} // Catch potential IRI package errors on utf8
      new_iri.Iri.parse(s);
    }
  }

  // Benchmark Uri.parse
  final stopwatchUri = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    for (var s in urisToParse) {
      Uri.parse(s);
    }
  }
  stopwatchUri.stop();
  print('Uri.parse: ${stopwatchUri.elapsedMilliseconds} ms');

  // Benchmark IRI constructor (package:iri)
  final stopwatchIri = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    for (var s in urisToParse) {
      try {
        IRI(s);
      } catch (_) {
        // Some might fail if IRI package is strict or buggy with unicode inputs?
        // But we want to measure successful creation if possible.
      }
    }
  }
  stopwatchIri.stop();
  print('package:iri IRI(): ${stopwatchIri.elapsedMilliseconds} ms');

  // Benchmark New Iri constructor (package:rdf_dart)
  final stopwatchNewIri = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    for (var s in urisToParse) {
      new_iri.Iri.parse(s);
    }
  }
  stopwatchNewIri.stop();
  print('New Iri.parse(): ${stopwatchNewIri.elapsedMilliseconds} ms');

  if (stopwatchUri.elapsedMilliseconds > 0) {
    final ratioOld =
        stopwatchIri.elapsedMilliseconds / stopwatchUri.elapsedMilliseconds;
    final ratioNew =
        stopwatchNewIri.elapsedMilliseconds / stopwatchUri.elapsedMilliseconds;
    final speedup =
        stopwatchIri.elapsedMilliseconds / stopwatchNewIri.elapsedMilliseconds;

    print('\nComparisons (vs Uri):');
    print('package:iri: ${ratioOld.toStringAsFixed(2)}x slower');
    print('New Iri:     ${ratioNew.toStringAsFixed(2)}x slower');
    print('\nSpeedup (package:iri vs New Iri):');
    print('New Iri is ${speedup.toStringAsFixed(2)}x faster than package:iri');
  } else {
    print('Uri.parse was too fast to measure properly.');
  }
}
