import '../util/iri.dart' as impl;
import 'term.dart';

/// An RDF Term acting as an IRI (Internationalized Resource Identifier).
///
/// An [Iri] can appear in the Subject, Predicate, or Object position of a triple.
/// It extends [impl.Iri] to provide IRI handling while implementing RDF term interfaces.
class Iri extends impl.Iri
    implements SubjectTerm, PredicateTerm, ObjectTerm, GraphName {
  /// Creates an [Iri] from a string.
  ///
  /// Delegates to [impl.Iri.parse].
  factory Iri(String value) => Iri.fromUri(Uri.parse(value));

  /// Parses [value] as an IRI.
  static Iri parse(String value) => Iri(value);

  /// Creates an [Iri] from an existing Uri.
  const Iri.fromUri(super.uri) : super.fromUri();

  /// Creates an [Iri] from its components.
  factory Iri.fromComponents({
    String? scheme,
    String? userInfo,
    String? host,
    int? port,
    String? path,
    Iterable<String>? pathSegments,
    String? query,
    Map<String, dynamic>? queryParameters,
    String? fragment,
  }) {
    return Iri.fromUri(
      impl.Iri(
        scheme: scheme,
        userInfo: userInfo,
        host: host,
        port: port,
        path: path,
        pathSegments: pathSegments,
        query: query,
        queryParameters: queryParameters,
        fragment: fragment,
      ).toPercentEncodedUri(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Iri) {
      return toPercentEncodedUri() == other.toPercentEncodedUri();
    }
    if (other is impl.Iri) {
      return toPercentEncodedUri() ==
          other.toPercentEncodedUri(); // Compare with base class
    }
    if (other is Uri) return toPercentEncodedUri() == other;
    return false;
  }

  @override
  int get hashCode => toPercentEncodedUri().hashCode;

  @override
  /// Always returns true for IRIs.
  bool get isGround => true;
}
