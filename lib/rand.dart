import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

part 'data/alias.dart';
part 'data/cities.dart';
part 'data/first_name.dart';
part 'data/last_name.dart';
part 'data/lorem.dart';

final class Rand {
  const Rand._();

  static var _r = math.Random();
  static final _rs = math.Random.secure();

  static void seed(int seed) => _r = math.Random(seed);

  ///
  /// Constants
  ///

  static const _maxInt = 1 << 32;

  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numeric = '0123456789';
  static const _special = '!@#\$%^&*()-_=+[]{}\\|;:\'",<.>/?`~';

  @visibleForTesting
  static const base62 = _numeric + _upper + _lower;

  static final _minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
  static final _maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

  static bool boolean([double trueChance = .5]) {
    assert(trueChance >= 0 && trueChance <= 1, 'trueChance must be in [0, 1]');
    return trueChance > _r.nextDouble();
  }

  ///
  /// Generic
  ///

  /// Returns [Null] or [value] based on [nullChance]
  static T? nullable<T>(T value, [double nullChance = 50]) {
    return boolean(nullChance) ? null : value;
  }

  ///
  /// Numeric
  ///

  /// [min]/[max] is inclusive
  /// [max] - [min] must be lesser or equal than [1 << 32 - 1]
  static int integer([int max = _maxInt - 1, int min = 0]) {
    if (max == min) {
      return max;
    }
    RangeError.checkValueInInterval(max - min, 1, _maxInt - 1, 'difference');
    return _r.nextInt(max - min + 1) + min;
  }

  /// [min]/[max] is inclusive
  static double float([num max = double.maxFinite, num min = 0]) {
    return _lerp(min, max, _r.nextDouble());
  }

  /// [precision] is the number of digits after the decimal point
  static double latitude([int precision = 5]) =>
      double.parse(float(90, -90).toStringAsPrecision(precision));

  /// [precision] is the number of digits after the decimal point
  static double longitude([int precision = 5]) =>
      double.parse(float(180, -180).toStringAsPrecision(precision));

  /// Returns a character using non-secure [math.Random]
  static int char() => _char(_r);

  /// Returns a character using secure [math.Random.secure]
  static int charSecure() => _char(_rs);

  /// Base62([base62CharSet]) based char code
  static int _char(math.Random r) {
    final s = r.nextInt(3);
    return switch (s) {
      0 => r.nextInt(10) + 48, // numeric
      1 => r.nextInt(26) + 65, // upper case
      2 => r.nextInt(26) + 97, // lower case
      _ => throw RangeError.range(s, 0, 2),
    };
  }

  static Uint8List bytes(int size, [bool secure = false]) {
    final buffer = Uint8List(size);
    for (var i = 0; i < size; i++) {
      buffer[i] = (secure ? _rs : _r).nextInt(0xff + 1);
    }
    return buffer;
  }

  ///
  /// Cryptographic
  ///

  /// [base62] based nonce
  static String nonce(int len) {
    return String.fromCharCodes([for (var i = 0; i < len; i++) charSecure()]);
  }

  /// [base62] based id
  static String id([int length = 16]) => nonce(length);

