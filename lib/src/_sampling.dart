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
    if (from.isEmpty) return <T>[];
    if (weights == null) {
      if (count == 0) return <T>[];
      return List<T>.generate(count, (_) => from[rng.nextInt(from.length)]);
    }
    if (weights.length < from.length) {
      throw ArgumentError(
        'weights.length (${weights.length}) must be >= '
            'from.length (${from.length})',
        'weights',
      );
    }
    final used = weights.length == from.length
        ? weights
        : weights.sublist(0, from.length);
    final total = _checkWeights(used);
    if (count == 0) return <T>[];
    return List<T>.generate(
      count,
      (_) => _weightedChoice(from, used, total, rng),
    );
  }
}
