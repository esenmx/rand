import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

part 'data/alias.dart';
part 'data/cities.dart';
part 'data/colors.dart';
part 'data/first_name.dart';
part 'data/last_name.dart';
part 'data/lorem.dart';

/// A utility class for generating random data.
///
/// All methods are static. Use [seed] for reproducible results.
final class Rand {
  const Rand._();

  static var _r = math.Random();
  static final _sr = math.Random.secure();

  /// Sets the seed for reproducible random generation.
  ///
  /// Does not affect secure methods like [password], [id], [nonce].
  static void seed(int value) => _r = math.Random(value);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Constants
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static const int _maxInt = (1 << 31) - 1;
  static const _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _digits = '0123456789';
  static const _symbols = '!@#\$%^&*()-_=+[]{}\\|;:\'",<.>/?`~';

  /// Base62 character set (digits + uppercase + lowercase).
  @visibleForTesting
  static const String base62 = _digits + _uppercase + _lowercase;

  static final int _epochMin = DateTime.utc(1970).microsecondsSinceEpoch;
  static final int _epochMax = DateTime.utc(2038).microsecondsSinceEpoch;

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Boolean & Nullable
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Returns `true` with given [probability] (0-100). Default: 50%.
  static bool boolean([double probability = 50]) {
    assert(
      probability >= 0 && probability <= 100,
      'probability must be in [0, 100]',
    );
    return probability > _r.nextInt(100);
  }

