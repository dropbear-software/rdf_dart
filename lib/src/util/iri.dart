import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:punycoder/punycoder.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

/// An Internationalized Resource Identifier (IRI).
///
/// An IRI is a sequence of characters from the Universal Character Set (Unicode).
/// It provides a complement to the Uniform Resource Identifier (URI).
///
/// This implementation is a wrapper around the native [Uri] class, providing
/// Seamless mapping to URIs as defined in RFC 3987.
///
/// All strings passed to constructors or parsing methods are automatically
/// normalized to Normalization Form KC (NFKC).
@immutable
class Iri {
  final Uri _uri;

  late final Uri _convertedUri = _computeUri();

  /// Creates a new IRI from its components.
  ///
  /// This mirrors the [Uri] constructor. All string components are
  /// normalized to NFKC.
  Iri({
    String? scheme,
    String? userInfo,
    String? host,
    int? port,
    String? path,
    Iterable<String>? pathSegments,
    String? query,
    Map<String, dynamic>? queryParameters,
    String? fragment,
  }) : _uri = Uri(
         scheme: scheme,
         userInfo: userInfo != null ? unorm.nfkc(userInfo) : null,
         host: host != null ? unorm.nfkc(host) : null,
         port: port,
         path: path != null ? unorm.nfkc(path) : null,
         pathSegments: pathSegments?.map(unorm.nfkc),
         query: query != null ? unorm.nfkc(query) : null,
         queryParameters: _normalizeQueryParameters(queryParameters),
         fragment: fragment != null ? unorm.nfkc(fragment) : null,
       );

  /// Creates a new http IRI from its components.
  Iri.http(
    String host, [
    String path = '',
    Map<String, dynamic>? queryParameters,
  ]) : _uri = Uri.http(
         unorm.nfkc(host),
         unorm.nfkc(path),
         _normalizeQueryParameters(queryParameters),
       );

  /// Creates a new https IRI from its components.
  Iri.https(
    String host, [
    String path = '',
    Map<String, dynamic>? queryParameters,
  ]) : _uri = Uri.https(
         unorm.nfkc(host),
         unorm.nfkc(path),
         _normalizeQueryParameters(queryParameters),
       );

  /// Creates a new file IRI from its components.
  Iri.file(String path, {bool? windows})
    : _uri = Uri.file(unorm.nfkc(path), windows: windows);

  /// Creates a new IRI from an existing [Uri].
  Iri.fromUri(this._uri);

  /// Internal constructor for creating an [Iri] from an existing [Uri].
  Iri._(this._uri);

  /// Parses a string into an [Iri].
  ///
  /// The input string is normalized to NFKC before parsing.
  factory Iri.parse(String input) {
    final normalized = unorm.nfkc(input);
    return Iri._(Uri.parse(normalized));
  }

  /// Parses a string into an [Iri], or returns null if it fails.
  ///
  /// The input string is normalized to NFKC before parsing.
  static Iri? tryParse(String input) {
    final normalized = unorm.nfkc(input);
    final uri = Uri.tryParse(normalized);
    return uri == null ? null : Iri._(uri);
  }

  static Map<String, dynamic>? _normalizeQueryParameters(
    Map<String, dynamic>? params,
  ) {
    if (params == null) return null;
    return params.map((k, v) {
      final Object? normalizedValue;
      if (v is String) {
        normalizedValue = unorm.nfkc(v);
      } else if (v is Iterable<String>) {
        normalizedValue = v.map(unorm.nfkc);
      } else {
        normalizedValue = v;
      }
      return MapEntry(unorm.nfkc(k), normalizedValue);
    });
  }

  /// The scheme of this IRI.
  String get scheme => _uri.scheme;

  /// The Unicode-aware host of this IRI.
  ///
  /// If the host was Punycode-encoded (e.g., from a [Uri]), it is decoded back
  /// to its Unicode representation.
  String get host {
    final decoded = Uri.decodeComponent(_uri.host);
    return domainToUnicode(decoded);
  }

  /// The Unicode-aware path of this IRI.
  String get path {
    final decoded = _decodeIriComponent(_uri.path);
    if (scheme == 'mailto') {
      try {
        return emailToUnicode(decoded);
      } on FormatException {
        return decoded;
      }
    }
    return decoded;
  }

