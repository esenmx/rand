import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  setUp(() => Rand.seed(42));

  group('Time', () {
    final minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
    final maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

    test('duration returns value in [min, max)', () {
      const max = Duration(days: 30);
      const min = Duration(days: 1);
      for (var i = 0; i < 100; i++) {
        final d = Rand.duration(min: min, max: max);
        check(d.inMicroseconds).isGreaterOrEqual(min.inMicroseconds);
        check(d.inMicroseconds).isLessThan(max.inMicroseconds);
      }
    });

    test('dateTime returns value in default range', () {
      for (var i = 0; i < 100; i++) {
        final dt = Rand.dateTime();
        check(dt.microsecondsSinceEpoch).isGreaterOrEqual(minEpoch);
        check(dt.microsecondsSinceEpoch).isLessThan(maxEpoch);
        check(dt.isUtc).isTrue();
      }
    });
  });
}
