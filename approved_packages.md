# Approved Packages

Note: All approved packages are ALREADY added to the project's pubspec.yaml file. However, if you wish to add any others, please note that any from the official Google or Dart teams are pre-approved. Everything else must be approved by the project maintainers.

## IRI
- The IRI package is approved for use in this project and is used to provide an implementation of [RFC3987](https://www.rfc-editor.org/rfc/rfc3987).
- Below is a short Dart code snippet showing you how to use it

```dart
import 'package:iri/iri.dart';

void main() {
  // 1. Create an IRI from a string containing non-ASCII characters.
  //    例子 means "example" in Chinese.
  //    The path contains 'ȧ' (U+0227 LATIN SMALL LETTER A WITH DOT ABOVE).
  final iri = IRI('https://例子.com/pȧth?q=1');

  // 2. Print the original IRI string representation.
  print('Original IRI: $iri');
  // Output: Original IRI: https://例子.com/pȧth?q=1

  // 3. Convert the IRI to its standard URI representation.
  //    - The host (例子.com) is converted to Punycode (xn--fsqu00a.com).
  //    - The non-ASCII path character 'ȧ' (UTF-8 bytes C8 A7) is percent-encoded (%C8%A7).
  final uri = iri.toUri();
  print('Converted URI: $uri');
  // Output: Converted URI: https://xn--fsqu00a.com/p%C8%A7th?q=1

  // 4. Access components (values are decoded for IRI representation).
  print('Scheme: ${iri.scheme}');       // Output: Scheme: https
  print('Host: ${iri.host}');           // Output: Host: 例子.com
  print('Path: ${iri.path}');           // Output: Path: /pȧth
  print('Query: ${iri.query}');         // Output: Query: q=1

  // 5. Compare IRIs
  final iri2 = IRI('https://例子.com/pȧth?q=1');
  print('IRIs equal: ${iri == iri2}'); // Output: IRIs equal: true

  final iri3 = IRI('https://example.com/');
  print('IRIs equal: ${iri == iri3}'); // Output: IRIs equal: false
}
```

## xsd
- The `xsd` package is a Dart library for working with XML Schema Datatypes (XSD) as defined by the W3C. This library provides Dart representations for XSD types and codecs to convert between their lexical (string) forms and their Dart object representations.
- This library aims to:
    - Provide faithful Dart representations for common XSD built-in datatypes.
    - Offer dart:convert style Codec instances for each supported XSD type, allowing for easy encoding (Dart object to XSD string) and decoding (XSD string to Dart object).
    - Handle XSD whitespace processing rules (preserve, replace, collapse) correctly.
    - Validate lexical forms against the rules of the specific XSD datatype.
    - Implement the value space constraints (e.g., ranges for numeric types) defined for each built-in XSD type.

### Supported XSD Datatypes

This library aims to support the following XSD 1.1 built-in datatypes that are commonly used in RDF and general XML processing:

| **XSD Data Type**          | **Planned** | **Implemented** | **Dart Data Type** | **Implementation Source** |
|------------------------|-------------|-----------------|----------------|------------|
|          `xsd:boolean` |      ✅      |        ✅        |     `bool`     |     `dart:core`    |
|           `xsd:string` |      ✅      |        ✅        |    `String`    |     `dart:core`    |
| `xsd:normalizedString` |      ✅      |        ✅        |    `String`    |     `dart:core`    |
|            `xsd:token` |      ✅      |        ✅        |    `String`    |     `dart:core`    |
|          `xsd:NMTOKEN` |      ✅      |        ✅        |    `String`    |     `dart:core`    |
|             `xsd:Name` |      ✅      |        ✅        |    `String`    |     `dart:core`    |
|         `xsd:language` |      ✅      |        ✅        |    `Locale`    |     `package:intl`    |
|           `xsd:NCName` |      ✅      |        ✅        |    `String`    |     `dart:core`    |
|          `xsd:decimal` |      ✅      |        ✅        |    `Decimal`    |     `package:decimal`    |
|           `xsd:double` |      ✅      |        ✅        |    `double`    |     `dart:core`    |
|            `xsd:float` |      ✅      |        ✅        |    `double`    |     `dart:core`    |
|          `xsd:integer` |      ✅      |        ✅        |    `BigInt`    |     `dart:core`    |
| `xsd:nonPositiveInteger` |      ✅      |        ✅        |    `BigInt`    |     `dart:core`    |
| `xsd:negativeInteger` |      ✅      |        ✅        |    `BigInt`    |     `dart:core`    |
| `xsd:long` |      ✅      |        ✅        |    `BigInt`    |     `dart:core`    |
| `xsd:int` |      ✅      |        ✅        |    `int`    |     `dart:core`    |
| `xsd:short` |      ✅      |        ✅        |    `int`    |     `dart:core`    |
| `xsd:byte` |      ✅      |        ✅        |    `int`    |     `dart:core`    |
| `xsd:nonNegativeInteger` |      ✅      |        ✅        |    `BigInt`    |     `dart:core`    |
| `xsd:positiveInteger` |      ✅      |        ✅        |    `BigInt`    |     `dart:core`    |
| `xsd:unsignedLong` |      ✅      |        ✅        |    `BigInt`    |     `dart:core`    |
| `xsd:unsignedInt` |      ✅      |        ✅        |    `int`    |     `dart:core`    |
| `xsd:unsignedShort` |      ✅      |        ✅        |    `int`    |     `dart:core`    |
| `xsd:unsignedByte` |      ✅      |        ✅        |    `int`    |     `dart:core`    |
| `xsd:anyURI` |      ✅      |        ✅        |    `Uri`    |     `dart:core`    |
| `xsd:hexBinary` |      ✅      |        ✅        |    `Uint8List`    |     `dart:typed_data`    |
| `xsd:base64Binary` |      ✅      |        ✅        |    `Uint8List`    |     `dart:typed_data`    |
| `xsd:duration` |      ✅      |        ✅        |    `XsdDuration`[1]    |     `package:xsd`    |
| `xsd:yearMonthDuration` |      ✅      |        ❌        |    ???    |     ???    |
| `xsd:dayTimeDuration` |      ✅      |        ❌        |    ???    |     ???    |
| `xsd:dateTime` |      ✅      |        ✅        |    `XsdDateTime`[2]    |     `package:xsd`    |
| `xsd:dateTimeStamp` |      ✅      |        ❌        |    ???    |     ???    |
| `xsd:date` |      ✅      |        ✅        |    `XsdDate`    |     `package:xsd`    |
| `xsd:time` |      ✅      |        ❌        |    ???    |     ???    |
| `xsd:gYearMonth` |      ✅      |        ✅        |    `YearMonth`    |     `package:xsd`    |
| `xsd:gYear` |      ✅      |        ✅        |    `GregorianYear`    |     `package:xsd`    |
| `xsd:gMonthDay` |      ✅      |        ✅        |    `GregorianMonthDay`    |     `package:xsd`    |
| `xsd:gDay` |      ✅      |        ✅        |    `GregorianDay`    |     `package:xsd`    |
| `xsd:gMonth` |      ✅      |        ✅        |    `GregorianMonth`    |     `package:xsd`    |
| `xsd:QName` |      ❌      |        ❌        |    ❌    |     ❌    |
| `xsd:NOTATION` |      ❌      |        ❌        |    ❌    |     ❌    |
| `xsd:ID` |      ❌      |        ❌        |    ❌    |     ❌    |
| `xsd:IDREF` |      ❌      |        ❌        |    ❌    |     ❌    |
| `xsd:ENTITY` |      ❌      |        ❌        |    ❌    |     ❌    |
| `xsd:ENTITIES` |      ❌      |        ❌        |    ❌    |     ❌    |
| `xsd:NMTOKENS` |      ❌      |        ❌        |    ❌    |     ❌    |

[1] **Note:** Although Dart already has a `Duration` class it actually represents an entirely different concept to the ISO8600 / XSD idea of a duration which `XsdDuration` implements.

[2] **Note:** Dart's native `DateTime` class doesn't preserve the original timezone offset from a parsed string, which is important for round-tripping `xsd:dateTime` values. This wrapper class stores the original offset to address this.

### Limitations

* **Facets on Built-in Types**: This library focuses on implementing the XSD built-in datatypes as they are defined in the "XML Schema Part 2: Datatypes" specification. This includes their inherent properties, lexical spaces, value spaces, and any *fixed* facets that define them (e.g., the range of `xsd:byte` or the `whiteSpace` behavior of `xsd:token`).
* The library currently **does not** provide a mechanism to dynamically apply arbitrary constraining facets (like `minLength`, `maxLength`, `pattern`, `enumeration`, `totalDigits`, `fractionDigits` beyond what defines a base type) to create new, user-defined derived simple types *at runtime through the codec*. For instance, while `xsd:string` is supported, you cannot pass `maxLength="5"` to the `XsdStringCodec` to validate against this specific restriction dynamically. Such validation would typically be handled by a higher-level XSD schema processor that uses this library for the base datatype conversions.

### Usage

```dart
import 'package:xsd/xsd.dart';

final boolCodec = XsdBooleanCodec();
bool myBool = boolCodec.decode('1'); // true
String boolStr = boolCodec.encode(false); // "false"

final intCodec = XsdIntCodec();
int myInt = intCodec.decode('  -123  '); // -123
String intStr = intCodec.encode(456); // "456"
```

## intl
- The intl package from the Dart team provides some helpful utilities for working with bi-directional text which may be useful when processing RDF `langDirString` data types.

Specific classes include `Bidi` class which provides utility methods for working with bidirectional text. All of the methods are static, and are organized into a class primarily to group them together for documentation and discoverability.

Static Methods of note on the `Bidi` class include:
- `detectRtlDirectionality(String str, {bool isHtml = false}) → bool`
Check the estimated directionality of str, return true if the piece of text should be laid out in RTL direction. If isHtml is true, the string is HTML or HTML-escaped.
- `endsWithLtr(String text, [bool isHtml = false]) → bool`
Determines if the exit directionality (ie, the last strongly-directional character in text is LTR. If isHtml is true, the text is HTML or HTML-escaped.
- `endsWithRtl(String text, [bool isHtml = false]) → bool`
Determines if the exit directionality (ie, the last strongly-directional character in text is RTL. If isHtml is true, the text is HTML or HTML-escaped.
- `enforceLtrInHtml(String html) → String`
Enforce the html snippet in LTR directionality regardless of overall context. If the html piece was enclosed by a tag, the direction will be applied to existing tag, - otherwise a span tag will be added as wrapper. For this reason, if html snippet start with with tag, this tag must enclose the whole piece. If the tag already has a direction specified, this new one will override existing one in behavior (tested on FF and IE).
- `enforceLtrInText(String text) → String`
Enforce LTR on both end of the given text using unicode BiDi formatting characters LRE and PDF.
- `enforceRtlInHtml(String html) → String`
Enforce the html snippet in RTL directionality regardless of overall context. If the html piece was enclosed by a tag, the direction will be applied to existing tag, otherwise a span tag will be added as wrapper. For this reason, if html snippet start with with tag, this tag must enclose the whole piece. If the tag already has a direction specified, this new one will override existing one in behavior (should work on Chrome, FF, and IE since this was ported directly from the Closure version).
- `enforceRtlInText(String text) → String`
Enforce RTL on both end of the given text using unicode BiDi formatting characters RLE and PDF.
- `estimateDirectionOfText(String text, {bool isHtml = false}) → TextDirection`
Estimates the directionality of text using the best known general-purpose method (using relative word counts). A TextDirection.UNKNOWN return value indicates completely neutral input. isHtml is true if text HTML or HTML-escaped.
- `hasAnyLtr(String text, [bool isHtml = false]) → bool`
Determines if the given text has any LTR characters in it. If isHtml is true, the text is HTML or HTML-escaped.
- `hasAnyRtl(String text, [bool isHtml = false]) → bool`
Determines if the given text has any RTL characters in it. If isHtml is true, the text is HTML or HTML-escaped.
- `isRtlLanguage([String? languageString]) → bool`
Check if a BCP 47 / III languageString indicates an RTL language.
- `normalizeHebrewQuote(String str) → String`
Replace the double and single quote directly after a Hebrew character in str with GERESH and GERSHAYIM. This is most likely the user's intention.
- `startsWithLtr(String text, [bool isHtml = false]) → bool`
Determines if the first character in text with strong directionality is LTR. If isHtml is true, the text is HTML or HTML-escaped.
- `startsWithRtl(String text, [bool isHtml = false]) → bool`
Determines if the first character in text with strong directionality is RTL. If isHtml is true, the text is HTML or HTML-escaped.
- `stripHtmlIfNeeded(String text) → String`
Returns the input text with spaces instead of HTML tags or HTML escapes, which is helpful for text directionality estimation. Note: This function should not be used in other contexts. It does not deal well with many things: comments, script, elements, style elements, dir attribute,> in quoted attribute values, etc. But it does handle well enough the most common use cases. Since the worst that can happen as a result of these shortcomings is that the wrong directionality will be estimated, we have not invested in improving this.

- The package also provides a `Locale` class which is A representation of a `Unicode Locale Identifier`.
- To create Locale instances, consider using:
    - `fromSubtags` for language, script and region,
    - `parse` for Unicode Locale Identifier strings (throws exceptions on failure),
    - `tryParse` for Unicode Locale Identifier strings (returns null on failure).
- It also include a helpful `toLanguageTag() → String` which returns the canonical Unicode `BCP47` Locale Identifier for this locale.