  /// Cryptographically secure password generator
  /// [length] is the length of the password
  /// [withLowercase] is the flag to include lowercase characters
  /// [withUppercase] is the flag to include uppercase characters
  /// [withNumeric] is the flag to include numeric characters
  /// [withSpecial] is the flag to include special characters
  static String password({
    int length = 12,
    bool withLowercase = true,
    bool withUppercase = true,
    bool withNumeric = true,
    bool withSpecial = true,
  }) {
    assert(length >= 4, 'minimum password length is 4');
    final pool = (StringBuffer()
          ..write(withLowercase ? _lower : '')
          ..write(withUppercase ? _upper : '')
          ..write(withNumeric ? _numeric : '')
          ..write(withSpecial ? _special : ''))
        .toString();

    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      final value = _rs.nextInt(pool.length);
      buffer.write(pool[value]);
    }
    return buffer.toString();
  }

  ///
  /// Time/Duration
  ///

  /// [a]/[b] parameters defines the limits, the order doesn't matter
  static Duration duration(Duration a, [Duration b = Duration.zero]) {
    return Duration(
      microseconds: _lerp(
        a.inMicroseconds,
        b.inMicroseconds,
        _r.nextDouble(),
      ).toInt(),
    );
  }

  /// microsecondsSinceEpoch based random [DateTime] generator
  /// [a]/[b] parameters defines the limits, the order doesn't matter
  static DateTime dateTime([DateTime? a, DateTime? b]) {
    final epoch = _lerp(
      a?.microsecondsSinceEpoch ?? _minEpoch,
      b?.microsecondsSinceEpoch ?? _maxEpoch,
      _r.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  /// Random local date between [01/01/a] and [01/01/b]
  static DateTime dateTimeYear(int a, int b) {
    final epoch = _lerp(
      DateTime(a).microsecondsSinceEpoch,
      DateTime(b).microsecondsSinceEpoch,
      _r.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  ///
  /// Collection
  ///

  static T element<T>(Iterable<T> iterable) =>
      iterable.elementAt(_r.nextInt(iterable.length));

  static MapEntry<K, V> mapEntry<K, V>(Map<K, V> map) => element(map.entries);

  static K mapKey<K, V>(Map<K, V> map) =>
      map.keys.elementAt(_r.nextInt(map.length));

  static V mapValue<K, V>(Map<K, V> map) => map[mapKey(map)]!;

  static Set<T> subSet<T>(Iterable<T> pool, int size) {
    final copy = Set<T>.of(pool);
    if (size > copy.length) {
      throw IndexError.withLength(
        size - 1,
        copy.length,
        message: 'few unique elements in the pool',
      );
    }
    final elements = <T>{};
    for (var i = 0; i < size; i++) {
      final e = element(copy);
      elements.add(e);
      copy.remove(e);
    }
    return elements;
  }

  ///
  /// Text
  ///

  static String alias() => element(_alias);

  static String firstName() => element(_firstNames);

  static String lastName() => element(_lastNames);

  static String fullName() {
    final buffer = StringBuffer('${firstName()} ');
    final middleCount = weightedRandomizedArray(
      weights: [100, 10, 1],
      pool: [0, 1, 2],
      size: 1,
    ).first;
    for (int i = 0; i < middleCount; i++) {
      buffer.write('${boolean() ? firstName() : lastName()} ');
    }
    buffer.write(lastName());
    return buffer.toString();
  }

  /// Returns a random lorem ipsum word
  static String word() => element(_words);

  /// Aggregates [count] number of random lorem ipsum words
  static String words({int? count, String separator = ' '}) =>
      subSet(_words, count ?? integer(10, 3)).join(separator);

  /// Returns a random lorem ipsum sentence
  static String sentence() => element(_sentences);

  /// Aggregates [size] number of random lorem ipsum sentences
  static String paragraph([int? size]) =>
      List.generate(size ?? integer(10, 5), (_) => sentence()).join('. ');

  /// Aggregates [size] number of [paragraph()]
  static String article([int? size]) =>
      List.generate(size ?? integer(7, 3), (_) => paragraph()).join('\n\n');

  ///
  /// Miscellaneous
  ///

  /// Returns a random city name
  static String city() => element(_cities);

  ///
  /// Probability
  ///

  /// [weights] represents the probability weights of each corresponding value
  /// in the same index from the [pool].
  /// [pool] is the list of values of type [T].
  /// [size] is size of the result array.
  /// [secure] is the flag to use cryptographically secure random generator.
  static List<T> weightedRandomizedArray<T>({
    required List<int> weights,
    required List<T> pool,
    required int size,
    bool secure = false,
  }) {
    assert(
      weights.length >= pool.length,
      'weights must greater or equal than pool',
    );
    if (weights.isEmpty || pool.isEmpty || size == 0) {
      return const [];
    }
    final random = (secure ? _rs : _r);
    final result = <T>[];
    final total = weights.fold<int>(0, (a, b) => a + b);
    for (var i = 0; i < size; i++) {
      int p = random.nextInt(total);
      for (var j = 0; j < weights.length; j++) {
        if (weights[j] > p) {
          result.add(pool[j]);
          break;
        }
        p -= weights[j];
      }
    }
    return result;
  }
}

double _lerp(num a, num b, double t) => a + (b - a) * t;