  /// The Unicode-aware query of this IRI.
  String get query => _decodeIriComponent(_uri.query);

  /// The Unicode-aware fragment of this IRI.
  String get fragment => _decodeIriComponent(_uri.fragment);

  /// The Unicode-aware user information of this IRI.
  String get userInfo => _decodeIriComponent(_uri.userInfo);

  /// The port of this IRI.
  int get port => _uri.port;

  /// The authority component.
  String get authority => _decodeIriComponent(_uri.authority);

  /// The URI query parameters as a map.
  Map<String, String> get queryParameters => _uri.queryParameters;

  /// The URI query parameters as a map, allowing for multiple values per key.
  ///
  /// The returned map's values are lists of strings.
  Map<String, List<String>> get queryParametersAll => _uri.queryParametersAll;

  /// The URI path segments as an iterable.
  List<String> get pathSegments =>
      _uri.pathSegments.map(_decodeIriComponent).toList();

  /// Resolves [reference] against this IRI.
  ///
  /// The [reference] is normalized to NFKC before being parsed and resolved.
  Iri resolve(String reference) {
    final normalized = unorm.nfkc(reference);
    return Iri.fromUri(_uri.resolve(normalized));
  }

  /// Resolves [reference] against this IRI.
  Iri resolveIri(Iri reference) {
    return Iri.fromUri(_uri.resolveUri(reference._uri));
  }

