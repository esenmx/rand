part of '../rand.dart';

int _halfOpen(int min, int max, Random rng) {
  if (min == max) return min;
  return _lerp(min, max, rng.nextDouble()).floor().clamp(min, max - 1);
}

mixin _Time {
  Random get rng;

  Duration duration({required Duration max, Duration min = Duration.zero}) {
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    return Duration(
      microseconds: _halfOpen(min.inMicroseconds, max.inMicroseconds, rng),
    );
  }

  DateTime dateTime([DateTime? start, DateTime? end]) {
    final from = start?.microsecondsSinceEpoch ?? _epochMin;
    final to = end?.microsecondsSinceEpoch ?? _epochMax;
    if (from > to) {
      throw ArgumentError(
        'start must be <= end, got start: $start, end: '
        '${end ?? 'default 2038-01-01'}; pass end for a start past 2038-01-01',
      );
    }
    return DateTime.fromMicrosecondsSinceEpoch(
      _halfOpen(from, to, rng),
      isUtc: true,
    );
  }
}
