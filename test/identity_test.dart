import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

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
  });
}
