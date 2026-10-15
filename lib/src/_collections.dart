part of '../rand.dart';

mixin _Collections {
  Random get rng;

  /// See [Rand.element].
  T element<T>(Iterable<T> from) {
    if (from.isEmpty) {
      throw StateError('Rand.element: cannot draw from empty iterable');
    }
    if (from is List<T>) {
      return from[rng.nextInt(from.length)];
    }
    return from.elementAt(rng.nextInt(from.length));
  }

  /// See [Rand.mapEntry].
  MapEntry<K, V> mapEntry<K, V>(Map<K, V> from) {
    if (from.isEmpty) {
      throw StateError('Rand.mapEntry: cannot draw from empty map');
    }
    return from.entries.elementAt(rng.nextInt(from.length));
  }

  /// See [Rand.mapKey].
  K mapKey<K, V>(Map<K, V> from) {
    if (from.isEmpty) {
      throw StateError('Rand.mapKey: cannot draw from empty map');
    }
    return from.keys.elementAt(rng.nextInt(from.length));
  }

  /// See [Rand.mapValue].
  V mapValue<K, V>(Map<K, V> from) {
    if (from.isEmpty) {
      throw StateError('Rand.mapValue: cannot draw from empty map');
    }
    return from.values.elementAt(rng.nextInt(from.length));
  }

  /// See [Rand.subset].
  Set<T> subset<T>(Set<T> from, {required int count}) {
    _checkNonNegative(count, 'count');
    if (count > from.length) {
      throw RangeError('count ($count) exceeds set size (${from.length})');
    }
    final list = from.toList();
    final result = <T>{};
    for (var i = 0; i < count; i++) {
      final idx = rng.nextInt(list.length - i);
      final picked = list[idx];
      result.add(picked);
      list[idx] = list[list.length - 1 - i];
    }
    return result;
  }

  /// See [Rand.enumValue].
  T enumValue<T extends Enum>(List<T> values) => element(values);

  /// See [Rand.shuffled].
  List<T> shuffled<T>(List<T> from) => List<T>.of(from)..shuffle(rng);
}
