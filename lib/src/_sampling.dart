part of '../rand.dart';

mixin _Sampling {
  Random get rng;

  /// See [Rand.sample].
  List<T> sample<T>({
    required List<T> from,
    required int count,
    List<int>? weights,
  }) {
    _checkNonNegative(count, 'count');
    if (weights != null && weights.length != from.length) {
      throw ArgumentError(
        'weights.length (${weights.length}) must equal '
            'from.length (${from.length})',
        'weights',
      );
    }
    if (from.isEmpty) {
      if (count == 0) return <T>[];
      throw StateError('Rand.sample: cannot draw from empty list');
    }
    if (weights == null) {
      if (count == 0) return <T>[];
      return List<T>.generate(count, (_) => from[rng.nextInt(from.length)]);
    }
    final total = _checkWeights(weights);
    if (count == 0) return <T>[];
    return List<T>.generate(
      count,
      (_) => _weightedChoice(from, weights, total, rng),
    );
  }
}
