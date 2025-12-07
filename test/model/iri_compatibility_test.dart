import 'package:rdf_dart/src/model/internationalised_resource_identifier.dart';
import 'package:test/test.dart';

void main() {
  test('IRI with non-ascii characters in host', () {
    final exampleIri = Iri.parse('http://例子.com/');
    expect(exampleIri.toString(), equals('http://例子.com/'));
    expect(exampleIri.host, equals('例子.com'));
    expect(exampleIri.authority, equals('例子.com'));
    expect(exampleIri.path, equals('/'));
    expect(exampleIri.query, equals(''));
    expect(exampleIri.fragment, equals(''));
  });

  test('IRI with non-ascii characters in path', () {
    final exampleIri = Iri.parse('http://example.com/例子');
    expect(exampleIri.toString(), equals('http://example.com/例子'));
    expect(exampleIri.host, equals('example.com'));
    expect(exampleIri.authority, equals('example.com'));
    expect(exampleIri.path, equals('/例子'));
    expect(exampleIri.query, equals(''));
    expect(exampleIri.fragment, equals(''));
  });

  test('IRI with non-ascii characters in query', () {
    final exampleIri = Iri.parse('http://example.com/?例子=例子');
    expect(exampleIri.toString(), equals('http://example.com/?例子=例子'));
    expect(exampleIri.host, equals('example.com'));
    expect(exampleIri.authority, equals('example.com'));
    expect(exampleIri.path, equals('/'));
    expect(exampleIri.query, equals('例子=例子'));
    expect(exampleIri.fragment, equals(''));
  });

  test('IRI with non-ascii characters in fragment', () {
    final exampleIri = Iri.parse('http://example.com/#例子');
    expect(exampleIri.toString(), equals('http://example.com/#例子'));
    expect(exampleIri.host, equals('example.com'));
    expect(exampleIri.authority, equals('example.com'));
    expect(exampleIri.path, equals('/'));
    expect(exampleIri.query, equals(''));
    expect(exampleIri.fragment, equals('例子'));
  });

  test('Case normalization of the host', () {
    final exampleIri = Iri.parse('http://Exämple.org/path');
    expect(exampleIri.toString(), equals('http://exämple.org/path'));
    expect(exampleIri.host, equals('exämple.org'));
    expect(exampleIri.authority, equals('exämple.org'));
    expect(exampleIri.path, equals('/path'));
    expect(exampleIri.query, equals(''));
    expect(exampleIri.fragment, equals(''));
  });
}
