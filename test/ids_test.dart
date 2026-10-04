import 'dart:math';

import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
final _t = DateTime.utc(2026, 10, 3, 12, 34, 56, 789);
final _v4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);
final _v7 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);
final _ulid = RegExp(r'^[0-7][0-9A-HJKMNP-TV-Z]{25}$');

int _uuidMs(String uuid) =>
    int.parse(uuid.replaceAll('-', '').substring(0, 12), radix: 16);

int _ulidMs(String ulid) {
  var ms = 0;
  for (final c in ulid.substring(0, 10).split('')) {
    ms = ms * 32 + _alphabet.indexOf(c);
  }
  return ms;
}

void main() {
  setUp(() => Rand.seed(42));

  group('uuidV4', () {
    test('2 000 draws are well-formed and distinct', () {
      final ids = List.generate(2000, (_) => Rand.uuidV4());
      for (final id in ids) {
        check(id).matchesPattern(_v4);
      }
      check(ids.toSet()).length.equals(ids.length);
    });
  });

  group('uuidV7', () {
    test('2 000 draws are well-formed and distinct', () {
      final ids = List.generate(2000, (_) => Rand.uuidV7());
      for (final id in ids) {
        check(id).matchesPattern(_v7);
      }
      check(ids.toSet()).length.equals(ids.length);
    });

    test('encodes time as a 48-bit big-endian Unix-ms prefix', () {
      final id = Rand.uuidV7(time: _t);
      check(id).startsWith('01a101c2-a895-7');
      check(_uuidMs(id)).equals(1791030896789);
    });

    test('defaults time to now', () {
      final before = DateTime.now().millisecondsSinceEpoch;
      final ms = _uuidMs(Rand.uuidV7());
      final after = DateTime.now().millisecondsSinceEpoch;
      check(ms)
        ..isGreaterOrEqual(before)
        ..isLessOrEqual(after);
    });

    test('throws outside the 48-bit Unix-ms range', () {
      check(() => Rand.uuidV7(time: DateTime.utc(1969)))
          .throws<ArgumentError>();
      check(
        () => Rand.uuidV7(
          time: DateTime.fromMillisecondsSinceEpoch(
            0x1000000000000,
            isUtc: true,
          ),
        ),
      ).throws<ArgumentError>();
    });
  });

  group('ulid', () {
    test('encodes time as 10 Crockford base32 chars', () {
      final id = Rand.ulid(time: _t);
      check(id)
        ..startsWith('01M40W5A4N')
        ..matchesPattern(_ulid);
      check(_ulidMs(id)).equals(_t.millisecondsSinceEpoch);
    });

    test('2 000 draws are well-formed and distinct', () {
      final ids = List.generate(2000, (_) => Rand.ulid());
      for (final id in ids) {
        check(id).matchesPattern(_ulid);
      }
      check(ids.toSet()).length.equals(ids.length);
    });

    test('the maximum 48-bit time encodes as 7ZZZZZZZZZ', () {
      final max = DateTime.fromMillisecondsSinceEpoch(
        0xFFFFFFFFFFFF,
        isUtc: true,
      );
      check(Rand.ulid(time: max)).startsWith('7ZZZZZZZZZ');
    });

    test('defaults time to now', () {
      final before = DateTime.now().millisecondsSinceEpoch;
      final ms = _ulidMs(Rand.ulid());
      final after = DateTime.now().millisecondsSinceEpoch;
      check(ms)
        ..isGreaterOrEqual(before)
        ..isLessOrEqual(after);
    });

    test('throws outside the 48-bit Unix-ms range', () {
      check(() => Rand.ulid(time: DateTime.utc(1969))).throws<ArgumentError>();
      check(
        () => Rand.ulid(
          time: DateTime.fromMillisecondsSinceEpoch(
            0x1000000000000,
            isUtc: true,
          ),
        ),
      ).throws<ArgumentError>();
    });
  });

  group('reproducibility', () {
    test('withSeed and RandGen replay the same IDs for a fixed time', () {
      List<String> draw(String Function() uuidV4, String Function() ulid) => [
        uuidV4(),
        ulid(),
      ];
      final a = Rand.withSeed(
        1,
        () => draw(Rand.uuidV4, () => Rand.ulid(time: _t)),
      );
      final b = Rand.withSeed(
        1,
        () => draw(Rand.uuidV4, () => Rand.ulid(time: _t)),
      );
      final gen = RandGen(Random(1));
      final c = draw(gen.uuidV4, () => gen.ulid(time: _t));
      check(a).deepEquals(b);
      check(a).deepEquals(c);
    });
  });
}
