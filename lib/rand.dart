library rand;

import 'dart:math' as math;

abstract class Rand {
  static final _rand = math.Random();
  static final _randSecure = math.Random.secure();

  static const _maxInt = 1 << 32;
  static const _base62CharSet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  static final _minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
  static final _maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

  static bool boolean([truePercent = 50]) {
    assert(truePercent > 0, 'use false instead');
    assert(truePercent < 100, 'use true instead');
    return truePercent > _rand.nextInt(100);
  }

  /// [min] is inclusive, [max] is exclusive
  /// Default [max] is set to [1 << 32]
  static int integer([int? max, int? min]) {
    max ??= _maxInt;
    min ??= 0;
    RangeError.checkNotNegative(min, 'min');
    if (max == min) {
      return max;
    }
    final diff = max - min;
    RangeError.checkValueInInterval(diff, 0, _maxInt, 'difference');
    return _rand.nextInt(diff) + min;
  }

  /// Base62([_base62CharSet]) based char code
  static int char() => _base62CharSet.codeUnitAt(_rand.nextInt(62));

  /// Base62([_base62CharSet]) based string
  static String string(int len, [bool forceMaxLen = true]) {
    final buffer = StringBuffer();
    for (int i = 0; i < (forceMaxLen ? len : integer(len)); i++) {
      buffer.writeCharCode(char());
    }
    return buffer.toString();
  }

  static T? valurOrNull<T>(T value, [int nullPercent = 50]) {
    return boolean(nullPercent) ? null : value;
  }

  static T element<T>(Iterable<T> iterable) {
    return iterable.elementAt(_rand.nextInt(iterable.length));
  }

  static MapEntry<K, V> mapEntry<K, V>(Map<K, V> map) {
    return element(map.entries);
  }

  static K mapKey<K, V>(Map<K, V> map) {
    return map.keys.elementAt(_rand.nextInt(map.length));
  }

  static V mapValue<K, V>(Map<K, V> map) {
    return map[mapKey(map)]!;
  }

  static Set<T> setOfSize<T>(Iterable<T> pool, int size) {
    final copy = Set<T>.of(pool);
    if (size > copy.length) {
      throw IndexError(size - 1, copy, 'FewUniqueError');
    }
    final elements = <T>{};
    for (int i = 0; i < size; i++) {
      final e = element(copy);
      elements.add(e);
      copy.remove(e);
    }
    return elements;
  }

  /// [FirebaseFirestore.DocumentReference] id
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

  /// [a]/[b] parameters defines the limits, the order doesn't matter
  static Duration duration(Duration a, [Duration b = Duration.zero]) {
    return Duration(
      microseconds: numLerp(
        a.inMicroseconds,
        b.inMicroseconds,
        _rand.nextDouble(),
      ).toInt(),
    );
  }

  /// microsecondsSinceEpoch based random [DateTime] generator
  /// [a]/[b] parameters defines the limits, the order doesn't matter
  static DateTime dateTime([DateTime? a, DateTime? b]) {
    final epoch = numLerp(
      a?.microsecondsSinceEpoch ?? _minEpoch,
      b?.microsecondsSinceEpoch ?? _maxEpoch,
      _rand.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  /// Random local date between [01/01/a] and [01/01/b]
  static DateTime dateTimeYear(int a, int b) {
    final epoch = numLerp(
      DateTime(a).microsecondsSinceEpoch,
      DateTime(b).microsecondsSinceEpoch,
      _rand.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  static List<T> distributedProbability<T>({
    required List<int> probs, // probability of each value
    required List<T> values,
    required int size, // size of generated result
  }) {
    assert(probs.length == values.length,
        "each value must have it's own probability in equivalent index");
    final result = <T>[];
    final total = probs.fold<int>(0, (a, b) => a + b);
    for (int i = 0; i < size; i++) {
      int p = integer(total);
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
}

double numLerp(num a, num b, double t) => a + (b - a) * t;

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
