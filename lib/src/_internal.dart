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

double _lerp(num a, num b, double t) => a * (1.0 - t) + b * t;

void _checkNonNegative(int value, String name) {
  if (value < 0) throw ArgumentError('$name must be >= 0, got $value', name);
}

void _checkChance(double chance, String name) {
  if (!(chance >= 0 && chance <= 100)) {
    throw ArgumentError('$name must be in [0, 100], got $chance', name);
  }
}

void _checkWeights(List<int> weights) {
  var total = 0;
  for (final w in weights) {
    if (w < 0) {
      throw ArgumentError('weights must be >= 0, got $w', 'weights');
    }
    if (w > 0x100000000 - total) {
      throw ArgumentError(
        'weights must sum to 1..4294967296, got more than 4294967296',
        'weights',
      );
    }
    total += w;
  }
  if (total < 1) {
    throw ArgumentError(
      'weights must sum to 1..4294967296, got $total',
      'weights',
    );
  }
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
  int charCode() => base62.codeUnitAt(nextInt(base62.length));
}
