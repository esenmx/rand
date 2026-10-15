part of '../rand.dart';

int _halfOpen(int min, int max, Random rng) {
  return _lerp(min, max, rng.nextDouble()).floor().clamp(min, max - 1);
}

mixin _Time {
  Random get rng;

  /// See [Rand.duration].
  Duration duration({required Duration max, Duration min = Duration.zero}) {
    if (min >= max) throw ArgumentError('min ($min) must be < max ($max)');
    return Duration(
      microseconds: _halfOpen(min.inMicroseconds, max.inMicroseconds, rng),
    );
  }

  /// See [Rand.dateTime].
  DateTime dateTime({DateTime? min, DateTime? max}) {
    final from = min?.microsecondsSinceEpoch ?? _epochMin;
    final to = max?.microsecondsSinceEpoch ?? _epochMax;
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
    return DateTime.fromMicrosecondsSinceEpoch(
      _halfOpen(from, to, rng),
      isUtc: true,
    );
  }
}
