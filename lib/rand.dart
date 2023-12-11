import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

part 'lorem.dart';

final class Rand {
  const Rand._();

  static final _r = math.Random();
  static final _rs = math.Random.secure();

  ///
  /// Constants
  ///

  static const _maxInt = 1 << 32;

  @visibleForTesting
  static const base62CharSet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  static final _minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
  static final _maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

  static bool boolean([double trueProbability = 50]) {
    return trueProbability > _r.nextInt(100);
  }

  ///
  /// Numeric
  ///

  /// both [min]/[max] is inclusive
  /// [max] - [min] must be lesser or equal than [1 << 32 - 1]
  static int integer([int max = _maxInt - 1, int min = 0]) {
    if (max == min) {
      return max;
    }
    RangeError.checkValueInInterval(max - min, 1, _maxInt - 1, 'difference');
    return _r.nextInt(max - min + 1) + min;
  }

  /// Base62([base62CharSet]) based char code
  static int char([bool secure = false]) {
    final rand = secure ? _rs : _r;
    return switch (rand.nextInt(3)) {
      0 => rand.nextInt(10) + 48,
      1 => rand.nextInt(26) + 65,
      2 => rand.nextInt(26) + 97,
      _ => throw StateError(''),
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
  /// Crypto
  ///

  /// Base62([base62CharSet]) based nonce
  static String nonce(int len, [bool secure = true]) {
    return String.fromCharCodes([for (var i = 0; i < len; i++) char(secure)]);
  }

  static T? maybeNull<T>(T value, [double nullProbability = 50]) {
    return boolean(nullProbability) ? null : value;
  }

  /// An example [FirebaseFirestore.DocumentReference] id
  static String documentId([int length = 20]) => nonce(length);

  /// For generating [FirebaseAuth] like uid's
  static String uid([int length = 28]) => nonce(length);

  static String password({
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
      final value = _rs.nextInt(chars.length);
      buffer.write(chars[value]);
    }
    return buffer.toString();
  }

  ///
  /// DateTime/Duration
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
  /// Collections
  ///

  static T element<T>(Iterable<T> iterable) {
    return iterable.elementAt(_r.nextInt(iterable.length));
  }

  static MapEntry<K, V> mapEntry<K, V>(Map<K, V> map) {
    return element(map.entries);
  }

  static K mapKey<K, V>(Map<K, V> map) {
    return map.keys.elementAt(_r.nextInt(map.length));
  }

  static V mapValue<K, V>(Map<K, V> map) {
    return map[mapKey(map)]!;
  }

  static Set<T> subSet<T>(Iterable<T> pool, int size) {
    final copy = Set<T>.of(pool);
    if (size > copy.length) {
      throw IndexError.withLength(
        size - 1,
        copy.length,
        message: 'FewUniqueError',
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
  /// Probability
  ///

  static List<T> distributedProbability<T>({
    required List<int> probs, // probability of each value
    required List<T> values,
    required int size, // size of generated result
  }) {
    assert(probs.isNotEmpty);
    assert(values.isNotEmpty);
    assert(probs.length == values.length);
    final result = <T>[];
    final total = probs.fold<int>(0, (a, b) => a + b);
    for (var i = 0; i < size; i++) {
      int p = _r.nextInt(total);
      for (var j = 0; j < probs.length; j++) {
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

double _lerp(num a, num b, double t) => a + (b - a) * t;
