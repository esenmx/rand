import 'dart:math';

import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() async {
  test('integerRange', () {
    expect(() => Random().nextInt(Rand.maxRngInt * 1000),
        throwsA(isA<RangeError>()));
    expect(() => Rand.integer(1, 2), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(-1), throwsA(isA<RangeError>()));
    expect(() => Rand.integer(1, -1), throwsA(isA<RangeError>()));
    expect(Rand.integer(), isA<int>());
    expect(Rand.integer(1), isA<int>());
    expect(Rand.integer(2, 1), isA<int>());
  });

  test('dateTime', () {
    for (int i = 0; i < 1000; i++) {
      final dt = Rand.dateTime();
      expect(dt.isAfter(DateTime(2000)) && dt.isBefore(DateTime(2100)), true);
    }
  });

  const within = Duration(days: 365);
  test('dateTimeAfterWithin', () {
    for (int i = 0; i < 1000; i++) {
      final dt = Rand.dateTimeAfterWithin(DateTime(2000), within);
      expect(dt.isAfter(DateTime(2000)) && dt.isBefore(DateTime(2001)), true);
    }
  });

  test('dateTimeBeforeWithin', () {
    for (int i = 0; i < 1000; i++) {
      final dt = Rand.dateTimeBeforeWithin(DateTime(2001), within);
      expect(dt.isAfter(DateTime(2000)) && dt.isBefore(DateTime(2001)), true);
    }
  });
}