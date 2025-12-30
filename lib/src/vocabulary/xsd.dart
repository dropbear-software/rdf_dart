// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import '../model/iri.dart';

/// The XML Schema vocabulary.
class Xsd {
  Xsd._();

  static const String namespace = 'http://www.w3.org/2001/XMLSchema#';

  static final string = Iri('${namespace}string');
  static final boolean = Iri('${namespace}boolean');
  static final decimal = Iri('${namespace}decimal');
  static final integer = Iri('${namespace}integer');
  static final double = Iri('${namespace}double');
  static final float = Iri('${namespace}float');
  static final date = Iri('${namespace}date');
  static final time = Iri('${namespace}time');
  static final dateTime = Iri('${namespace}dateTime');
  static final dateTimeStamp = Iri('${namespace}dateTimeStamp');
  static final gYear = Iri('${namespace}gYear');
  static final gMonth = Iri('${namespace}gMonth');
  static final gDay = Iri('${namespace}gDay');
  static final gYearMonth = Iri('${namespace}gYearMonth');
  static final gMonthDay = Iri('${namespace}gMonthDay');
  static final duration = Iri('${namespace}duration');
  static final yearMonthDuration = Iri('${namespace}yearMonthDuration');
  static final dayTimeDuration = Iri('${namespace}dayTimeDuration');
  static final byte = Iri('${namespace}byte');
  static final short = Iri('${namespace}short');
  static final int = Iri('${namespace}int');
  static final long = Iri('${namespace}long');
  static final unsignedByte = Iri('${namespace}unsignedByte');
  static final unsignedShort = Iri('${namespace}unsignedShort');
  static final unsignedInt = Iri('${namespace}unsignedInt');
  static final unsignedLong = Iri('${namespace}unsignedLong');
  static final positiveInteger = Iri('${namespace}positiveInteger');
  static final nonNegativeInteger = Iri('${namespace}nonNegativeInteger');
  static final negativeInteger = Iri('${namespace}negativeInteger');
  static final nonPositiveInteger = Iri('${namespace}nonPositiveInteger');
  static final hexBinary = Iri('${namespace}hexBinary');
  static final base64Binary = Iri('${namespace}base64Binary');
  static final anyURI = Iri('${namespace}anyURI');
  static final language = Iri('${namespace}language');
  static final normalizedString = Iri('${namespace}normalizedString');
  static final token = Iri('${namespace}token');
  static final NMTOKEN = Iri('${namespace}NMTOKEN');
  static final Name = Iri('${namespace}Name');
  static final NCName = Iri('${namespace}NCName');
}
