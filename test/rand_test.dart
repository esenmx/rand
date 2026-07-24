import 'dart:convert';
import 'dart:math';

import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

enum _TestEnum { alpha, beta, gamma, delta }

void main() {
  setUp(() => Rand.seed(42));

  group('useRng / seed', () {
    test('same seed produces same sequence', () {
      Rand.seed(42);
      final a = List.generate(100, (_) => Rand.integer(max: 1 << 20));
      Rand.seed(42);
      final b = List.generate(100, (_) => Rand.integer(max: 1 << 20));
      check(a).deepEquals(b);
    });

    test('different seeds produce different sequences', () {
      Rand.seed(42);
      final a = List.generate(100, (_) => Rand.integer(max: 1 << 20));
      Rand.seed(43);
      final b = List.generate(100, (_) => Rand.integer(max: 1 << 20));
      check(a).not((it) => it.deepEquals(b));
    });

    test('useRng(Random(N)) is observably equivalent to seed(N)', () {
      Rand.seed(42);
      final a = List.generate(50, (_) => Rand.integer(max: 1 << 20));
      Rand.useRng(Random(42));
      final b = List.generate(50, (_) => Rand.integer(max: 1 << 20));
      check(a).deepEquals(b);
    });

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

    test('seed does not affect secureCharCode', () {
      Rand.seed(42);
      final a = List.generate(50, (_) => Rand.secureCharCode());
      Rand.seed(42);
      final b = List.generate(50, (_) => Rand.secureCharCode());
      check(a).not((it) => it.deepEquals(b));
    });
  });

  group('Boolean & Nullable', () {
    test('boolean returns true/false based on probability', () {
      var trueCount = 0;
      var falseCount = 0;
      for (var i = 0; i < 10000; i++) {
        if (Rand.boolean(99)) trueCount++;
        if (!Rand.boolean(1)) falseCount++;
      }
      check(trueCount).isGreaterThan(9700);
      check(falseCount).isGreaterThan(9700);
    });

    test('boolean throws on invalid probability', () {
      check(() => Rand.boolean(-1)).throws<ArgumentError>();
      check(() => Rand.boolean(101)).throws<ArgumentError>();
    });

    test('boolean respects double-precision probabilities', () {
      var trueCount = 0;
      for (var i = 0; i < 10000; i++) {
        if (Rand.boolean(0.1)) trueCount++;
      }
      check(trueCount).isLessThan(50);
    });

    test('nullable returns value or null based on probability', () {
      var nullCount = 0;
      for (var i = 0; i < 1000; i++) {
        if (Rand.nullable('value') == null) nullCount++;
      }
      check(nullCount).isGreaterThan(400);
      check(nullCount).isLessThan(600);
    });
  });

  group('Numbers', () {
    test('integer returns value in range', () {
      check(Rand.integer(min: 5, max: 5)).equals(5);
      check(Rand.integer()).isA<int>();
      check(Rand.integer(max: 1)).isA<int>();
      check(Rand.integer(min: 1, max: 2)).isA<int>();
      check(Rand.integer(min: -1, max: 1)).isA<int>();
    });

    test('integer is uniform over its range', () {
      Rand.seed(42);
      final histogram = List.filled(10, 0);
      for (var i = 0; i < 100000; i++) {
        histogram[Rand.integer(max: 9)]++;
      }
      for (final count in histogram) {
        check(count).isGreaterOrEqual(9000);
        check(count).isLessOrEqual(11000);
      }
    });

    test('integer throws on invalid range', () {
      check(() => Rand.integer(min: 2, max: 1)).throws<ArgumentError>();
    });

    test('float returns value in [min, max)', () {
      for (var i = 0; i < 100; i++) {
        final f = Rand.float(min: 10, max: 20);
        check(f).isGreaterOrEqual(10);
        check(f).isLessThan(20);
      }
    });

    test('float handles extremely wide ranges without overflow', () {
      final f = Rand.float(
        min: -double.maxFinite / 2,
        max: double.maxFinite / 2,
      );
      check(f.isInfinite).isFalse();
      check(f.isNaN).isFalse();

      final f2 = Rand.float(min: -double.maxFinite);
      check(f2.isInfinite).isFalse();
      check(f2.isNaN).isFalse();
    });

    test('float throws on invalid range', () {
      check(() => Rand.float(min: 20, max: 10)).throws<ArgumentError>();
    });

    test('latitude returns valid range', () {
      for (var i = 0; i < 100; i++) {
        final lat = Rand.latitude();
        check(lat).isGreaterOrEqual(-90);
        check(lat).isLessOrEqual(90);
      }
    });

    test('longitude returns valid range', () {
      for (var i = 0; i < 100; i++) {
        final lng = Rand.longitude();
        check(lng).isGreaterOrEqual(-180);
        check(lng).isLessOrEqual(180);
      }
    });

    test('geoPoint returns record in valid lat/lng range', () {
      for (var i = 0; i < 100; i++) {
        final (:lat, :lng) = Rand.geoPoint();
        check(lat).isGreaterOrEqual(-90);
        check(lat).isLessOrEqual(90);
        check(lng).isGreaterOrEqual(-180);
        check(lng).isLessOrEqual(180);
      }
    });

    test('charCode returns base62 character', () {
      for (var i = 0; i < 1000; i++) {
        final c = Rand.charCode();
        check(base62.contains(String.fromCharCode(c))).isTrue();
        final cs = Rand.secureCharCode();
        check(base62.contains(String.fromCharCode(cs))).isTrue();
      }
    });

    test('bytes returns correct length', () {
      check(Rand.bytes(0)).length.equals(0);
      check(Rand.bytes(10)).length.equals(10);
      check(Rand.bytes(100)).length.equals(100);
    });

    test('semver returns dotted triple within bounds', () {
      final pattern = RegExp(r'^(\d+)\.(\d+)\.(\d+)$');
      for (var i = 0; i < 100; i++) {
        final v = Rand.semver(maxMajor: 3, maxMinor: 4, maxPatch: 5);
        final m = pattern.firstMatch(v);
        check(m).isNotNull();
        check(int.parse(m!.group(1)!)).isLessOrEqual(3);
        check(int.parse(m.group(2)!)).isLessOrEqual(4);
        check(int.parse(m.group(3)!)).isLessOrEqual(5);
      }
    });

    test('otp returns digit string of requested length', () {
      const digits = '0123456789';
      for (final len in [1, 6, 12]) {
        final code = Rand.otp(length: len);
        check(code).length.equals(len);
        for (var i = 0; i < code.length; i++) {
          check(digits.contains(code[i])).isTrue();
        }
      }
    });

    test('otp throws on non-positive length', () {
      check(() => Rand.otp(length: 0)).throws<ArgumentError>();
      check(() => Rand.otp(length: -3)).throws<ArgumentError>();
    });

    test('otp is reproducible under seed', () {
      Rand.seed(42);
      final a = List.generate(20, (_) => Rand.otp());
      Rand.seed(42);
      final b = List.generate(20, (_) => Rand.otp());
      check(a).deepEquals(b);
    });
  });

  group('Cryptographic', () {
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
  });

  group('Time', () {
    final minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
    final maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

    test('duration returns value in [min, max)', () {
      const max = Duration(days: 30);
      const min = Duration(days: 1);
      for (var i = 0; i < 100; i++) {
        final d = Rand.duration(min: min, max: max);
        check(d.inMicroseconds).isGreaterOrEqual(min.inMicroseconds);
        check(d.inMicroseconds).isLessThan(max.inMicroseconds);
      }
    });

    test('dateTime returns value in default range', () {
      for (var i = 0; i < 100; i++) {
        final dt = Rand.dateTime();
        check(dt.microsecondsSinceEpoch).isGreaterOrEqual(minEpoch);
        check(dt.microsecondsSinceEpoch).isLessThan(maxEpoch);
        check(dt.isUtc).isTrue();
      }
    });
  });

  group('Collections', () {
    test('element returns item from collection', () {
      final list = [1, 2, 3, 4, 5];
      for (var i = 0; i < 100; i++) {
        check(list.contains(Rand.element(list))).isTrue();
      }
    });

    test('element throws StateError on empty', () {
      check(() => Rand.element(<int>[])).throws<StateError>();
    });

    test('mapEntry returns entry from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        final entry = Rand.mapEntry(map);
        check(map.containsKey(entry.key)).isTrue();
        check(map[entry.key]).equals(entry.value);
      }
    });

    test('mapKey returns key from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        check(map.containsKey(Rand.mapKey(map))).isTrue();
      }
    });

    test('mapValue returns value from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        check(map.containsValue(Rand.mapValue(map))).isTrue();
      }
    });

    test('subSet returns unique elements', () {
      check(Rand.subSet(<int>{}, 0)).isEmpty();

      final pool = List.generate(100, (i) => i).toSet();
      check(Rand.subSet(pool, 100)).length.equals(100);
      check(Rand.subSet(pool, 50)).length.equals(50);
    });

    test('subSet throws when count exceeds set size', () {
      check(() => Rand.subSet({1, 2}, 3)).throws<RangeError>();
    });

    test('enumValue returns a member of the enum', () {
      for (var i = 0; i < 50; i++) {
        check(_TestEnum.values.contains(Rand.enumValue(_TestEnum.values)))
            .isTrue();
      }
    });

    test('shuffled returns same elements in a different order', () {
      final input = List.generate(50, (i) => i);
      final out = Rand.shuffled(input);
      check(out).length.equals(input.length);
      check(out.toSet()).deepEquals(input.toSet());
      check(out).not((it) => it.deepEquals(input));
    });

    test('shuffled does not mutate input', () {
      final input = [1, 2, 3, 4, 5];
      final snapshot = List<int>.of(input);
      Rand.shuffled(input);
      check(input).deepEquals(snapshot);
    });

    test('shuffled is reproducible under seed', () {
      Rand.seed(42);
      final a = Rand.shuffled(List.generate(20, (i) => i));
      Rand.seed(42);
      final b = Rand.shuffled(List.generate(20, (i) => i));
      check(a).deepEquals(b);
    });
  });

  group('Text', () {
    test('alias returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.alias()).isNotEmpty();
      }
    });

    test('firstName returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.firstName()).isNotEmpty();
      }
    });

    test('lastName returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.lastName()).isNotEmpty();
      }
    });

    test('fullName contains at least first and last name', () {
      for (var i = 0; i < 10; i++) {
        final name = Rand.fullName();
        check(name).isNotEmpty();
        check(name.split(' ').length).isGreaterOrEqual(2);
      }
    });

    test('word returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.word()).isNotEmpty();
      }
    });

    test('words returns correct count', () {
      check(Rand.words(count: 5).split(' ')).length.equals(5);
      check(Rand.words(count: 10, separator: '-').split('-')).length.equals(10);
    });

    test('sentence returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.sentence()).isNotEmpty();
      }
    });

    test('paragraph returns multiple sentences', () {
      final p = Rand.paragraph(5);
      check(p).isNotEmpty();
      check(p.split('. ').length).isGreaterOrEqual(5);
    });

    test('article returns multiple paragraphs', () {
      final a = Rand.article(3);
      check(a).isNotEmpty();
      check(a.split('\n\n').length).isGreaterOrEqual(3);
    });

    test('slug returns wordCount unique words joined by separator', () {
      for (final wc in [1, 3, 5]) {
        final s = Rand.slug(wordCount: wc);
        final parts = s.split('-');
        check(parts.length).equals(wc);
        check(parts.toSet().length).equals(wc);
      }
      check(Rand.slug(separator: '_').split('_')).length.equals(3);
    });

    test('slug throws on non-positive wordCount', () {
      check(() => Rand.slug(wordCount: 0)).throws<ArgumentError>();
    });
  });

  group('Miscellaneous', () {
    test('city returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.city()).isNotEmpty();
      }
    });

    test('color returns valid CssColors', () {
      for (var i = 0; i < 10; i++) {
        check(CssColors.values.contains(Rand.color())).isTrue();
      }
    });

    test('colorDark returns only dark colors', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.colorDark().isDark).isTrue();
      }
    });

    test('colorLight returns only light colors', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.colorLight().isDark).isFalse();
      }
    });

    test('CssColors exposes argb', () {
      check(CssColors.coral.argb).equals(0xFFFF7F50);
      check(CssColors.aliceBlue.argb).equals(0xFFF0F8FF);
    });

    test('CssColorsX.isDark classifies extremes correctly', () {
      check(CssColors.black.isDark).isTrue();
      check(CssColors.white.isDark).isFalse();
      check(CssColors.navy.isDark).isTrue();
      check(CssColors.ivory.isDark).isFalse();
    });
  });

  group('Networking', () {
    test('email contains @ and a domain', () {
      final ipv4Pattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
      for (var i = 0; i < 50; i++) {
        final e = Rand.email();
        check(e.contains('@')).isTrue();
        final parts = e.split('@');
        check(parts.length).equals(2);
        check(parts[0]).isNotEmpty();
        check(parts[1]).isNotEmpty();
        check(ipv4Pattern.hasMatch(parts[1])).isFalse();
      }
    });

    test('email honors explicit domain', () {
      for (var i = 0; i < 20; i++) {
        check(Rand.email(domain: 'mycompany.io')).endsWith('@mycompany.io');
      }
    });

    test('ipv4 is dotted quad with each octet in 0..255', () {
      final pattern = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
      for (var i = 0; i < 200; i++) {
        final ip = Rand.ipv4();
        final m = pattern.firstMatch(ip);
        check(m).isNotNull();
        for (var g = 1; g <= 4; g++) {
          final octet = int.parse(m!.group(g)!);
          check(octet).isGreaterOrEqual(0);
          check(octet).isLessOrEqual(255);
        }
      }
    });

    test('ipv6 is 8 groups of 4 lowercase hex chars', () {
      final pattern = RegExp(r'^([0-9a-f]{4}:){7}[0-9a-f]{4}$');
      for (var i = 0; i < 100; i++) {
        check(pattern.hasMatch(Rand.ipv6())).isTrue();
      }
    });

    test('mac is 6 hex bytes with configurable separator', () {
      final colon = RegExp(r'^([0-9a-f]{2}:){5}[0-9a-f]{2}$');
      final dash = RegExp(r'^([0-9a-f]{2}-){5}[0-9a-f]{2}$');
      for (var i = 0; i < 50; i++) {
        check(colon.hasMatch(Rand.mac())).isTrue();
        check(dash.hasMatch(Rand.mac(separator: '-'))).isTrue();
      }
    });

    test('hex returns lowercase hex of requested length', () {
      const hexPool = '0123456789abcdef';
      for (final len in [1, 8, 40, 64, 128]) {
        final h = Rand.hex(length: len);
        check(h).length.equals(len);
        for (var i = 0; i < h.length; i++) {
          check(hexPool.contains(h[i])).isTrue();
        }
      }
    });

    test('hex throws on non-positive length', () {
      check(() => Rand.hex(length: 0)).throws<ArgumentError>();
      check(() => Rand.hex(length: -1)).throws<ArgumentError>();
    });

    test('hex is reproducible under seed', () {
      Rand.seed(42);
      final a = List.generate(20, (_) => Rand.hex(length: 16));
      Rand.seed(42);
      final b = List.generate(20, (_) => Rand.hex(length: 16));
      check(a).deepEquals(b);
    });
  });

  group('Sampling', () {
    test('sample without weights uses equal probability', () {
      final result = Rand.sample(from: [1, 2, 3], count: 100);
      check(result).length.equals(100);
      check(result.every((e) => [1, 2, 3].contains(e))).isTrue();
    });

    test('sample with weights respects ratios', () {
      Rand.seed(42);
      final result = Rand.sample(
        from: ['a', 'b', 'c'],
        count: 100000,
        weights: [1, 10, 100],
      );
      final a = result.where((e) => e == 'a').length;
      final b = result.where((e) => e == 'b').length;
      final c = result.where((e) => e == 'c').length;
      // 1:10:100 → a ≈ 900, b ≈ 9009, c ≈ 90090. Wide tolerance.
      check(a).isLessThan(b);
      check(b).isLessThan(c);
      check(a / b).isGreaterOrEqual(0.05);
      check(a / b).isLessOrEqual(0.20);
      check(b / c).isGreaterOrEqual(0.05);
      check(b / c).isLessOrEqual(0.20);
    });

    test('sample handles empty inputs', () {
      check(Rand.sample(from: <int>[], count: 10)).isEmpty();
      check(Rand.sample(from: [1], count: 0)).isEmpty();
    });

    test('sample throws on mismatched weights length', () {
      check(() => Rand.sample(from: [1, 2], count: 1, weights: [1]))
          .throws<ArgumentError>();
    });
  });
}
