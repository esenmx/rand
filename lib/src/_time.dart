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
  DateTime dateTime([DateTime? start, DateTime? end]) {
    final from = start?.microsecondsSinceEpoch ?? _epochMin;
    final to = end?.microsecondsSinceEpoch ?? _epochMax;
    if (from >= to) {
      throw ArgumentError(switch ((start, end)) {
        (_, null) =>
          'start must be < 2038-01-01 UTC when end is omitted, '
              'got ${start?.toUtc()}; pass end',
        (null, _) =>
          'end must be > 1970-01-01 UTC when start is omitted, '
              'got ${end?.toUtc()}; pass start',
        _ =>
          'start must be < end, '
              'got start: ${start?.toUtc()}, end: ${end?.toUtc()}',
      });
    }
    return DateTime.fromMicrosecondsSinceEpoch(
      _halfOpen(from, to, rng),
      isUtc: true,
    );
  }
}
