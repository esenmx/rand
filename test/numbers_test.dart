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

    test('integer accepts spans up to 2^32 - 1', () {
      for (var i = 0; i < 1000; i++) {
        check(Rand.integer(max: 0xFFFFFFFF))
          ..isGreaterOrEqual(0)
          ..isLessOrEqual(0xFFFFFFFF);
        check(Rand.integer(min: -0x7FFFFFFF, max: 0x80000000))
          ..isGreaterOrEqual(-0x7FFFFFFF)
          ..isLessOrEqual(0x80000000);
      }
    });

    test('integer rejects spans past 2^32 - 1 naming max', () {
      check(() => Rand.integer(max: 0x100000000))
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

    test('float returns min when min == max', () {
      check(Rand.float(min: 1, max: 1)).equals(1);
      for (var i = 0; i < 100; i++) {
        check(Rand.float(min: 123.456, max: 123.456)).equals(123.456);
      }
    });

    test('equal-bound float consumes no draw', () {
      Rand.seed(5);
      Rand.float(min: 123.456, max: 123.456);
      final next = Rand.integer();
      Rand.seed(5);
      check(next).equals(Rand.integer());
    });

    test(
      'latitude and longitude are finite and in range for precision 0..15',
      () {
        for (var p = 0; p <= 15; p++) {
          final lat = Rand.latitude(p);
          final lng = Rand.longitude(p);
          check(lat.isFinite).isTrue();
          check(lat.abs()).isLessOrEqual(90);
          check(lng.isFinite).isTrue();
          check(lng.abs()).isLessOrEqual(180);
        }
      },
    );

    test('latitude, longitude and geoPoint reject precision outside 0..15', () {
      for (final p in [16, 64, -1]) {
        check(() => Rand.latitude(p)).throws<RangeError>();
        check(() => Rand.longitude(p)).throws<RangeError>();
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

    test('charCode returns base62 character', () {
      for (var i = 0; i < 1000; i++) {
        final c = Rand.charCode();
        check(base62.contains(String.fromCharCode(c))).isTrue();
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

    test('seeded charCode is uniform over base62', () {
      Rand.seed(3);
      final s = String.fromCharCodes(
        List.generate(64000, (_) => Rand.charCode()),
      );
      check(_chiSquareBase62(s)).isLessThan(125);
    });
  });
}
