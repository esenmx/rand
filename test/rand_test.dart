import 'dart:math';

import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() async {
  test('boolean', () {
    expect(() => Rand.boolean(0), throwsA(isA<AssertionError>()));
    expect(() => Rand.boolean(100), throwsA(isA<AssertionError>()));
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
    expect(
        () => Random().nextInt(Rand.maxInt * 1000), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(1, 2), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(-1), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(1, -1), throwsA(isA<RangeError>()));
    expect(Rand.integer(), isA<int>());
    expect(Rand.integer(1), isA<int>());
    expect(Rand.integer(2, 1), isA<int>());
  });

  test('distributedProbability', () {
    expect(Rand.distributedProbability(probs: [], values: [], size: 10), []);

    for (var i = 0; i < 1000; i++) {
      final result = Rand.distributedProbability(
          probs: [1, 10, 100], values: ['foo', 'bar', 'baz'], size: 111);
      final foo = result.where((element) => element == 'foo').length;
      final bar = result.where((element) => element == 'bar').length;
      final baz = result.where((element) => element == 'baz').length;
      expect(RangeError.checkValueInInterval(foo, 0, bar), foo);
      expect(RangeError.checkValueInInterval(bar, foo, baz), bar);
      expect(RangeError.checkValueInInterval(baz, bar, 111), baz);
    }
  });

  test('setOfSize', () {
    expect(Rand.setOfSize([], 0), <dynamic>{});
    expect(() => Rand.setOfSize([1, 2, 2], 3), throwsA(isA<RangeError>()));
    expect(Rand.setOfSize([1, 2, 2, 3, 3, 3], 3), {1, 2, 3});
    final array = List.generate(100, (i) => i).toSet();
    expect(Rand.setOfSize(array, 100).length, 100);
    expect(Rand.setOfSize(array, 50).length, 50);
    expect(
        Rand.setOfSize(List.generate(500, (_) => Rand.uid()), 500).length, 500);
  });

  test('dateTime', () {
    for (int i = 0; i < 1000; i++) {
      final dt = Rand.dateTime();
      expect(dt.microsecondsSinceEpoch, greaterThan(Rand.minEpoch));
      expect(dt.microsecondsSinceEpoch, lessThan(Rand.maxEpoch));
    }
  });

  test('dateTimeWithinYears', () {
    for (int i = 0; i < 1000; i++) {
      final dt = Rand.dateTimeWithinYears(1970, 2038);
      expect(dt.microsecondsSinceEpoch, greaterThan(Rand.minEpoch));
      expect(dt.microsecondsSinceEpoch, lessThan(Rand.maxEpoch));
    }
  });

  const within = Duration(days: 365);
  test('within.after', () {
    for (int i = 0; i < 1000; i++) {
      final dt = DateTime(2000).randomWithin(within);
      expect(dt.isAfter(DateTime(2000)) && dt.isBefore(DateTime(2001)), true);
    }
  });

  test('within.before', () {
    for (int i = 0; i < 1000; i++) {
      final dt = DateTime(2001).randomWithin(-within);
      expect(dt.isAfter(DateTime(2000)) && dt.isBefore(DateTime(2001)), true);
    }
  });
}
