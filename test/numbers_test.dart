import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

final _semverOrg = RegExp(
  r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)'
  r'(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)'
  r'(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?'
  r'(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$',
);

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
  });
}
