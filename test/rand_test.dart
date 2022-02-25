import 'dart:math';

import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() async {
  test('integer', () {
    expect(() => Random().nextInt(Rand.maxRngInt * 1000),
        throwsA(isA<RangeError>()));
    expect(() => Rand.integer(1, 2), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(-1), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(1, -1), throwsA(isA<RangeError>()));
    expect(Rand.integer(), isA<int>());
    expect(Rand.integer(1), isA<int>());
    expect(Rand.integer(2, 1), isA<int>());
  });

  test('probabilityDistribution', () {
    expect(Rand.probabilityDistribution(probs: [], values: [], size: 10), []);

    for (var i = 0; i < 100; i++) {
      final result = Rand.probabilityDistribution(
          probs: [1, 10, 100], values: ['foo', 'bar', 'baz'], size: 111);
      final foo = result.where((element) => element == 'foo').length;
      final bar = result.where((element) => element == 'bar').length;
      final baz = result.where((element) => element == 'baz').length;
      expect(RangeError.checkValueInInterval(foo, 0, bar), foo);
      expect(RangeError.checkValueInInterval(bar, foo, baz), bar);
      expect(RangeError.checkValueInInterval(baz, bar, 111), baz);
    }
  });

  test('elementSet', () {
    expect(() => Rand.elementSet({}, 0), throwsA(isA<RangeError>()));
    expect(() => Rand.elementSet({1, 2, 2}, 3), throwsA(isA<RangeError>()));
    expect(Rand.elementSet({1, 2, 2, 3, 3, 3}, 3), {1, 2, 3});
    final array = List.generate(100, (i) => i).toSet();
    expect(Rand.elementSet(array, 100).length, 100);
    expect(Rand.elementSet(array, 50).length, 50);
  });

  test('quantitiveConditionalSetBuilder', () {});

  test('dateTime', () {
    const max = (1 << 31) * 1000000;
    for (int i = 0; i < 1000; i++) {
      final dt = Rand.dateTime();
      expect(dt.isAfter(DateTime.fromMicrosecondsSinceEpoch(0)), true);
      expect(dt.isBefore(DateTime.fromMicrosecondsSinceEpoch(max)), true);
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
