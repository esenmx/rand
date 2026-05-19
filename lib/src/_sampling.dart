part of '../rand.dart';

mixin _Sampling {
  Random get rng;

  List<T> sample<T>({
    required List<T> from,
    required int count,
    List<int>? weights,
  }) {
    if (from.isEmpty || count == 0) return const [];
    final w = weights ?? List<int>.filled(from.length, 1);
    if (w.length < from.length) {
      throw ArgumentError(
        'weights.length (${w.length}) must be >= from.length (${from.length})',
      );
    }
    return List<T>.generate(count, (_) => _weightedChoice(from, w, rng));
  }
}
