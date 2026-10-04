part of '../rand.dart';

mixin _Sampling {
  Random get rng;

  List<T> sample<T>({
    required List<T> from,
    required int count,
    List<int>? weights,
  }) {
    _checkNonNegative(count, 'count');
    if (from.isEmpty || count == 0) return <T>[];
    final w = weights ?? List<int>.filled(from.length, 1);
    if (w.length < from.length) {
      throw ArgumentError(
        'weights.length (${w.length}) must be >= from.length (${from.length})',
      );
    }
    final used = w.length == from.length ? w : w.sublist(0, from.length);
    _checkWeights(used);
    return List<T>.generate(count, (_) => _weightedChoice(from, used, rng));
  }
}