  /// Returns [value] or `null` with given [nullProbability] (0-100). Default: 50%.
  static T? nullable<T>(T value, [double nullProbability = 50]) {
    return boolean(nullProbability) ? null : value;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Numbers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random integer in [min, max] range (inclusive).
  ///
  /// Maximum range: 2^31-1.
  static int integer({int min = 0, int max = _maxInt - 1}) {
    if (max == min) return max;
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    RangeError.checkValueInInterval(max - min, 1, _maxInt - 1, 'difference');
    return _r.nextInt(max - min + 1) + min;
  }

  /// Random double in [min, max] range.
  static double float({num min = 0, num max = double.maxFinite}) {
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    return _lerp(min, max, _r.nextDouble());
  }

  /// Random latitude (-90 to 90) with given decimal [precision].
  static double latitude([int precision = 5]) =>
      double.parse(float(min: -90, max: 90).toStringAsPrecision(precision));

  /// Random longitude (-180 to 180) with given decimal [precision].
  static double longitude([int precision = 5]) =>
      double.parse(float(min: -180, max: 180).toStringAsPrecision(precision));

  /// Random base62 character code.
  static int charCode() => _r.charCode();

  /// Random base62 character code (cryptographically secure).
  static int safeCharCode() => _sr.charCode();

  /// Random bytes of given [length]. Set [secure] for cryptographic use.
  static Uint8List bytes(int length, [bool secure = false]) {
    final rng = secure ? _sr : _r;
    return Uint8List.fromList(
      [for (var i = 0; i < length; i++) rng.nextInt(256)],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Cryptographic
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Secure random base62 string of given [length].
  static String nonce(int length) =>
      String.fromCharCodes([for (var i = 0; i < length; i++) safeCharCode()]);

  /// Secure random ID (base62). Default: 16 characters.
  static String id([int length = 16]) => nonce(length);

  /// Secure random password with configurable character sets.
  ///
  /// Minimum [length] is 4.
  static String password({
    int length = 12,
    bool lowercase = true,
    bool uppercase = true,
    bool digits = true,
    bool symbols = true,
  }) {
    if (length < 4) {
      throw ArgumentError('length must be >= 4, got $length');
    }
    final pool = StringBuffer()
      ..write(lowercase ? _lowercase : '')
      ..write(uppercase ? _uppercase : '')
      ..write(digits ? _digits : '')
      ..write(symbols ? _symbols : '');
    if (pool.isEmpty) {
      throw ArgumentError('at least one character set must be enabled');
    }
    final chars = pool.toString();
    return String.fromCharCodes([
      for (var i = 0; i < length; i++)
        chars.codeUnitAt(_sr.nextInt(chars.length)),
    ]);
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Time
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random [Duration] between [max] and [min]. Default min: zero.
  static Duration duration(Duration max, [Duration min = Duration.zero]) {
    return Duration(
      microseconds: _lerp(
        min.inMicroseconds,
        max.inMicroseconds,
        _r.nextDouble(),
      ).toInt(),
    );
  }

  /// Random [DateTime] between [start] and [end]. Default: 1970-2038.
  static DateTime dateTime([DateTime? start, DateTime? end]) {
    final epoch = _lerp(
      start?.microsecondsSinceEpoch ?? _epochMin,
      end?.microsecondsSinceEpoch ?? _epochMax,
      _r.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Collections
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random element from [from].
  static T element<T>(Iterable<T> from) =>
      from.elementAt(_r.nextInt(from.length));

  /// Random entry from [from].
  static MapEntry<K, V> mapEntry<K, V>(Map<K, V> from) => element(from.entries);

  /// Random key from [from].
  static K mapKey<K, V>(Map<K, V> from) =>
      from.keys.elementAt(_r.nextInt(from.length));

  /// Random value from [from].
  static V mapValue<K, V>(Map<K, V> from) => from[mapKey(from)]!;

  /// Random subset of [count] unique elements from [from].
  static Set<T> subSet<T>(Iterable<T> from, int count) {
    final available = Set<T>.of(from);
    if (count > available.length) {
      throw RangeError(
        'count ($count) exceeds unique elements (${available.length})',
      );
    }
    final result = <T>{};
    for (var i = 0; i < count; i++) {
      final picked = element(available);
      result.add(picked);
      available.remove(picked);
    }
    return result;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Text
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random alias/nickname.
  static String alias() => element(_alias);

  /// Random first name.
  static String firstName() => element(_firstNames);

  /// Random last name.
  static String lastName() => element(_lastNames);

  /// Random full name (first + optional middle + last).
  static String fullName() {
    final buffer = StringBuffer(firstName());
    final middleCount = sample(
      weights: [100, 10, 1],
      from: [0, 1, 2],
      count: 1,
    ).first;
    for (var i = 0; i < middleCount; i++) {
      buffer.write(' ${boolean() ? firstName() : lastName()}');
    }
    buffer.write(' ${lastName()}');
    return buffer.toString();
  }

  /// Random lorem word.
  static String word() => element(_words);

  /// Random lorem words joined by [separator]. Default [count]: 3-10.
  static String words({int? count, String separator = ' '}) =>
      subSet(_words, count ?? integer(min: 3, max: 10)).join(separator);

  /// Random lorem sentence.
  static String sentence() => element(_sentences);

  /// Random paragraph of [count] sentences. Default: 5-10.
  static String paragraph([int? count]) =>
      List.generate(count ?? integer(min: 5, max: 10), (_) => sentence())
          .join('. ');

  /// Random article of [count] paragraphs. Default: 3-7.
  static String article([int? count]) =>
      List.generate(count ?? integer(min: 3, max: 7), (_) => paragraph())
          .join('\n\n');

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Miscellaneous
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random city name.
  static String city() => element(_cities);

  /// Random CSS color.
  static CSSColors color() => element(CSSColors.values);

  /// Random dark CSS color.
  static CSSColors colorDark() =>
      element(CSSColors.values.where((c) => c.isDark));

  /// Random light CSS color.
  static CSSColors colorLight() =>
      element(CSSColors.values.where((c) => !c.isDark));

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Sampling
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Selects [count] elements from [from] with optional [weights].
  ///
  /// If [weights] is null, all items have equal probability.
  /// Set [secure] for cryptographic RNG.
  static List<T> sample<T>({
    required List<T> from,
    required int count,
    List<int>? weights,
    bool secure = false,
  }) {
    if (from.isEmpty || count == 0) return const [];
    final w = weights ?? List.filled(from.length, 1);
    if (w.length < from.length) {
      throw ArgumentError(
        'weights.length (${w.length}) must be >= from.length (${from.length})',
      );
    }
    final rng = secure ? _sr : _r;
    final total = w.fold<int>(0, (sum, v) => sum + v);
    final result = <T>[];
    for (var i = 0; i < count; i++) {
      var threshold = rng.nextInt(total);
      for (var j = 0; j < w.length; j++) {
        if (w[j] > threshold) {
          result.add(from[j]);
          break;
        }
        threshold -= w[j];
      }
    }
    return result;
  }

  static double _lerp(num a, num b, double t) => a + (b - a) * t;
}

extension on math.Random {
  int charCode() {
    return switch (nextInt(3)) {
      0 => nextInt(10) + 48, // 0-9
      1 => nextInt(26) + 65, // A-Z
      2 => nextInt(26) + 97, // a-z
      _ => throw StateError('unreachable'),
    };
  }
}
