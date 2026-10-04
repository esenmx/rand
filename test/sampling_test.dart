import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  setUp(() => Rand.seed(42));

  group('Sampling', () {
    test('sample without weights uses equal probability', () {
      final result = Rand.sample(from: [1, 2, 3], count: 100);
      check(result).length.equals(100);
      check(result.every((e) => [1, 2, 3].contains(e))).isTrue();
    });

    test('sample with weights respects ratios', () {
      Rand.seed(42);
      final result = Rand.sample(
        from: ['a', 'b', 'c'],
        count: 100000,
        weights: [1, 10, 100],
      );
      final a = result.where((e) => e == 'a').length;
      final b = result.where((e) => e == 'b').length;
      final c = result.where((e) => e == 'c').length;
      // 1:10:100 → a ≈ 900, b ≈ 9009, c ≈ 90090. Wide tolerance.
      check(a).isLessThan(b);
      check(b).isLessThan(c);
      check(a / b).isGreaterOrEqual(0.05);
      check(a / b).isLessOrEqual(0.20);
      check(b / c).isGreaterOrEqual(0.05);
      check(b / c).isLessOrEqual(0.20);
    });

    test('sample handles empty inputs', () {
      check(Rand.sample(from: <int>[], count: 10)).isEmpty();
      check(Rand.sample(from: [1], count: 0)).isEmpty();
    });

    test('sample throws on mismatched weights length', () {
      check(() => Rand.sample(from: [1, 2], count: 1, weights: [1]))
          .throws<ArgumentError>();
    });

    test('sample ignores weights beyond from.length', () {
      final result = Rand.sample(from: [1], count: 200, weights: [1, 1000]);
      check(result.every((e) => e == 1)).isTrue();
    });

    test('sample returns a growable list when from is empty', () {
      final empty = Rand.sample(from: <int>[], count: 3);
      check(() => empty.add(1)).returnsNormally();
    });

    test('sample rejects all-zero weights naming weights', () {
      check(() => Rand.sample(from: ['a', 'b'], count: 1, weights: [0, 0]))
          .throws<ArgumentError>()
          .has((e) => '${e.message}', 'message')
          .contains('weights');
    });

    test('sample rejects negative weights', () {
      check(
        () =>
            Rand.sample(from: ['a', 'b', 'c'], count: 10, weights: [3, -5, 10]),
      ).throws<ArgumentError>();
    });

    test('sample rejects weights summing past 2^32', () {
      check(
        () => Rand.sample(from: ['a', 'b'], count: 1, weights: [4294967296, 1]),
      ).throws<ArgumentError>();
    });
  });
}
