part of '../rand.dart';

mixin _Collections {
  Random get rng;

  T element<T>(Iterable<T> from) {
    if (from.isEmpty) {
      throw StateError('Rand.element: cannot draw from empty iterable');
    }
    if (from is List<T>) {
      return from[rng.nextInt(from.length)];
    }
    return from.elementAt(rng.nextInt(from.length));
  }

  MapEntry<K, V> mapEntry<K, V>(Map<K, V> from) => element(from.entries);

  K mapKey<K, V>(Map<K, V> from) {
    if (from.isEmpty) {
      throw StateError('Rand.mapKey: cannot draw from empty map');
    }
    return from.keys.elementAt(rng.nextInt(from.length));
  }

  V mapValue<K, V>(Map<K, V> from) => from[mapKey(from)] as V;

  Set<T> subSet<T>(Set<T> from, int count) {
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

  T enumValue<T extends Enum>(List<T> values) => element(values);

  List<T> shuffled<T>(List<T> from) => List<T>.of(from)..shuffle(rng);
}
