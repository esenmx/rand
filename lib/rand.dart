library rand;

import 'dart:math' as math;

import 'package:meta/meta.dart';

abstract class Rand {
  static final _rand = math.Random();
  static final _randSecure = math.Random.secure();

  @visibleForTesting
  static const maxInt = 1 << 32;

  static final defaultMinEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
  static final defaultMaxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

  static const _base62CharSet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  static bool boolean([truePercent = 50]) {
    assert(truePercent > 0, 'use false instead');
    assert(truePercent < 100, 'use true instead');
    return truePercent > _rand.nextInt(100);
  }

  static List<T> distributedProps<T>({
    required List<int> probs, // probability of each value
    required List<T> values,
    required int size, // size of generated result
  }) {
    assert(probs.length == values.length,
        "each value must have it's own probability in same index");
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
    final adjMax = max ?? maxInt;
    RangeError.checkNotNegative(adjMax, 'max');
    return adjMax == min ? adjMax : _rand.nextInt(adjMax - min) + min;
  }

  static T? mayBeNull<T>(T value, [int nullPercent = 50]) {
    return boolean(nullPercent) ? null : value;
  }

  static T element<T>(Iterable<T> iterable) {
    return iterable.elementAt(_rand.nextInt(iterable.length));
  }

  static MapEntry<K, V> mapEntry<K, V>(Map<K, V> map) {
    return map.entries.elementAt(_rand.nextInt(map.length));
  }

  static K mapKey<K, V>(Map<K, V> map) {
    return map.keys.elementAt(_rand.nextInt(map.length));
  }

  static V mapValue<K, V>(Map<K, V> map) {
    return map[mapKey(map)]!;
  }

  static Set<T> elementSet<T>(Set<T> pool, int length) {
    RangeError.checkValidIndex(length - 1, pool,
        "not enough unique values for creating Set<{$T> with length of $length");
    final copy = Set<T>.of(pool);
    final elements = <T>{};
    for (int i = 0; i < length; i++) {
      final e = element(copy);
      elements.add(e);
      copy.remove(e);
    }
    return elements;
  }

  static String string(int length) {
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.writeCharCode(_base62CharSet.codeUnitAt(_rand.nextInt(62)));
    }
    return buffer.toString();
  }

  /// [Firestore] DocumentReference id
  static String get documentId => string(20);

  /// [FirebaseAuth] uid
  static String get uid => string(28);

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
      final value = _randSecure.nextInt(chars.length);
      buffer.write(chars[value]);
    }
    return buffer.toString();
  }

  /// microsecondsSinceEpoch based random [DateTime] generator
  /// [from]/[to] parameters defines the limits instead of [min]/[max]
  /// so the order doesn't matter
  static DateTime dateTime([DateTime? to, DateTime? from]) {
    final microEpochLerp = numLerp(
      from?.microsecondsSinceEpoch ?? defaultMinEpoch,
      to?.microsecondsSinceEpoch ?? defaultMaxEpoch,
      _rand.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(microEpochLerp.toInt());
  }
}

extension DateTimeExtensions on DateTime {
  DateTime randomWithin(Duration margin) => Rand.dateTime(this, add(margin));
}

double numLerp<T extends num>(T a, T b, double t) => a + (b - a) * t;

extension IntExtensions on int {
  int get square => this * this;

  int get cube => this * this * this;
}

extension DoubleExtensions on double {
  double get square => this * this;

  double get cube => this * this * this;
}

extension NumExtensions on num {
  double get sqrt => math.sqrt(this);

  double get exp => math.exp(this);

  double get log => math.log(this);

  num pow(num exp) => math.pow(this, exp);
}
