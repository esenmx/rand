import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

final _semverOrg = RegExp(
  r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
  r'(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)'
  r'(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?'
  r'(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
);

double _chiSquareBase62(String s) {
  final counts = <int, int>{};
  for (final c in s.codeUnits) {
    counts[c] = (counts[c] ?? 0) + 1;
  }
  final expected = s.length / Rand.base62Alphabet.length;
  var chi = 0.0;
  for (final c in Rand.base62Alphabet.codeUnits) {
    final d = (counts[c] ?? 0) - expected;
    chi += d * d / expected;
  }
  return chi;
}

void main() {
  setUp(() => Rand.seed(42));

  group('Numbers', () {
    test('integer returns value in range', () {
      check(Rand.integer()).isA<int>();
      check(Rand.integer(max: 1)).isA<int>();
      check(Rand.integer(min: 1, max: 2)).isA<int>();
      check(Rand.integer(min: -1, max: 1)).isA<int>();
    });

    test('integer max is exclusive, like nextInt', () {
      for (var i = 0; i < 1000; i++) {
        check(Rand.integer(max: 2)).isLessThan(2);
        check(Rand.integer(min: 4, max: 5)).equals(4);
        check(Rand.integer(min: -3, max: -1))
          ..isGreaterOrEqual(-3)
          ..isLessThan(-1);
      }
    });

    test('integer with min == max throws before drawing', () {
      Rand.seed(5);
      check(() => Rand.integer(min: 5, max: 5))
          .throws<ArgumentError>()
          .has((e) => '${e.message}', 'message')
          .contains('min (5) must be < max (5)');
      final next = Rand.integer();
      Rand.seed(5);
      check(next).equals(Rand.integer());
    });

    test('integer is uniform over its range', () {
      Rand.seed(42);
      final histogram = List.filled(10, 0);
      for (var i = 0; i < 100000; i++) {
        histogram[Rand.integer(max: 10)]++;
      }
      for (final count in histogram) {
        check(count).isGreaterOrEqual(9000);
        check(count).isLessOrEqual(11000);
      }
    });

    test('integer throws on invalid range', () {
      check(() => Rand.integer(min: 2, max: 1)).throws<ArgumentError>();
    });

    test('integer accepts spans up to 2^32', () {
      for (var i = 0; i < 1000; i++) {
        check(Rand.integer(max: 0x100000000))
          ..isGreaterOrEqual(0)
          ..isLessThan(0x100000000);
        check(Rand.integer(min: -0x80000001, max: 0x7FFFFFFF))
          ..isGreaterOrEqual(-0x80000001)
          ..isLessThan(0x7FFFFFFF);
      }
    });

    test('integer rejects spans past 2^32 naming max', () {
      check(() => Rand.integer(max: 0x100000001))
          .throws<ArgumentError>()
          .has((e) => e.name, 'name')
          .equals('max');
      check(() => Rand.integer(min: -1099511627776, max: 1099511627776))
          .throws<ArgumentError>()
          .has((e) => e.name, 'name')
          .equals('max');
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

    test('bare float() draws from [0, 1), like nextDouble', () {
      for (var i = 0; i < 1000; i++) {
        check(Rand.float())
          ..isGreaterOrEqual(0)
          ..isLessThan(1);
        check(Rand.float(min: 0.25))
          ..isGreaterOrEqual(0.25)
          ..isLessThan(1);
      }
    });

    test('float(min) above the default max of 1 throws', () {
      check(() => Rand.float(min: 5))
          .throws<ArgumentError>()
          .has((e) => '${e.message}', 'message')
          .contains('max (1)');
    });

    test('float throws on invalid range', () {
      check(() => Rand.float(min: 20, max: 10)).throws<ArgumentError>();
    });

    test('float rejects non-finite bounds', () {
      check(() => Rand.float(max: double.infinity)).throws<ArgumentError>();
      check(() => Rand.float(min: double.negativeInfinity))
          .throws<ArgumentError>();
      check(() => Rand.float(min: double.nan)).throws<ArgumentError>();
      check(() => Rand.float(max: double.nan)).throws<ArgumentError>();
    });

    test('float with min == max throws', () {
      check(() => Rand.float(min: 2, max: 2))
          .throws<ArgumentError>()
          .has((e) => '${e.message}', 'message')
          .contains('min (2) must be < max (2)');
      check(() => Rand.float(min: 123.456, max: 123.456))
          .throws<ArgumentError>();
    });

    test('float stays below max on adjacent doubles', () {
      for (final (lo, hi) in [
        (1.0, 1.0000000000000002),
        (1700000000.0, 1700000000.0 + 2.384185791015625e-7),
        (-1.0000000000000002, -1.0),
      ]) {
        check((lo + hi) / 2)
            .anyOf([(it) => it.equals(lo), (it) => it.equals(hi)]);
        for (var i = 0; i < 1000; i++) {
          check(Rand.float(min: lo, max: hi))
            ..isGreaterOrEqual(lo)
            ..isLessThan(hi);
        }
      }
    });

    test('equal-bound float throws before drawing', () {
      Rand.seed(5);
      check(() => Rand.float(min: 123.456, max: 123.456))
          .throws<ArgumentError>();
      final next = Rand.integer();
      Rand.seed(5);
      check(next).equals(Rand.integer());
    });

    test('float with 64-bit int bounds > 2^53 honours [lo, hi)', () {
      final minCollapsed = int.parse('9007199254740995');
      final maxCollapsed = int.parse('9007199254740996');
      check(
        because: 'both bounds round to the same double: [lo, hi) is empty',
        () => Rand.float(min: minCollapsed, max: maxCollapsed),
      ).throws<ArgumentError>();

      final minSpan = int.parse('9007199254740993');
      final maxSpan = int.parse('9007199254740994');
      final lo = minSpan.toDouble();
      final hi = maxSpan.toDouble();
      for (var i = 0; i < 1000; i++) {
        check(Rand.float(min: minSpan, max: maxSpan))
          ..isGreaterOrEqual(lo)
          ..isLessThan(hi);
      }
    });

    test(
      'latitude and longitude are finite and in range for precision 0..15',
      () {
        for (var p = 0; p <= 15; p++) {
          final lat = Rand.latitude(precision: p);
          final lng = Rand.longitude(precision: p);
          check(lat.isFinite).isTrue();
          check(lat.abs()).isLessOrEqual(90);
          check(lng.isFinite).isTrue();
          check(lng.abs()).isLessOrEqual(180);
        }
      },
    );

    test('latitude, longitude and geoPoint reject precision outside 0..15', () {
      for (final p in [16, 64, -1]) {
        check(() => Rand.latitude(precision: p)).throws<RangeError>();
        check(() => Rand.longitude(precision: p)).throws<RangeError>();
        check(() => Rand.geoPoint(precision: p)).throws<RangeError>();
      }
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

    test('charCode returns Rand.base62Alphabet character', () {
      for (var i = 0; i < 1000; i++) {
        final c = Rand.charCode();
        check(Rand.base62Alphabet.contains(String.fromCharCode(c))).isTrue();
      }
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

    test('semver matches the semver.org regex', () {
      Rand.seed(8);
      for (var i = 0; i < 5000; i++) {
        final v = Rand.semver(maxMajor: 20, maxMinor: 20, maxPatch: 200);
        check(v).matchesPattern(_semverOrg);
      }
    });

    test('semver validates maxMajor, maxMinor, maxPatch upfront', () {
      for (final (call, param) in [
        (() => Rand.semver(maxMajor: -1), 'maxMajor'),
        (() => Rand.semver(maxMajor: 0x100000000), 'maxMajor'),
        (() => Rand.semver(maxMinor: -1), 'maxMinor'),
        (() => Rand.semver(maxMinor: 0x100000000), 'maxMinor'),
        (() => Rand.semver(maxPatch: -1), 'maxPatch'),
        (() => Rand.semver(maxPatch: 0x100000000), 'maxPatch'),
      ]) {
        Rand.seed(5);
        check(call)
            .throws<ArgumentError>()
            .has((e) => e.name, 'name')
            .equals(param);
        final next = Rand.integer();
        Rand.seed(5);
        check(next).equals(Rand.integer());
      }
    });

    test('semver with zero maxima consumes no draw', () {
      Rand.seed(5);
      check(Rand.semver(maxMajor: 0, maxMinor: 0, maxPatch: 0)).equals('0.0.0');
      final next = Rand.integer();
      Rand.seed(5);
      check(next).equals(Rand.integer());
    });

    test('digits returns a digit string of the requested length', () {
      const digits = '0123456789';
      for (final len in [1, 6, 12]) {
        final code = Rand.digits(length: len);
        check(code).length.equals(len);
        for (var i = 0; i < code.length; i++) {
          check(digits.contains(code[i])).isTrue();
        }
      }
    });

    test('digits throws on non-positive length naming length', () {
      for (final len in [0, -3]) {
        check(() => Rand.digits(length: len))
            .throws<ArgumentError>()
            .has((e) => e.name, 'name')
            .equals('length');
      }
    });

    test('digits is reproducible under seed', () {
      Rand.seed(42);
      final a = List.generate(20, (_) => Rand.digits());
      Rand.seed(42);
      final b = List.generate(20, (_) => Rand.digits());
      check(a).deepEquals(b);
    });

    test('seeded charCode is uniform over Rand.base62Alphabet', () {
      Rand.seed(3);
      final s = String.fromCharCodes(
        List.generate(64000, (_) => Rand.charCode()),
      );
      check(_chiSquareBase62(s)).isLessThan(125);
    });
  });
}