  /// Creates a new IRI by replacing some of the components of this IRI.
  ///
  /// This mirrors the [Uri.replace] method. All string components are
  /// normalized to NFKC.
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
    return Iri.fromUri(
      _uri.replace(
        scheme: scheme,
        userInfo: userInfo != null ? unorm.nfkc(userInfo) : null,
        host: host != null ? unorm.nfkc(host) : null,
        port: port,
        path: path != null ? unorm.nfkc(path) : null,
        pathSegments: pathSegments?.map(unorm.nfkc),
        query: query != null ? unorm.nfkc(query) : null,
        queryParameters: _normalizeQueryParameters(queryParameters),
        fragment: fragment != null ? unorm.nfkc(fragment) : null,
      ),
    );
  }

  /// Converts this IRI to a standard [Uri].
  ///
  /// Any non-ASCII characters in the hostname are converted to Punycode
  /// according to RFC 3492. Other components are percent-encoded using UTF-8.
  Uri toUri() => _convertedUri;

  Uri _computeUri() {
    if (scheme == 'mailto') {
      final decodedPath = Uri.decodeComponent(_uri.path);
      try {
        final punyEmail = emailToAscii(decodedPath, validate: false);
        return _uri.replace(path: punyEmail);
      } on FormatException {
        return _uri;
      }
    }

    final decodedHost = Uri.decodeComponent(_uri.host);
    if (decodedHost.isEmpty) {
      return _uri;
    }

    final punyHost = domainToAscii(decodedHost, validate: false);
    return _uri.replace(host: punyHost);
  }

  /// Returns the Unicode representation of this IRI.
  @override
  String toString() {
    final sb = StringBuffer();
    if (scheme.isNotEmpty) {
      sb.write(scheme);
      sb.write(':');
    }
    if (_uri.hasAuthority || scheme == 'file') {
      sb.write('//');
      final uinfo = userInfo;
      if (uinfo.isNotEmpty) {
        sb.write(uinfo);
        sb.write('@');
      }
      sb.write(host);
      if (_uri.hasPort) {
        sb.write(':');
        sb.write(port);
      }
    }
    sb.write(path);
    if (_uri.hasQuery) {
      sb.write('?');
      sb.write(query);
    }
    if (_uri.hasFragment) {
      sb.write('#');
      sb.write(fragment);
    }
    return sb.toString();
  }

  /// Returns the percent-encoded URI string representation of this IRI.
  String toUriString() => toUri().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Iri && toUri() == other.toUri());

  @override
  int get hashCode => toUri().hashCode;

  /// Decodes percent-encoded sequences in [text] that represent
  /// valid characters allowed in an IRI but not in a URI (i.e. > U+007F).
  ///
  /// Keeps ASCII percent-encoded sequences (e.g. %20, %2F) as is,
  /// to preserve structure and delimiters.
  static String _decodeIriComponent(String text) {
    if (!text.contains('%')) return text;

    List<int> bytes = utf8.encode(text);
    List<int> resultBytes = [];

    for (int i = 0; i < bytes.length; i++) {
      if (bytes[i] == 0x25) {
        // '%'
        if (i + 2 < bytes.length) {
          // Peek ahead to see how many bytes we can consume as %XX
          List<int> encodedSequence = [];
          int j = i;
          while (j + 2 < bytes.length && bytes[j] == 0x25) {
            int? byteVal = _parseHex(bytes[j + 1], bytes[j + 2]);
            if (byteVal != null) {
              encodedSequence.add(byteVal);
              j += 3;
            } else {
              break;
            }
          }

          if (encodedSequence.isNotEmpty) {
            // Loop through encodedSequence bytes.
            int k = 0;
            while (k < encodedSequence.length) {
              int firstByte = encodedSequence[k];
              if (firstByte < 0x80) {
                // ASCII. Keep as %XX from original source.
                resultBytes.add(0x25); // %
                resultBytes.add(bytes[i + k * 3 + 1]);
                resultBytes.add(bytes[i + k * 3 + 2]);
                k++;
              } else {
                // Start of UTF-8 sequence?
                int charLen = 0;
                if ((firstByte & 0xE0) == 0xC0) {
                  charLen = 2; // 110xxxxx
                } else if ((firstByte & 0xF0) == 0xE0) {
                  charLen = 3; // 1110xxxx
                } else if ((firstByte & 0xF8) == 0xF0) {
                  charLen = 4; // 11110xxx
                } else {
                  // Invalid start byte. Keep encoded.
                  resultBytes.add(0x25);
                  resultBytes.add(bytes[i + k * 3 + 1]);
                  resultBytes.add(bytes[i + k * 3 + 2]);
                  k++;
                  continue;
                }

                if (k + charLen <= encodedSequence.length) {
                  // Verify trailing bytes
                  bool valid = true;
                  for (int m = 1; m < charLen; m++) {
                    if ((encodedSequence[k + m] & 0xC0) != 0x80) valid = false;
                  }
                  if (valid) {
                    try {
                      String ch = utf8.decode(
                        encodedSequence.sublist(k, k + charLen),
                      );
                      resultBytes.addAll(utf8.encode(ch));
                      k += charLen;
                    } catch (_) {
                      // Decode failed, keep encoded
                      for (int m = 0; m < charLen; m++) {
                        resultBytes.add(0x25);
                        resultBytes.add(bytes[i + (k + m) * 3 + 1]);
                        resultBytes.add(bytes[i + (k + m) * 3 + 2]);
                      }
                      k += charLen;
                    }
                  } else {
                    // Invalid sequence, keep encoded
                    resultBytes.add(0x25);
                    resultBytes.add(bytes[i + k * 3 + 1]);
                    resultBytes.add(bytes[i + k * 3 + 2]);
                    k++;
                  }
                } else {
                  // Incomplete sequence, keep encoded
                  resultBytes.add(0x25);
                  resultBytes.add(bytes[i + k * 3 + 1]);
                  resultBytes.add(bytes[i + k * 3 + 2]);
                  k++;
                }
              }
            }

            // Advance main loop by processed length
            i += (j - i) - 1;
            continue;
          }
        }
      }

      resultBytes.add(bytes[i]);
    }

    return utf8.decode(resultBytes);
  }

  static int? _parseHex(int c1, int c2) {
    int dig1 = _hexDigit(c1);
    int dig2 = _hexDigit(c2);
    if (dig1 == -1 || dig2 == -1) return null;
    return (dig1 << 4) | dig2;
  }

  static int _hexDigit(int c) {
    if (c >= 0x30 && c <= 0x39) return c - 0x30;
    if (c >= 0x41 && c <= 0x46) return c - 0x37;
    if (c >= 0x61 && c <= 0x66) return c - 0x57;
    return -1;
  }
}
