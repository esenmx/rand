import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

part 'data/alias.dart';
part 'data/cities.dart';
part 'data/colors.dart';
part 'data/first_name.dart';
part 'data/last_name.dart';
part 'data/lorem.dart';

final class Rand {
  const Rand._();

  static var _r = math.Random();
  static final _rs = math.Random.secure();

  /// Set the seed for non-secure RNG.
  static void seed(int seed) => _r = math.Random(seed);

  ///
  /// Constants
  ///

  static const int _maxInt = (1 << 31) - 1;
  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numeric = '0123456789';
  static const _special = '!@#\$%^&*()-_=+[]{}\\|;:\'",<.>/?`~';
  @visibleForTesting
  static const String base62 = _numeric + _upper + _lower;

  static final int _minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
  static final int _maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

  ///
  /// Generic
  ///

  /// Returns true with [trueChance]% probability (default: 50).
  static bool boolean([double trueChance = 50]) {
    assert(
      trueChance >= 0 && trueChance <= 100,
      'trueChance should be in [0, 100]',
    );
    return trueChance > _r.nextInt(100);
  }

  /// Returns [value] or null according to [nullChance]% probability.
  static T? nullable<T>(T value, [double nullChance = 50]) {
    return boolean(nullChance) ? null : value;
  }

  ///
  /// Numeric
  ///

  /// Random int in [min, max] (inclusive). Max difference: 2^31-1.
  static int integer({int min = 0, int max = _maxInt - 1}) {
    if (max == min) return max;
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    RangeError.checkValueInInterval(max - min, 1, _maxInt - 1, 'difference');
    return _r.nextInt(max - min + 1) + min;
  }

  /// Random double in [min, max] range.
  static double float({num min = 0, num max = double.maxFinite}) {
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    return Rand._lerp(min, max, _r.nextDouble());
  }

  /// Random latitude value, [precision] controls decimals.
  static double latitude([int precision = 5]) =>
      double.parse(float(min: -90, max: 90).toStringAsPrecision(precision));

  /// Random longitude value, [precision] controls decimals.
  static double longitude([int precision = 5]) =>
      double.parse(float(min: -180, max: 180).toStringAsPrecision(precision));

  /// Random base62 char code (non-secure).
  static int char() => _char(_r);

  /// Random base62 char code (secure).
  static int charSecure() => _char(_rs);

  /// Internal: random base62 char from [r].
  static int _char(math.Random r) {
    final s = r.nextInt(3);
    return switch (s) {
      0 => r.nextInt(10) + 48, // 0-9
      1 => r.nextInt(26) + 65, // A-Z
      2 => r.nextInt(26) + 97, // a-z
      _ => throw RangeError.range(s, 0, 2),
    };
  }

  /// Random bytes of length [size]. Set [secure] for cryptographic RNG.
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

  /// Secure random base62 string of length [len].
  static String nonce(int len) =>
      String.fromCharCodes([for (var i = 0; i < len; i++) charSecure()]);

  /// Secure random ID (base62) of [length].
  static String id([int length = 16]) => nonce(length);

