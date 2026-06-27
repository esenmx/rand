part of '../rand.dart';

const List<String> _domains = [
  'example.com',
  'example.org',
  'example.net',
  'test.com',
  'mail.test',
  'demo.dev',
  'sample.app',
  'fake.io',
];

const String _hexChars = '0123456789abcdef';

mixin _Networking on _Numbers, _Collections, _Identity {
  String email({String? domain}) {
    final user = '${firstName().toLowerCase()}${integer(min: 1, max: 99)}';
    return '$user@${domain ?? element(_domains)}';
  }

  String ipv4() {
    return '${integer(max: 255)}.${integer(max: 255)}.'
        '${integer(max: 255)}.${integer(max: 255)}';
  }

  String ipv6() {
    final codes = Uint16List(39); // 8 * 4 + 7 * 1 = 39 characters
    var j = 0;
    for (var i = 0; i < 8; i++) {
      if (i > 0) {
        codes[j++] = 58; // ':'
      }
      codes[j++] = _hexChars.codeUnitAt(rng.nextInt(16));
      codes[j++] = _hexChars.codeUnitAt(rng.nextInt(16));
      codes[j++] = _hexChars.codeUnitAt(rng.nextInt(16));
      codes[j++] = _hexChars.codeUnitAt(rng.nextInt(16));
    }
    return String.fromCharCodes(codes);
  }

  String mac({String separator = ':'}) {
    final totalLen = separator.isEmpty ? 12 : 12 + 5 * separator.length;
    final codes = Uint16List(totalLen);
    var j = 0;
    for (var i = 0; i < 6; i++) {
      if (i > 0 && separator.isNotEmpty) {
        for (var k = 0; k < separator.length; k++) {
          codes[j++] = separator.codeUnitAt(k);
        }
      }
      codes[j++] = _hexChars.codeUnitAt(rng.nextInt(16));
      codes[j++] = _hexChars.codeUnitAt(rng.nextInt(16));
    }
    return String.fromCharCodes(codes);
  }

  String hex({int length = 8}) {
    if (length < 1) {
      throw ArgumentError('length must be >= 1, got $length');
    }
    final codes = Uint16List(length);
    for (var i = 0; i < length; i++) {
      codes[i] = _hexChars.codeUnitAt(rng.nextInt(16));
    }
    return String.fromCharCodes(codes);
  }
}
