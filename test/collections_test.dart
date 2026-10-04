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

    test('element throws StateError on empty', () {
      check(() => Rand.element(<int>[])).throws<StateError>();
    });

    test('mapEntry returns entry from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        final entry = Rand.mapEntry(map);
        check(map.containsKey(entry.key)).isTrue();
        check(map[entry.key]).equals(entry.value);
      }
    });

    test('mapKey returns key from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        check(map.containsKey(Rand.mapKey(map))).isTrue();
      }
    });

    test('mapKey throws StateError on empty', () {
      check(() => Rand.mapKey(<String, int>{})).throws<StateError>();
    });

    test('mapValue returns value from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        check(map.containsValue(Rand.mapValue(map))).isTrue();
      }
    });

    test('subSet returns unique elements', () {
      check(Rand.subSet(<int>{}, 0)).isEmpty();

      final pool = List.generate(100, (i) => i).toSet();
      check(Rand.subSet(pool, 100)).length.equals(100);
      check(Rand.subSet(pool, 50)).length.equals(50);
    });

    test('subSet throws when count exceeds set size', () {
      check(() => Rand.subSet({1, 2}, 3)).throws<RangeError>();
    });

    test('subSet rejects a negative count', () {
      check(() => Rand.subSet({1, 2, 3}, -1))
          .throws<ArgumentError>()
          .has((e) => '${e.message}', 'message')
          .contains('count must be >= 0');
    });

    test('subSet is uniform: each of 10 lands in a 3-subset ~30%', () {
      Rand.seed(8);
      final pool = Set.of(List.generate(10, (i) => i));
      final hits = List.filled(10, 0);
      const n = 100000;
      for (var i = 0; i < n; i++) {
        for (final x in Rand.subSet(pool, 3)) {
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
      final a = Rand.shuffled(List.generate(20, (i) => i));
      Rand.seed(42);
      final b = Rand.shuffled(List.generate(20, (i) => i));
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
  });
}
