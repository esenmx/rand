library rand;

import 'dart:math' as math;

abstract class Rand {
  static final _rand = math.Random();
  static final _randSecure = math.Random.secure();

  static const maxInt = 1 << 32;

  static final minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
  static final maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

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

  static Set<T> setOf<T>(Iterable<T> pool, int length) {
    final copy = Set<T>.of(pool);
    if (length > copy.length) {
      throw IndexError(length - 1, copy, 'FewUniqueError');
    }
    final elements = <T>{};
    for (int i = 0; i < length; i++) {
      final e = element(copy);
      elements.add(e);
      copy.remove(e);
    }
    return elements;
  }

  static int charCode() => _base62CharSet.codeUnitAt(_rand.nextInt(62));

  static String string(int len, [bool forceMaxLen = true]) {
    final buffer = StringBuffer();
    for (int i = 0; i < (forceMaxLen ? len : Rand.integer(len)); i++) {
      buffer.writeCharCode(charCode());
    }
    return buffer.toString();
  }

  /// [Firestore] DocumentReference id
  static String documentId() => string(20);

  /// [FirebaseAuth] uid
  static String uid() => string(28);

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
    final epoch = numLerp(
      from?.microsecondsSinceEpoch ?? minEpoch,
      to?.microsecondsSinceEpoch ?? maxEpoch,
      _rand.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  static DateTime dateTimeWithinYears(int yearA, int yearB) {
    final epoch = numLerp(
      DateTime(yearA).microsecondsSinceEpoch,
      DateTime(yearB).microsecondsSinceEpoch,
      _rand.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }
}

extension DateTimeExtensions on DateTime {
  DateTime randomWithin(Duration margin) => Rand.dateTime(this, add(margin));
}

double numLerp<T extends num>(T a, T b, double t) => a + (b - a) * t;

extension IntExtensions on int {
  int square() => this * this;

  int cube() => this * this * this;
}

extension DoubleExtensions on double {
  double square() => this * this;

  double cube() => this * this * this;
}

extension NumExtensions on num {
  double sqrt() => math.sqrt(this);

  double exp() => math.exp(this);

  double log() => math.log(this);

  num pow(num exp) => math.pow(this, exp);
}
