// dart2js' secure RNG throws under node.
@TestOn('!node')
library;

import 'dart:convert';

import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

double _chiSquareBase62(String s) {
  final counts = <int, int>{};
  for (final c in s.codeUnits) {
    counts[c] = (counts[c] ?? 0) + 1;
  }
  final expected = s.length / base62.length;
  var chi = 0.0;
  for (final c in base62.codeUnits) {
    final d = (counts[c] ?? 0) - expected;
    chi += d * d / expected;
  }
  return chi;
}

void main() {
  setUp(() => Rand.seed(42));

  group('seed does not affect', () {
    test('seed does not affect password', () {
      Rand.seed(42);
      final a = Rand.password();
      Rand.seed(42);
      final b = Rand.password();
      check(a).not((it) => it.equals(b));
    });

    test('seed does not affect nonce', () {
      Rand.seed(42);
      final a = Rand.nonce();
      Rand.seed(42);
      final b = Rand.nonce();
      check(a).not((it) => it.equals(b));
    });

    test('seed does not affect bytes', () {
      Rand.seed(42);
      final a = Rand.bytes(16);
      Rand.seed(42);
      final b = Rand.bytes(16);
      check(a).not((it) => it.deepEquals(b));
    });

    test('withSeed does not affect nonce', () {
      final a = Rand.withSeed(42, Rand.nonce);
      final b = Rand.withSeed(42, Rand.nonce);
      check(a).not((it) => it.equals(b));
    });

    test('seed does not affect secureCharCode', () {
      Rand.seed(42);
      final a = List.generate(50, (_) => Rand.secureCharCode());
      Rand.seed(42);
      final b = List.generate(50, (_) => Rand.secureCharCode());
      check(a).not((it) => it.deepEquals(b));
    });
  });

  group('Cryptographic', () {
    test('secureCharCode returns base62 character', () {
      for (var i = 0; i < 1000; i++) {
        final cs = Rand.secureCharCode();
        check(base62.contains(String.fromCharCode(cs))).isTrue();
      }
    });

    test('bytes returns correct length', () {
      check(Rand.bytes(0)).length.equals(0);
      check(Rand.bytes(10)).length.equals(10);
      check(Rand.bytes(100)).length.equals(100);
    });

    test('nonce returns correct length', () {
      for (var i = 0; i < 100; i++) {
        final len = Rand.integer(max: 100);
        check(Rand.nonce(length: len)).length.equals(len);
      }
    });

    test('nonce returns base62 characters', () {
      for (var i = 0; i < 50; i++) {
        final n = Rand.nonce(length: 32);
        for (var j = 0; j < n.length; j++) {
          check(base62.contains(n[j])).isTrue();
        }
      }
    });

    test('password returns correct length and respects options', () {
      check(Rand.password()).length.equals(12);
      check(Rand.password(length: 20)).length.equals(20);

      final lower = Rand.password(
        uppercase: false,
        digits: false,
        symbols: false,
      );
      check(lower.toLowerCase()).equals(lower);

      final upper = Rand.password(
        lowercase: false,
        digits: false,
        symbols: false,
      );
      check(upper.toUpperCase()).equals(upper);
    });

    test('password throws on invalid length', () {
      check(() => Rand.password(length: 3)).throws<ArgumentError>();
    });

    test('password guarantees representation of enabled character sets', () {
      const lowercaseSet = 'abcdefghijklmnopqrstuvwxyz';
      const uppercaseSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      const digitsSet = '0123456789';
      const symbolsSet = '!@#\$%^&*()-_=+[]{}\\|;:\'",<.>/?`~';

      for (var i = 0; i < 1000; i++) {
        final p = Rand.password(length: 4);
        var hasLower = false;
        var hasUpper = false;
        var hasDigit = false;
        var hasSymbol = false;
        for (var charIndex = 0; charIndex < p.length; charIndex++) {
          final char = p[charIndex];
          if (lowercaseSet.contains(char)) hasLower = true;
          if (uppercaseSet.contains(char)) hasUpper = true;
          if (digitsSet.contains(char)) hasDigit = true;
          if (symbolsSet.contains(char)) hasSymbol = true;
        }
        check(hasLower).isTrue();
        check(hasUpper).isTrue();
        check(hasDigit).isTrue();
        check(hasSymbol).isTrue();
      }
    });

    test('password reaches every character of all four pools', () {
      final chars = List.generate(
        20000,
        (_) => Rand.password(length: 20),
      ).join().split('').toSet();
      check(chars).length.equals(26 + 26 + 10 + 32);
    });

    test('password throws when all char sets disabled', () {
      check(
        () => Rand.password(
          lowercase: false,
          uppercase: false,
          digits: false,
          symbols: false,
        ),
      ).throws<ArgumentError>();
    });

    test('base64 decodes to byteLength bytes', () {
      for (final len in [1, 16, 32, 64]) {
        final encoded = Rand.base64(byteLength: len);
        check(base64Decode(encoded)).length.equals(len);
      }
    });

    test('base64 throws on non-positive byteLength', () {
      check(() => Rand.base64(byteLength: 0)).throws<ArgumentError>();
    });

    test('seed does not affect base64', () {
      Rand.seed(42);
      final a = Rand.base64();
      Rand.seed(42);
      final b = Rand.base64();
      check(a).not((it) => it.equals(b));
    });

    test('nonce characters are uniform over base62', () {
      final s = List.generate(4000, (_) => Rand.nonce()).join();
      final digits = s.codeUnits.where((c) => c < 58).length;
      final chi = _chiSquareBase62(s);
      printOnFailure('digit share ${digits / s.length}, chi2 $chi');
      check(digits / s.length).isCloseTo(10 / 62, 0.012);
      check(chi).isLessThan(200);
    });
  });
}
