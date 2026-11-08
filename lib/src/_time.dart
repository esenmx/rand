part of '../rand.dart';

int _halfOpen(int min, int max, Random rng) {
  final t = rng.nextDouble();
  final span = max - min;
  final spanWrapsInt64 = span < 0;
  if (spanWrapsInt64) {
    final halfOffset = (t * (max ~/ 2 - min ~/ 2)).floor();
    return min + halfOffset + halfOffset;
  }
  return min + (t * span).floor();
}

mixin _Time {
  Random get rng;

  /// See [Rand.duration].
  Duration duration({required Duration max, Duration min = .zero}) {
    final from = min.inMicroseconds;
    final to = max.inMicroseconds;
    _checkWebSafe(from, 'min', unit: ' µs');
    _checkWebSafe(to, 'max', unit: ' µs');
    if (min >= max) throw ArgumentError('min ($min) must be < max ($max)');
    return Duration(microseconds: _halfOpen(from, to, rng));
  }

  /// See [Rand.dateTime].
  DateTime dateTime({DateTime? min, DateTime? max}) {
    final from = min?.microsecondsSinceEpoch ?? _epochMin;
    final to = max?.microsecondsSinceEpoch ?? _epochMax;
    _checkWebSafe(from, 'min', unit: ' µs since the epoch');
    _checkWebSafe(to, 'max', unit: ' µs since the epoch');
    if (from >= to) {
      throw ArgumentError(switch ((min, max)) {
        (_, null) =>
          'min must be < 2038-01-01 UTC when max is omitted, '
              'got ${min?.toUtc()}; pass max',
        (null, _) =>
          'max must be > 1970-01-01 UTC when min is omitted, '
              'got ${max?.toUtc()}; pass min',
        _ =>
          'min must be < max, '
              'got min: ${min?.toUtc()}, max: ${max?.toUtc()}',
      });
    }
    return .fromMicrosecondsSinceEpoch(_halfOpen(from, to, rng), isUtc: true);
  }
}
