import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  // Set seed for reproducible tests
  setUp(() => Rand.seed(42));

  group('Generic', () {
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

    test('nullable returns value or null based on probability', () {
      var nullCount = 0;
      for (var i = 0; i < 1000; i++) {
        if (Rand.nullable('value') == null) nullCount++;
      }
      check(nullCount).isGreaterThan(400);
      check(nullCount).isLessThan(600);
    });
  });

  group('Numeric', () {
    test('integer returns value in range', () {
      check(Rand.integer(min: 5, max: 5)).equals(5);
      check(Rand.integer()).isA<int>();
      check(Rand.integer(max: 1)).isA<int>();
      check(Rand.integer(min: 1, max: 2)).isA<int>();
      check(Rand.integer(min: -1, max: 1)).isA<int>();
    });

    test('integer throws on invalid range', () {
      check(() => Rand.integer(min: 2, max: 1)).throws<ArgumentError>();
    });

    test('float returns value in range', () {
      for (var i = 0; i < 100; i++) {
        final f = Rand.float(min: 10, max: 20);
        check(f).isGreaterOrEqual(10);
        check(f).isLessThan(20);
      }
    });

    test('float throws on invalid range', () {
      check(() => Rand.float(min: 20, max: 10)).throws<ArgumentError>();
    });

    test('latitude returns valid range', () {
      for (var i = 0; i < 100; i++) {
        final lat = Rand.latitude();
        check(lat).isGreaterOrEqual(-90);
        check(lat).isLessOrEqual(90);
      }
    });

    test('longitude returns valid range', () {
      for (var i = 0; i < 100; i++) {
        final lng = Rand.longitude();
        check(lng).isGreaterOrEqual(-180);
        check(lng).isLessOrEqual(180);
      }
    });

    test('char returns base62 character', () {
      for (var i = 0; i < 1000; i++) {
        final char = Rand.char();
        check(Rand.base62.contains(String.fromCharCode(char))).isTrue();
        final charSecure = Rand.charSecure();
        check(Rand.base62.contains(String.fromCharCode(charSecure))).isTrue();
      }
    });

    test('bytes returns correct length', () {
      check(Rand.bytes(0)).length.equals(0);
      check(Rand.bytes(10)).length.equals(10);
      check(Rand.bytes(100)).length.equals(100);
      check(Rand.bytes(10, true)).length.equals(10); // secure
    });
  });

  group('Cryptographic', () {
    test('nonce returns correct length', () {
      for (var i = 0; i < 100; i++) {
        final len = Rand.integer(max: 100);
        check(Rand.nonce(len)).length.equals(len);
      }
    });

    test('id returns correct length', () {
      check(Rand.id()).length.equals(16); // default
      check(Rand.id(8)).length.equals(8);
      check(Rand.id(32)).length.equals(32);
    });

    test('password returns correct length and respects options', () {
      check(Rand.password()).length.equals(12); // default
      check(Rand.password(length: 20)).length.equals(20);

      // Only lowercase
      final lower = Rand.password(
        withUppercase: false,
        withNumeric: false,
        withSpecial: false,
      );
      check(lower.toLowerCase()).equals(lower);

      // Only uppercase
      final upper = Rand.password(
        withLowercase: false,
        withNumeric: false,
        withSpecial: false,
      );
      check(upper.toUpperCase()).equals(upper);
    });

    test('password throws on invalid length', () {
      check(() => Rand.password(length: 3)).throws<ArgumentError>();
    });

    test('password throws when all charsets disabled', () {
      check(
        () => Rand.password(
          withLowercase: false,
          withUppercase: false,
          withNumeric: false,
          withSpecial: false,
        ),
      ).throws<ArgumentError>();
    });
  });

  group('Time/Duration', () {
    final minEpoch = DateTime.utc(1970).microsecondsSinceEpoch;
    final maxEpoch = DateTime.utc(2038).microsecondsSinceEpoch;

    test('duration returns value in range', () {
      const max = Duration(days: 30);
      const min = Duration(days: 1);
      for (var i = 0; i < 100; i++) {
        final d = Rand.duration(max, min);
        check(d.inMicroseconds).isLessThan(max.inMicroseconds);
        check(d.inMicroseconds).isGreaterThan(min.inMicroseconds);
      }
    });

    test('dateTime returns value in default range', () {
      for (var i = 0; i < 100; i++) {
        final dt = Rand.dateTime();
        check(dt.microsecondsSinceEpoch).isGreaterThan(minEpoch);
        check(dt.microsecondsSinceEpoch).isLessThan(maxEpoch);
      }
    });

    test('dateTimeYear returns value in range', () {
      check(Rand.dateTimeYear(2000, 2000)).equals(DateTime(2000));
      for (var i = 0; i < 100; i++) {
        final dt = Rand.dateTimeYear(1970, 2038);
        check(dt.microsecondsSinceEpoch).isGreaterThan(minEpoch);
        check(dt.microsecondsSinceEpoch).isLessThan(maxEpoch);
      }
    });
  });

  group('Collection', () {
    test('element returns item from collection', () {
      final list = [1, 2, 3, 4, 5];
      for (var i = 0; i < 100; i++) {
        check(list.contains(Rand.element(list))).isTrue();
      }
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

    test('mapValue returns value from map', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      for (var i = 0; i < 100; i++) {
        check(map.containsValue(Rand.mapValue(map))).isTrue();
      }
    });

    test('subSet returns unique elements', () {
      check(Rand.subSet(<int>[], 0)).isEmpty();
      check(Rand.subSet([1, 2, 2, 3, 3, 3], 3)).deepEquals({1, 2, 3});

      final array = List.generate(100, (i) => i).toSet();
      check(Rand.subSet(array, 100)).length.equals(100);
      check(Rand.subSet(array, 50)).length.equals(50);
    });

    test('subSet throws when not enough unique elements', () {
      check(() => Rand.subSet([1, 2, 2], 3)).throws<RangeError>();
    });
  });

  group('Text', () {
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

    test('word returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.word()).isNotEmpty();
      }
    });

    test('words returns correct count', () {
      check(Rand.words(count: 5).split(' ')).length.equals(5);
      check(Rand.words(count: 10, separator: '-').split('-')).length.equals(10);
    });

    test('sentence returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.sentence()).isNotEmpty();
      }
    });

    test('paragraph returns multiple sentences', () {
      final p = Rand.paragraph(5);
      check(p).isNotEmpty();
      check(p.split('. ').length).isGreaterOrEqual(5);
    });

    test('article returns multiple paragraphs', () {
      final a = Rand.article(3);
      check(a).isNotEmpty();
      check(a.split('\n\n').length).isGreaterOrEqual(3);
    });
  });

  group('Miscellaneous', () {
    test('city returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.city()).isNotEmpty();
      }
    });

    test('color returns valid CSSColors', () {
      for (var i = 0; i < 10; i++) {
        check(CSSColors.values.contains(Rand.color())).isTrue();
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
  });

  group('Probability', () {
    test('weightedRandomizedArray returns weighted distribution', () {
      for (var i = 0; i < 100; i++) {
        final result = Rand.weightedRandomizedArray(
          weights: [1, 10, 100],
          pool: ['rare', 'common', 'veryCommon'],
          size: 1110,
        );
        final rare = result.where((e) => e == 'rare').length;
        final common = result.where((e) => e == 'common').length;
        final veryCommon = result.where((e) => e == 'veryCommon').length;
        // Verify ordering: rare < common < veryCommon
        check(rare).isLessOrEqual(common);
        check(common).isLessOrEqual(veryCommon);
      }
    });

    test('weightedRandomizedArray handles empty inputs', () {
      check(
        Rand.weightedRandomizedArray(weights: [1], pool: <int>[], size: 10),
      ).isEmpty();
      check(
        Rand.weightedRandomizedArray(weights: [1], pool: [1], size: 0),
      ).isEmpty();
    });

    test('weightedRandomizedArray throws on mismatched lengths', () {
      check(
        () => Rand.weightedRandomizedArray(weights: [1], pool: [1, 2], size: 1),
      ).throws<ArgumentError>();
    });
  });
}
