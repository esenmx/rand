import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  setUp(() => Rand.seed(42));

  group('Colors', () {
    test('color returns valid CssColors', () {
      for (var i = 0; i < 10; i++) {
        check(CssColors.values.contains(Rand.color())).isTrue();
      }
    });

    test('colorDark returns only dark colors', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.colorDark().isDark).isTrue();
      }
    });

    test('colorLight returns only light colors', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.colorLight().isDark).isFalse();
      }
    });

    test('CssColors exposes argb', () {
      check(CssColors.coral.argb).equals(0xFFFF7F50);
      check(CssColors.aliceBlue.argb).equals(0xFFF0F8FF);
    });

    test('every CssColors value is opaque', () {
      for (final c in CssColors.values) {
        check(c.argb ~/ 0x1000000, because: c.name).equals(0xFF);
      }
    });

    test('CssColors.compareTo orders by index', () {
      final sorted = Rand.shuffled(CssColors.values)..sort();
      check(sorted).deepEquals(CssColors.values);
    });

    test('CssColorsX.isDark classifies extremes correctly', () {
      check(CssColors.black.isDark).isTrue();
      check(CssColors.white.isDark).isFalse();
      check(CssColors.navy.isDark).isTrue();
      check(CssColors.ivory.isDark).isFalse();
    });
  });
}
