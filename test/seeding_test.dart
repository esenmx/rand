import 'dart:math';

import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  setUp(() => Rand.seed(42));

  group('useRng / seed', () {
    test('same seed produces same sequence', () {
      Rand.seed(42);
      final a = List.generate(100, (_) => Rand.integer(max: 1 << 20));
      Rand.seed(42);
      final b = List.generate(100, (_) => Rand.integer(max: 1 << 20));
      check(a).deepEquals(b);
    });

    test('different seeds produce different sequences', () {
      Rand.seed(42);
      final a = List.generate(100, (_) => Rand.integer(max: 1 << 20));
      Rand.seed(43);
      final b = List.generate(100, (_) => Rand.integer(max: 1 << 20));
      check(a).not((it) => it.deepEquals(b));
    });

    test('useRng(Random(N)) is observably equivalent to seed(N)', () {
      Rand.seed(42);
      final a = List.generate(50, (_) => Rand.integer(max: 1 << 20));
      Rand.useRng(Random(42));
      final b = List.generate(50, (_) => Rand.integer(max: 1 << 20));
      check(a).deepEquals(b);
    });
  });
}
