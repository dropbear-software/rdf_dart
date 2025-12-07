/// An Internationalized Resource Identifier (IRI) as defined by [RFC 3987](https://tools.ietf.org/html/rfc3987).
///
/// This class provides an implementation of IRI that wraps Dart's native [Uri] class.
/// It handles the conversion between percent-encoded URI components and their
/// Unicode IRI counterparts.
library;

import 'dart:convert';

/// An Internationalized Resource Identifier (IRI).
///
/// Wraps a [Uri] and provides IRI-compliant accessors that decode
/// percent-encoded UTF-8 sequences back into Unicode characters, while
/// preserving percent-encoded reserved characters.
class Iri implements Uri {
  final Uri _uri;

  /// Creates a new [Iri] from the given [uri].
  const Iri.fromUri(this._uri);

  /// Parsers [value] as an IRI.
  ///
  /// This uses [Uri.parse] internally, relying on its ability to handle
  /// and encode non-ASCII characters.
  static Iri parse(String value) {
    return Iri.fromUri(Uri.parse(value));
  }

  /// Returns the underlying [Uri] with percent-encoded components.
  Uri toPercentEncodedUri() => _uri;

  /// Creates a new [Iri] from its components.
  ///
  /// Delegates to [Uri] constructor.
  factory Iri({
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
      Uri(
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
  String get scheme => _uri.scheme;

  @override
  String get authority => _decodeIriComponent(_uri.authority);

  @override
  String get userInfo => _decodeIriComponent(_uri.userInfo);

  @override
  String get host => _decodeIriComponent(_uri.host);

  @override
  int get port => _uri.port;

  @override
  String get path => _decodeIriComponent(_uri.path);

  @override
  String get query => _decodeIriComponent(_uri.query);

  @override
  String get fragment => _decodeIriComponent(_uri.fragment);

  @override
  List<String> get pathSegments =>
      _uri.pathSegments.map(_decodeIriComponent).toList();

  @override
  Map<String, String> get queryParameters => _uri.queryParameters.map(
    (k, v) => MapEntry(_decodeIriComponent(k), _decodeIriComponent(v)),
  );

  @override
  Map<String, List<String>> get queryParametersAll =>
      _uri.queryParametersAll.map(
        (k, v) => MapEntry(
          _decodeIriComponent(k),
          v.map(_decodeIriComponent).toList(),
        ),
      );

  @override
  bool get isAbsolute => _uri.isAbsolute;

  @override
  bool get hasScheme => _uri.hasScheme;

  @override
  bool get hasAuthority => _uri.hasAuthority;

  @override
  bool get hasPort => _uri.hasPort;

  @override
  bool get hasQuery => _uri.hasQuery;

  @override
  bool get hasFragment => _uri.hasFragment;

  @override
  bool get hasEmptyPath => _uri.hasEmptyPath;

  @override
  bool get hasAbsolutePath => _uri.hasAbsolutePath;

  @override
  String get origin => _decodeIriComponent(_uri.origin);

  @override
  bool isScheme(String scheme) => _uri.isScheme(scheme);

  @override
  String toFilePath({bool? windows}) => _uri.toFilePath(windows: windows);

  @override
  UriData? get data => _uri.data;

  @override
  int get hashCode => _uri.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Iri) return _uri == other._uri;
    if (other is Uri) return _uri == other;
    return false;
  }

  @override
  String toString() => _decodeIriComponent(_uri.toString());

  @override
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
  Iri removeFragment() => Iri.fromUri(_uri.removeFragment());

  @override
  Iri resolve(String reference) => Iri.fromUri(_uri.resolve(reference));

  @override
  Iri resolveUri(Uri reference) => Iri.fromUri(_uri.resolveUri(reference));

  @override
  Iri normalizePath() => Iri.fromUri(_uri.normalizePath());

  /// Decodes percent-encoded sequences in [text] that represent
  /// valid characters allowed in an IRI but not in a URI (i.e. > U+007F).
  ///
  /// Keeps ASCII percent-encoded sequences (e.g. %20, %2F) as is,
  /// to preserve structure and delimiters.
  String _decodeIriComponent(String text) {
    if (!text.contains('%')) return text;

    // We iterate through the string and decode sequences of %XX
    // If the sequence decodes to a byte > 127, we collect it.
    // We need to handle multi-byte UTF-8 sequences.

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

  int? _parseHex(int c1, int c2) {
    int dig1 = _hexDigit(c1);
    int dig2 = _hexDigit(c2);
    if (dig1 == -1 || dig2 == -1) return null;
    return (dig1 << 4) | dig2;
  }

  int _hexDigit(int c) {
    if (c >= 0x30 && c <= 0x39) return c - 0x30;
    if (c >= 0x41 && c <= 0x46) return c - 0x37;
    if (c >= 0x61 && c <= 0x66) return c - 0x57;
    return -1;
  }
}
