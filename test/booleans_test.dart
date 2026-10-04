import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  setUp(() => Rand.seed(42));

  group('Boolean & Nullable', () {
    test('boolean returns true/false based on probability', () {
      var trueCount = 0;
      var falseCount = 0;
      for (var i = 0; i < 10000; i++) {
        if (Rand.boolean(99)) trueCount++;
        if (!Rand.boolean(1)) falseCount++;
      }
      check(trueCount).isGreaterThan(9700);
      check(falseCount).isGreaterThan(9700);
    });

    test('boolean throws on invalid probability', () {
      check(() => Rand.boolean(-1)).throws<ArgumentError>();
      check(() => Rand.boolean(101)).throws<ArgumentError>();
    });

    test('boolean and nullable reject a NaN chance', () {
      check(() => Rand.boolean(double.nan)).throws<ArgumentError>();
      check(() => Rand.nullable(1, double.nan)).throws<ArgumentError>();
    });

    test('boolean respects double-precision probabilities', () {
      var trueCount = 0;
      for (var i = 0; i < 10000; i++) {
        if (Rand.boolean(0.1)) trueCount++;
      }
      check(trueCount).isLessThan(50);
    });

    test('nullable returns value or null based on probability', () {
      var nullCount = 0;
      for (var i = 0; i < 1000; i++) {
        if (Rand.nullable('value') == null) nullCount++;
      }
      check(nullCount).isGreaterThan(400);
      check(nullCount).isLessThan(600);
    });
  });
}
