library rand;

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:meta/meta.dart';

class Rand {
  const Rand._();

  static final _r = math.Random();
  static final _rs = math.Random.secure();

  static const _maxInt = 1 << 32;

  @visibleForTesting
  static const base62CharSet =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

  static final _minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
  static final _maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

  static bool boolean([double truePercent = 50]) {
    return truePercent > _r.nextInt(100);
  }

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
    final int codeUnit;
    switch (rand.nextInt(3)) {
      case 0:
        codeUnit = rand.nextInt(10) + 48;
        break;
      case 1:
        codeUnit = rand.nextInt(26) + 65;
        break;
      case 2:
        codeUnit = rand.nextInt(26) + 97;
        break;
      default:
        throw FallThroughError();
    }
    return codeUnit;
  }

  static Uint8List bytes(int size, [bool secure = false]) {
    var buffer = Uint8List(size);
    for (var i = 0; i < size; i++) {
      buffer[i] = (secure ? _rs : _r).nextInt(0xff + 1);
    }
    return buffer;
  }

  /// Base62([base62CharSet]) based nonce
  static String nonce(int len, [bool secure = true]) {
    return String.fromCharCodes([for (int i = 0; i < len; i++) char(secure)]);
  }

  static T? valuerOrNull<T>(T value, [double nullPercent = 50]) {
    return boolean(nullPercent) ? null : value;
  }

  /// An example [FirebaseFirestore.DocumentReference] id
  static String documentId([int length = 20]) => nonce(length);

  /// An example s[FirebaseAuth] uid
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

  /// [a]/[b] parameters defines the limits, the order doesn't matter
  static Duration duration(Duration a, [Duration b = Duration.zero]) {
    return Duration(
      microseconds: numLerp(
        a.inMicroseconds,
        b.inMicroseconds,
        _r.nextDouble(),
      ).toInt(),
    );
  }

  /// microsecondsSinceEpoch based random [DateTime] generator
  /// [a]/[b] parameters defines the limits, the order doesn't matter
  static DateTime dateTime([DateTime? a, DateTime? b]) {
    final epoch = numLerp(
      a?.microsecondsSinceEpoch ?? _minEpoch,
      b?.microsecondsSinceEpoch ?? _maxEpoch,
      _r.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt());
  }

  /// Random local date between [01/01/a] and [01/01/b]
  static DateTime dateTimeYear(int a, int b) {
    final epoch = numLerp(
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
    for (int i = 0; i < size; i++) {
      int p = _r.nextInt(total);
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
