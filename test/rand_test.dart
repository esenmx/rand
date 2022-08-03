import 'dart:math';

import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() async {
  test('boolean (statistical)', () {
    int falseCount = 0;
    int trueCount = 0;
    for (var i = 0; i < 10000; i++) {
      if (Rand.boolean(99)) trueCount++;
      if (!Rand.boolean(1)) falseCount++;
    }
    expect(falseCount, greaterThan(9800));
    expect(falseCount, lessThan(10000));
    expect(trueCount, greaterThan(9800));
    expect(trueCount, lessThan(10000));
  });

  test('integer', () {
    expect(() => Random().nextInt(1 << 64), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(1, 2), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(-1), throwsA(isA<RangeError>()));
    expect(Rand.integer(0, 0), 0);
    expect(Rand.integer(), isA<int>());
    expect(Rand.integer(1), isA<int>());
    expect(Rand.integer(2, 1), isA<int>());
    expect(Rand.integer(1, -1), isA<int>());
    expect(Rand.integer(1 << 33 - 1, 1 << 32), greaterThanOrEqualTo(1 << 32));
    expect(Rand.integer(1 << 33 - 1, 1 << 32), lessThanOrEqualTo(1 << 33));
  });

  test('subSet', () {
    expect(Rand.subSet([], 0), <dynamic>{});
    expect(() => Rand.subSet([1, 2, 2], 3), throwsA(isA<RangeError>()));
    expect(Rand.subSet([1, 2, 2, 3, 3, 3], 3), {1, 2, 3});
    final array = List.generate(100, (i) => i).toSet();
    expect(Rand.subSet(array, 100).length, 100);
    expect(Rand.subSet(array, 50).length, 50);
  });

  final minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
  final maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

  test('dateTime', () {
    for (int i = 0; i < 1000; i++) {
      final dt = Rand.dateTime();
      expect(dt.microsecondsSinceEpoch, greaterThan(minEpoch));
      expect(dt.microsecondsSinceEpoch, lessThan(maxEpoch));
    }
  });

  group('duration', () {
    const max = Duration(days: 30);
    test('max', () {
      for (var i = 0; i < 1000; i++) {
        final d = Rand.duration(max);
        expect(d.inMicroseconds, lessThan(max.inMicroseconds));
        expect(d.inMicroseconds, greaterThan(0));
      }
    });

    const min = Duration(days: 1);
    test('max/min', () {
      for (var i = 0; i < 1000; i++) {
        final d = Rand.duration(max, min);
        expect(d.inMicroseconds, lessThan(max.inMicroseconds));
        expect(d.inMicroseconds, greaterThan(min.inMicroseconds));
      }
    });
  });

  test('dateTimeYear', () {
    expect(Rand.dateTimeYear(2000, 2000), DateTime(2000));
    for (int i = 0; i < 1000; i++) {
      final dt = Rand.dateTimeYear(1970, 2038);
      expect(dt.microsecondsSinceEpoch, greaterThan(minEpoch));
      expect(dt.microsecondsSinceEpoch, lessThan(maxEpoch));
    }
  });

  test('distributedProbability', () {
    expect(() {
      return Rand.distributedProbability(probs: [1], values: [], size: 10);
    }, throwsA(isA<AssertionError>()));
    expect(() {
      return Rand.distributedProbability(probs: [], values: [1], size: 10);
    }, throwsA(isA<AssertionError>()));
    expect(() {
      return Rand.distributedProbability(probs: [1], values: [1, 2], size: 10);
    }, throwsA(isA<AssertionError>()));

    for (var i = 0; i < 10000; i++) {
      final result = Rand.distributedProbability(
          probs: [1, 10, 100], values: ['foo', 'bar', 'baz'], size: 1110);
      final foo = result.where((e) => e == 'foo').length;
      final bar = result.where((e) => e == 'bar').length;
      final baz = result.where((e) => e == 'baz').length;
      expect(RangeError.checkValueInInterval(foo, 0, bar), foo);
      expect(RangeError.checkValueInInterval(bar, foo, baz), bar);
      expect(RangeError.checkValueInInterval(baz, bar, 1110), baz);
    }
  });

  test('char', () {
    for (var i = 0; i < 1000; i++) {
      var char = Rand.char();
      expect(Rand.base62CharSet.contains(String.fromCharCode(char)), isTrue);
      char = Rand.char(true);
      expect(Rand.base62CharSet.contains(String.fromCharCode(char)), isTrue);
    }
  });

  test('nonce', () {
    for (var i = 0; i < 1000; i++) {
      final len = Rand.integer(100);
      final nonce = Rand.nonce(len);
      expect(nonce, hasLength(len));
    }
  });
}