  /// Secure random password. Options control charsets; min length 4.
  static String password({
    int length = 12,
    bool withLowercase = true,
    bool withUppercase = true,
    bool withNumeric = true,
    bool withSpecial = true,
  }) {
    if (length < 4) {
      throw ArgumentError('minimum password length is 4, got $length');
    }
    final pool = (StringBuffer()
          ..write(withLowercase ? _lower : '')
          ..write(withUppercase ? _upper : '')
          ..write(withNumeric ? _numeric : '')
          ..write(withSpecial ? _special : ''))
        .toString();
    if (pool.isEmpty) {
      throw ArgumentError('at least one character set must be enabled');
    }

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

  /// Random Duration between [a] and [b].
  static Duration duration(Duration a, [Duration b = Duration.zero]) {
    return Duration(
      microseconds: Rand._lerp(
        a.inMicroseconds,
        b.inMicroseconds,
        _r.nextDouble(),
      ).toInt(),
    );
  }

  /// Random DateTime (microsecondsSinceEpoch) between [a] and [b].
  static DateTime dateTime([DateTime? a, DateTime? b]) {
    final epoch = Rand._lerp(
      a?.microsecondsSinceEpoch ?? _minEpoch,
      b?.microsecondsSinceEpoch ?? _maxEpoch,
      _r.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  /// Random DateTime between Jan 1st of years [a] and [b].
  static DateTime dateTimeYear(int a, int b) {
    final epoch = Rand._lerp(
      DateTime(a).microsecondsSinceEpoch,
      DateTime(b).microsecondsSinceEpoch,
      _r.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  ///
  /// Collection
  ///

  /// Returns a random element from [iterable].
  static T element<T>(Iterable<T> iterable) =>
      iterable.elementAt(_r.nextInt(iterable.length));

  /// Returns a random entry from [map].
  static MapEntry<K, V> mapEntry<K, V>(Map<K, V> map) => element(map.entries);

  /// Returns a random key from [map].
  static K mapKey<K, V>(Map<K, V> map) =>
      map.keys.elementAt(_r.nextInt(map.length));

  /// Returns a random value from [map].
  static V mapValue<K, V>(Map<K, V> map) => map[mapKey(map)]!;

  /// Returns unique random subset (size [size]) from [pool].
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

  /// Random alias/nickname.
  static String alias() => element(_alias);

  /// Random first name.
  static String firstName() => element(_firstNames);

  /// Random last name.
  static String lastName() => element(_lastNames);

  /// Random full name. May include 0-2 additional names.
  static String fullName() {
    final buffer = StringBuffer('${firstName()} ');
    final middleCount = weightedRandomizedArray(
      weights: [100, 10, 1],
      pool: [0, 1, 2],
      size: 1,
    ).first;
    for (var i = 0; i < middleCount; i++) {
      buffer.write('${boolean() ? firstName() : lastName()} ');
    }
    buffer.write(lastName());
    return buffer.toString();
  }

  /// Random lorem word.
  static String word() => element(_words);

  /// [count] random lorem words, joined by [separator]. If [count] is null, uses random count.
  static String words({int? count, String separator = ' '}) =>
      subSet(_words, count ?? integer(min: 3, max: 10)).join(separator);

  /// Random lorem sentence.
  static String sentence() => element(_sentences);

  /// [size] random sentences as a paragraph. If [size] is null, uses random size.
  static String paragraph([int? size]) =>
      List.generate(size ?? integer(min: 5, max: 10), (_) => sentence())
          .join('. ');

  /// [size] random paragraphs as article. If [size] is null, uses random size.
  static String article([int? size]) =>
      List.generate(size ?? integer(min: 3, max: 7), (_) => paragraph())
          .join('\n\n');

  ///
  /// Miscellaneous
  ///

  /// Random city name.
  static String city() => element(_cities);

  /// Random CSS color.
  static CSSColors color() => element(CSSColors.values);

  /// Random CSS color (dark colors only).
  static CSSColors colorDark() =>
      element(CSSColors.values.where((c) => c.isDark));

  /// Random CSS color (light colors only).
  static CSSColors colorLight() =>
      element(CSSColors.values.where((c) => !c.isDark));

  ///
  /// Probability
  ///

  /// Returns an array of [size] random elements from [pool], using [weights] as selection probability, optionally with secure RNG.
  static List<T> weightedRandomizedArray<T>({
    required List<int> weights,
    required List<T> pool,
    required int size,
    bool secure = false,
  }) {
    if (weights.length < pool.length) {
      throw ArgumentError(
        'weights length (${weights.length}) must be >= pool length (${pool.length})',
      );
    }
    if (weights.isEmpty || pool.isEmpty || size == 0) {
      return const [];
    }
    final random = (secure ? _rs : _r);
    final result = <T>[];
    final total = weights.fold<int>(0, (a, b) => a + b);
    for (var i = 0; i < size; i++) {
      var p = random.nextInt(total);
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

  /// Linear interpolation between [a] and [b] by [t].
  static double _lerp(num a, num b, double t) => a + (b - a) * t;
}
