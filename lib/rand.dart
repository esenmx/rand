library rand;

import 'dart:math' as math;

abstract class Rand {
  static final _rand = math.Random();

  static const maxRngInt = 1 << 32;

  static const base62CharSet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  static bool boolean([truePercent = 50]) {
    assert(truePercent > 0, 'use false instead');
    assert(truePercent < 100, 'use true instead');
    return truePercent > _rand.nextInt(100);
  }

  static List<T> probabilityDistribution<T>({
    required List<int> probs, // probability of each value
    required List<T> values,
    required int size, // size of generated result
  }) {
    assert(probs.length == values.length,
        "each value must have it's own probability");
    final result = <T>[];
    final totalProb = probs.fold<int>(0, (a, b) => a + b);
    for (int i = 0; i < size; i++) {
      int p = integer(totalProb);
      for (int j = 0; j < probs.length; j++) {
        if (probs[j] > p) {
          result.add(values[j]);
          break;
        }
        p -= probs[j];
      }
    }
    return result;
  }

  /// [max] is exclusive, [min] is inclusive
  /// default adjusted max value [adjMax] is `1 << 32`
  static int integer([int? max, int min = 0]) {
    RangeError.checkNotNegative(min, 'min');
    final adjMax = max ?? maxRngInt;
    RangeError.checkNotNegative(adjMax, 'max');
    return adjMax == min ? adjMax : _rand.nextInt(adjMax - min) + min;
  }

  static T? mayBeNull<T>(T value, [int nullPercent = 50]) {
    return boolean(nullPercent) ? null : value;
  }

  static T element<T>(Iterable<T> iterable) {
    return iterable.elementAt(_rand.nextInt(iterable.length));
  }

  static MapEntry<K, V> entry<K, V>(Map<K, V> map) {
    return map.entries.elementAt(_rand.nextInt(map.length));
  }

  static String string(int length) {
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.writeCharCode(base62CharSet.codeUnitAt(_rand.nextInt(62)));
    }
    return buffer.toString();
  }

  /// Random [Firestore] documentId, rarely it becomes 28 characters
  static String get documentId => boolean(99) ? string(20) : string(28);

  static String randomPassword({
    int length = 16,
    bool withLowercase = true,
    bool withUppercase = true,
    bool withNumeric = true,
    bool withSpecial = true,
  }) {
    const lowerCase = "abcdefghijklmnopqrstuvwxyz";
    const upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numeric = "0123456789";
    const special = "!@#\$%^&*()-_=+[]{}\\|;:'\",<.>/?`~";

    final chars = (StringBuffer()
          ..write(withLowercase ? lowerCase : '')
          ..write(withUppercase ? upperCase : '')
          ..write(withNumeric ? numeric : '')
          ..write(withSpecial ? special : ''))
        .toString();

    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final value = math.Random.secure().nextInt(chars.length);
      buffer.write(chars[value]);
    }
    return buffer.toString();
  }

  /// [a] and [b] parameters define the limits of the generated [DateTime] object
  /// (a < b) or (a > b) doesn't matter, they are just the limits
  static DateTime dateTime({DateTime? a, DateTime? b}) {
    final microEpoch = lerp(
      (a ?? DateTime(2000)).microsecondsSinceEpoch,
      (b ?? DateTime(2038)).microsecondsSinceEpoch,
      Rand._rand.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(microEpoch.toInt());
  }
}

double lerp<T extends num>(T a, T b, double t) => a + (b - a) * t;

extension DateTimeExtensions on DateTime {
  DateTime within(Duration margin) => Rand.dateTime(a: this, b: add(margin));
}
