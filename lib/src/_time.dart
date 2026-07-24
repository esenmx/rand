part of '../rand.dart';

mixin _Time {
  Random get rng;

  Duration duration({required Duration max, Duration min = Duration.zero}) {
    return Duration(
      microseconds: _lerp(
        min.inMicroseconds,
        max.inMicroseconds,
        rng.nextDouble(),
      ).toInt(),
    );
  }

  DateTime dateTime([DateTime? start, DateTime? end]) {
    final epoch = _lerp(
      start?.microsecondsSinceEpoch ?? _epochMin,
      end?.microsecondsSinceEpoch ?? _epochMax,
      rng.nextDouble(),
    );
    return DateTime.fromMicrosecondsSinceEpoch(epoch.toInt(), isUtc: true);
  }
}
