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

  group('CSPRNG is lazy', () {
    test('seeded non-crypto generators work without touching the CSPRNG', () {
      check(() {
        Rand.seed(1);
        return Rand.integer(max: 10);
      }).returnsNormally();
    });
  });

  group('seed reporting', () {
    test('seed() picks a seed that seed(currentSeed) replays', () {
      Rand.seed();
      final seed = Rand.currentSeed;
      check(seed).isNotNull();
      final a = List.generate(20, (_) => Rand.integer());
      Rand.seed(seed);
      check(List.generate(20, (_) => Rand.integer())).deepEquals(a);
    });

    test('currentSeed reports the explicit seed', () {
      Rand.seed(1234);
      check(Rand.currentSeed).equals(1234);
    });

    test('currentSeed is null after useRng', () {
      Rand.useRng(Random(1));
      check(Rand.currentSeed).isNull();
    });
  });

  group('withSeed', () {
    test('draws equal a RandGen over Random(seed)', () {
      final gen = RandGen(Random(7));
      final expected = [gen.integer(), gen.fullName(), gen.email(), gen.hex()];
      final actual = Rand.withSeed(
        7,
        () => [Rand.integer(), Rand.fullName(), Rand.email(), Rand.hex()],
      );
      check(actual).deepEquals(expected);
    });

    test('leaves the global stream untouched', () {
      Rand.seed(42);
      final expected = [Rand.integer(), Rand.integer()];
      Rand.seed(42);
      final first = Rand.integer();
      Rand.withSeed(7, () => List.generate(10, (_) => Rand.integer()));
      check([first, Rand.integer()]).deepEquals(expected);
    });

    test('scope follows async continuations', () async {
      final gen = RandGen(Random(7));
      final expected = [gen.integer(), gen.integer()];
      final actual = await Rand.withSeed(7, () async {
        final a = Rand.integer();
        await Future<void>.delayed(Duration.zero);
        return [a, Rand.integer()];
      });
      check(actual).deepEquals(expected);
    });

    test('nested scope shadows the outer one', () {
      final outer = RandGen(Random(1));
      final inner = RandGen(Random(2));
      final expected = [outer.integer(), inner.integer(), outer.integer()];
      final seeds = <int?>[];
      final actual = Rand.withSeed(1, () {
        final a = Rand.integer();
        final b = Rand.withSeed(2, () {
          seeds.add(Rand.currentSeed);
          return Rand.integer();
        });
        seeds.add(Rand.currentSeed);
        return [a, b, Rand.integer()];
      });
      check(actual).deepEquals(expected);
      check(seeds).deepEquals([2, 1]);
    });

    test('seed inside a scope re-seeds only that scope', () {
      Rand.seed(42);
      final expected = Rand.integer();
      Rand.seed(42);
      Rand.withSeed(7, () {
        Rand.seed(3);
        check(Rand.currentSeed).equals(3);
      });
      check(Rand.currentSeed).equals(42);
      check(Rand.integer()).equals(expected);
    });
  });

  group('RandGen', () {
    test('equal seeds agree and other streams do not perturb them', () {
      final a = RandGen(Random(5));
      final b = RandGen(Random(5));
      final other = RandGen(Random(6));
      final xs = <Object>[];
      final ys = <Object>[];
      for (var i = 0; i < 50; i++) {
        xs.add(a.integer());
        other.fullName();
        Rand.integer();
        ys.add(b.integer());
      }
      check(xs).deepEquals(ys);
    });
  });
}
