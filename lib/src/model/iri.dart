import '../util/iri.dart' as impl;
import 'term.dart';

/// An RDF Term acting as an IRI (Internationalized Resource Identifier).
///
/// An [Iri] can appear in the Subject, Predicate, or Object position of a triple.
/// It wraps [impl.Iri] to provide IRI handling while implementing RDF term interfaces.
class Iri implements SubjectTerm, PredicateTerm, ObjectTerm, GraphName {
  final impl.Iri _iri;

  /// Creates an [Iri] from a string.
  ///
  /// Delegates to [impl.Iri.parse].
  factory Iri(String value) => Iri.parse(value);

  /// Parses [value] as an IRI.
  factory Iri.parse(String value) => Iri._(impl.Iri.parse(value));

  /// Creates an [Iri] from an existing Uri.
  factory Iri.fromUri(Uri uri) => Iri._(impl.Iri.fromUri(uri));

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
    return Iri._(
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
      ),
    );
  }

  const Iri._(this._iri);

  /// The scheme component.
  String get scheme => _iri.scheme;

  /// The host component.
  String get host => _iri.host;

  /// The path component.
  String get path => _iri.path;

  /// The query component.
  String? get query => _iri.query;

  /// The fragment component.
  String? get fragment => _iri.fragment;

  /// The user info component.
  String? get userInfo => _iri.userInfo;

  /// The port component.
  int get port => _iri.port;

  /// The path segments.
  List<String> get pathSegments => _iri.pathSegments;

  /// The query parameters.
  Map<String, String> get queryParameters => _iri.queryParameters;

  @override
  String toString() => _iri.toString();

  /// Returns the underlying [Uri] with percent-encoded components.
  Uri toUri() => _iri.toUri();

  /// Resolves [reference] against this IRI.
  Iri resolve(String reference) => Iri._(_iri.resolve(reference));

  /// Returns a new [Iri] with the given components replaced.
  Iri replace({
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
    return Iri._(
      _iri.replace(
        scheme: scheme,
        userInfo: userInfo,
        host: host,
        port: port,
        path: path,
        pathSegments: pathSegments,
        query: query,
        queryParameters: queryParameters,
        fragment: fragment,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is Iri) {
      return _iri == other._iri;
    }
    if (other is Uri) {
      return toUri() == other;
    }
    return false;
  }

  @override
  int get hashCode => _iri.hashCode;

  @override

  /// Always returns true for IRIs.
  bool get isGround => true;
}
