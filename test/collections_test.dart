import 'dart:collection';

import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

enum _TestEnum { alpha, beta, gamma, delta }

void main() {
  setUp(() => Rand.seed(42));

  group('Collections', () {
    test('element returns item from collection', () {
      final list = [1, 2, 3, 4, 5];
      for (var i = 0; i < 100; i++) {
        check(list.contains(Rand.element(list))).isTrue();
      }
    });

    test('element returns item from non-List Iterable', () {
      final set = {1, 2, 3};
      for (var i = 0; i < 50; i++) {
        check(set.contains(Rand.element(set))).isTrue();
      }
    });

    test('element throws StateError on empty', () {
      check(() => Rand.element(<int>[]))
          .throws<StateError>()
          .has((e) => e.message, 'message')
          .contains('Rand.element');
    });

    test('mapEntry returns entry from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        final entry = Rand.mapEntry(map);
        check(map.containsKey(entry.key)).isTrue();
        check(map[entry.key]).equals(entry.value);
      }
    });

    test('mapEntry throws StateError naming Rand.mapEntry on empty', () {
      check(() => Rand.mapEntry(<String, int>{}))
          .throws<StateError>()
          .has((e) => e.message, 'message')
          .contains('Rand.mapEntry');
    });

    test('mapKey returns key from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        check(map.containsKey(Rand.mapKey(map))).isTrue();
      }
    });

    test('mapKey throws StateError on empty', () {
      check(() => Rand.mapKey(<String, int>{}))
          .throws<StateError>()
          .has((e) => e.message, 'message')
          .contains('Rand.mapKey');
    });

    test('mapValue returns value from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        check(map.containsValue(Rand.mapValue(map))).isTrue();
      }
    });

    test('mapValue works when map has a NaN key', () {
      check(Rand.mapValue({double.nan: 'a'})).equals('a');
    });

    test('mapValue throws StateError naming Rand.mapValue on empty', () {
      check(() => Rand.mapValue(<String, int>{}))
          .throws<StateError>()
          .has((e) => e.message, 'message')
          .contains('Rand.mapValue');
    });

    test('sample validates weights even when count is 0', () {
      for (final weights in [
        [1],
        [-1, 1],
        [0, 0],
      ]) {
        check(() => Rand.sample(['a', 'b'], count: 0, weights: weights))
            .throws<ArgumentError>()
            .has((e) => e.name, 'name')
            .equals('weights');
      }
    });

    test('subset returns unique elements', () {
      check(Rand.subset(<int>{}, count: 0)).isEmpty();

      final pool = List.generate(100, (i) => i).toSet();
      check(Rand.subset(pool, count: 100)).length.equals(100);
      check(Rand.subset(pool, count: 50)).length.equals(50);
    });

    test('subset throws when count exceeds set size', () {
      check(() => Rand.subset({1, 2}, count: 3)).throws<RangeError>();
    });

    test('subset rejects a negative count', () {
      check(() => Rand.subset({1, 2, 3}, count: -1))
          .throws<ArgumentError>()
          .has((e) => '${e.message}', 'message')
          .contains('count must be >= 0');
    });

    test('subset is uniform: each of 10 lands in a 3-subset ~30%', () {
      Rand.seed(8);
      final pool = Set.of(List.generate(10, (i) => i));
      final hits = List.filled(10, 0);
      const n = 100000;
      for (var i = 0; i < n; i++) {
        for (final x in Rand.subset(pool, count: 3)) {
          hits[x]++;
        }
      }
      for (final h in hits) {
        check(h / n).isCloseTo(0.3, 0.01);
      }
    });

    test('enumValue returns a member of the enum', () {
      for (var i = 0; i < 50; i++) {
        check(_TestEnum.values.contains(Rand.enumValue(_TestEnum.values)))
            .isTrue();
      }
    });

    test('shuffled returns same elements in a different order', () {
      final input = List.generate(50, (i) => i);
      final out = Rand.shuffled(input);
      check(out).length.equals(input.length);
      check(out.toSet()).deepEquals(input.toSet());
      check(out).not((it) => it.deepEquals(input));
    });

    test('shuffled does not mutate input', () {
      final input = [1, 2, 3, 4, 5];
      final snapshot = List<int>.of(input);
      Rand.shuffled(input);
      check(input).deepEquals(snapshot);
    });

    test('shuffled is reproducible under seed', () {
      Rand.seed(42);
      final a = Rand.shuffled(.generate(20, (i) => i));
      Rand.seed(42);
      final b = Rand.shuffled(.generate(20, (i) => i));
      check(a).deepEquals(b);
    });

    test('shuffled is uniform: position of element 0', () {
      Rand.seed(8);
      final pos = List.filled(6, 0);
      const n = 120000;
      for (var i = 0; i < n; i++) {
        pos[Rand.shuffled([0, 1, 2, 3, 4, 5]).indexOf(0)]++;
      }
      for (final p in pos) {
        check(p / n).isCloseTo(1 / 6, 0.01);
      }
    });

    test('subset keeps the equality of an identity set', () {
      final equalButDistinct = List.generate(3, (_) => DateTime.utc(2026));
      final picked = Rand.subset(
        Set<DateTime>.identity()..addAll(equalButDistinct),
        count: 3,
      );
      check(picked).length.equals(3);
      check(picked.add(equalButDistinct.first)).isFalse();
      check(picked.add(.utc(2026))).isTrue();
    });

    test('subset keeps the equality of a custom-equality set', () {
      final source = LinkedHashSet<String>(
        equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
        hashCode: (s) => s.toLowerCase().hashCode,
      )..addAll(['a', 'b', 'c']);
      final picked = Rand.subset(source, count: 3);
      check(picked).length.equals(3);
      check(picked.contains('A')).isTrue();
    });

    test('subset keeps the ordering of a sorted set', () {
      final source = SplayTreeSet<int>((a, b) => b.compareTo(a))
        ..addAll([1, 2, 3, 4, 5]);
      final picked = Rand.subset(source, count: 3).toList();
      check(picked).deepEquals(source.where(picked.contains));
    });

    test('subset of an unmodifiable set returns a modifiable set', () {
      for (final source in [
        const {1, 2, 3},
        Set<int>.unmodifiable([1, 2, 3]),
        UnmodifiableSetView({1, 2, 3}),
      ]) {
        final picked = Rand.subset(source, count: 2);
        check(picked).length.equals(2);
        check(picked.add(4)).isTrue();
      }
    });
  });
}
