part of '../rand.dart';

const int _maxInt = (1 << 31) - 1;
const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String _digits = '0123456789';
const String _symbols = '!@#\$%^&*()-_=+[]{}\\|;:\'",<.>/?`~';

/// Base62 alphabet — digits, then uppercase, then lowercase ASCII.
///
/// Used by [Rand.charCode], [Rand.secureCharCode], and [Rand.nonce].
const String base62 = _digits + _uppercase + _lowercase;

final int _epochMin = DateTime.utc(1970).microsecondsSinceEpoch;
final int _epochMax = DateTime.utc(2038).microsecondsSinceEpoch;

double _lerp(num a, num b, double t) {
  if (a.isInfinite || b.isInfinite) {
    return a + (b - a) * t;
  }
  return a * (1.0 - t) + b * t;
}

T _weightedChoice<T>(List<T> items, List<int> weights, Random rng) {
  final total = weights.fold<int>(0, (sum, w) => sum + w);
  var threshold = rng.nextInt(total);
  for (var i = 0; i < weights.length; i++) {
    if (weights[i] > threshold) return items[i];
    threshold -= weights[i];
  }
  throw StateError('unreachable: weighted choice fell through');
}

extension on Random {
  int charCode() {
    return switch (nextInt(3)) {
      0 => nextInt(10) + 48, // 0-9
      1 => nextInt(26) + 65, // A-Z
      2 => nextInt(26) + 97, // a-z
      _ => throw StateError('unreachable'),
    };
  }
}
