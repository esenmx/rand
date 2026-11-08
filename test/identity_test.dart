import 'dart:math';

import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

final class _TopOfRange implements Random {
  int _draws = 0;

  @override
  int nextInt(int max) {
    if (++_draws > 1000000) throw TestFailure('redraws never stopped');
    return max - 1;
  }

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => throw UnsupportedError('nextBool');
}

void main() {
  setUp(() => Rand.seed(42));

  group('Identity', () {
    test('alias returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.alias()).isNotEmpty();
      }
    });

    test('firstName returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.firstName()).isNotEmpty();
      }
    });

    test('lastName returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.lastName()).isNotEmpty();
      }
    });

    test('fullName contains at least first and last name', () {
      for (var i = 0; i < 10; i++) {
        final name = Rand.fullName();
        check(name).isNotEmpty();
        check(name.split(' ').length).isGreaterOrEqual(2);
      }
    });

    test('city returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.city()).isNotEmpty();
      }
    });

    test('fullName never repeats a name', () {
      Rand.seed(1);
      for (var i = 0; i < 50000; i++) {
        final parts = Rand.fullName().split(' ');
        check(
          parts.toSet(),
          because: parts.join(' '),
        ).length.equals(parts.length);
      }
    });

    test('fullName throws when the RNG cannot produce an unused name', () {
      check(() => RandGen(_TopOfRange()).fullName())
          .throws<StateError>()
          .has((e) => e.message, 'message')
          .contains('Rand.fullName');
    });
  });
}
