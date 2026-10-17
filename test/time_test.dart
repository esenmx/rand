import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  setUp(() => Rand.seed(42));

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

    test('default dateTime stays before 2038-01-01', () {
      final end = DateTime.utc(2038);
      for (var i = 0; i < 10000; i++) {
        check(Rand.dateTime().isBefore(end)).isTrue();
      }
    });

    test('duration throws when min > max', () {
      check(
        () => Rand.duration(
          min: const Duration(days: 10),
          max: const Duration(days: 1),
        ),
      ).throws<ArgumentError>();
    });

    test('dateTime throws when min > max', () {
      check(() => Rand.dateTime(min: .utc(2025), max: .utc(2020)))
          .throws<ArgumentError>();
    });

    test('dateTime(min:) after the default max throws', () {
      check(() => Rand.dateTime(min: .utc(2050))).throws<ArgumentError>();
    });

    test('reversed dateTime errors say which bound to pass in UTC', () {
      check(
          () => Rand.dateTime(
            min: .utc(2025).toLocal(),
            max: .utc(2020).toLocal(),
          ),
        ).throws<ArgumentError>().has((e) => '${e.message}', 'message')
        ..contains('min must be < max')
        ..contains('2025-01-01 00:00:00.000Z')
        ..contains('2020-01-01 00:00:00.000Z')
        ..not((it) => it.contains('2038'));
      check(() => Rand.dateTime(min: .utc(2050).toLocal()))
          .throws<ArgumentError>()
          .has((e) => '${e.message}', 'message')
        ..contains('2038-01-01 UTC')
        ..contains('2050-01-01 00:00:00.000Z')
        ..contains('pass max');
      check(() => Rand.dateTime(max: .utc(1969).toLocal()))
          .throws<ArgumentError>()
          .has((e) => '${e.message}', 'message')
        ..contains('1970-01-01 UTC')
        ..contains('1969-01-01 00:00:00.000Z')
        ..contains('pass min');
    });

    test('duration and dateTime with equal bounds throw before drawing', () {
      const d = Duration(seconds: 3);
      final t = DateTime.utc(2020);
      for (final (call, message) in [
        (() => Rand.duration(min: d, max: d), 'min ($d) must be < max ($d)'),
        (() => Rand.dateTime(min: t, max: t), 'min must be < max'),
        (
          () => Rand.dateTime(min: .utc(2038)),
          'min must be < 2038-01-01 UTC when max is omitted',
        ),
        (
          () => Rand.dateTime(max: .utc(1970)),
          'max must be > 1970-01-01 UTC when min is omitted',
        ),
      ]) {
        Rand.seed(5);
        check(call)
            .throws<ArgumentError>()
            .has((e) => '${e.message}', 'message')
            .contains(message);
        final next = Rand.integer();
        Rand.seed(5);
        check(next).equals(Rand.integer());
      }
    });

    test('a 1µs dateTime range always returns min', () {
      final start = DateTime.utc(2020);
      final end = start.add(const Duration(microseconds: 1));
      for (var i = 0; i < 1000; i++) {
        check(Rand.dateTime(min: start, max: end)).equals(start);
      }
    });

    test('a 1µs duration range always returns min', () {
      const min = Duration(days: 20000);
      const max = Duration(days: 20000, microseconds: 1);
      for (var i = 0; i < 1000; i++) {
        check(Rand.duration(min: min, max: max)).equals(min);
      }
    });

    test('negative duration range honours half-open [min, max)', () {
      const min = Duration(microseconds: -10);
      const max = Duration(microseconds: -5);
      final seen = {
        for (var i = 0; i < 2000; i++)
          Rand.duration(min: min, max: max).inMicroseconds,
      };
      printOnFailure('observed ${seen.toList()..sort()}');
      check(seen).contains(-10);
      check(seen).not((it) => it.contains(-5));
    });

    test('pre-1970 dateTime range honours half-open [min, max)', () {
      final start = DateTime.utc(1969, 12, 31, 23, 59, 59, 999, 990);
      final end = start.add(const Duration(microseconds: 5));
      final seen = {
        for (var i = 0; i < 2000; i++)
          Rand.dateTime(min: start, max: end).microsecondsSinceEpoch,
      };
      printOnFailure('observed ${seen.toList()..sort()}');
      check(seen).contains(start.microsecondsSinceEpoch);
      check(seen).not((it) => it.contains(end.microsecondsSinceEpoch));
    });
  });
}
