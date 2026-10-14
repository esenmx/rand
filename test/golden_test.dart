// Pinned lorem strings exceed 80 columns.
// ignore_for_file: lines_longer_than_80_chars
import 'dart:math';

import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

enum _E { a, b, c, d }

final _pre1970 = DateTime.utc(1969, 12, 31, 23, 59, 59, 999, 990);
const _map = {'a': 1, 'b': 2, 'c': 3};
final _t = DateTime.utc(2026, 10, 3, 12, 34, 56, 789);

List<Object?> _n(int n, Object? Function() draw) =>
    List.generate(n, (_) => draw());

Object? _seeded(Object? Function() draw) {
  Rand.seed(42);
  return draw();
}

String _lit(Object? v) => switch (v) {
  final String s =>
    "'${s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll('\n', r'\n').replaceAll(r'$', r'\$')}'",
  final List<Object?> l => '[${l.map(_lit).join(', ')}]',
  _ => '$v',
};

final Map<String, Object? Function([RandGen?])> _draws = {
  'integer': ([g]) => _n(3, g == null ? Rand.integer : g.integer),
  'integerRange': ([g]) => _n(
    5,
    () => g == null
        ? Rand.integer(min: -10, max: 10)
        : g.integer(min: -10, max: 10),
  ),
  'float': ([g]) =>
      _n(3, () => g == null ? Rand.float(max: 1) : g.float(max: 1)),
  'floatDefault': ([g]) => _n(2, g == null ? Rand.float : g.float),
  'boolean': ([g]) => _n(8, g == null ? Rand.boolean : g.boolean),
  'nullable': ([g]) =>
      _n(6, () => g == null ? Rand.nullable(1) : g.nullable(1)),
  'latitude': ([g]) => _n(2, g == null ? Rand.latitude : g.latitude),
  'latitude0': ([g]) =>
      _n(4, () => g == null ? Rand.latitude(0) : g.latitude(0)),
  'longitude': ([g]) =>
      _n(2, () => g == null ? Rand.longitude(2) : g.longitude(2)),
  'geoPoint': ([g]) {
    final (:lat, :lng) = g == null ? Rand.geoPoint() : g.geoPoint();
    return [lat, lng];
  },
  'charCode': ([g]) => _n(8, g == null ? Rand.charCode : g.charCode),
  'semver': ([g]) => _n(2, g == null ? Rand.semver : g.semver),
  'otp': ([g]) => _n(2, g == null ? Rand.otp : g.otp),
  'duration': ([g]) => _n(
    3,
    () =>
        (g == null
                ? Rand.duration(max: const Duration(days: 30))
                : g.duration(max: const Duration(days: 30)))
            .inMicroseconds,
  ),
  'durationNegative': ([g]) => _n(
    8,
    () =>
        (g == null
                ? Rand.duration(
                    min: const Duration(microseconds: -10),
                    max: const Duration(microseconds: -5),
                  )
                : g.duration(
                    min: const Duration(microseconds: -10),
                    max: const Duration(microseconds: -5),
                  ))
            .inMicroseconds,
  ),
  'dateTime': ([g]) => _n(
    3,
    () => (g == null ? Rand.dateTime() : g.dateTime()).microsecondsSinceEpoch,
  ),
  'dateTimeRange': ([g]) => _n(
    3,
    () =>
        (g == null
                ? Rand.dateTime(DateTime.utc(2020), DateTime.utc(2025))
                : g.dateTime(DateTime.utc(2020), DateTime.utc(2025)))
            .microsecondsSinceEpoch,
  ),
  'datePre1970': ([g]) => _n(
    8,
    () =>
        (g == null
                ? Rand.dateTime(
                    _pre1970,
                    _pre1970.add(const Duration(microseconds: 5)),
                  )
                : g.dateTime(
                    _pre1970,
                    _pre1970.add(const Duration(microseconds: 5)),
                  ))
            .microsecondsSinceEpoch,
  ),
  'element': ([g]) => _n(
    4,
    () =>
        g == null ? Rand.element([1, 2, 3, 4, 5]) : g.element([1, 2, 3, 4, 5]),
  ),
  'elementSet': ([g]) => _n(
    4,
    () =>
        g == null ? Rand.element({'a', 'b', 'c'}) : g.element({'a', 'b', 'c'}),
  ),
  'mapEntry': ([g]) =>
      _n(2, () => (g == null ? Rand.mapEntry(_map) : g.mapEntry(_map)).key),
  'mapKey': ([g]) =>
      _n(2, () => g == null ? Rand.mapKey(_map) : g.mapKey(_map)),
  'mapValue': ([g]) =>
      _n(2, () => g == null ? Rand.mapValue(_map) : g.mapValue(_map)),
  'enumValue': ([g]) => _n(
    3,
    () => (g == null ? Rand.enumValue(_E.values) : g.enumValue(_E.values)).name,
  ),
  'shuffled': ([g]) => g == null
      ? Rand.shuffled(List.generate(10, (i) => i))
      : g.shuffled(List.generate(10, (i) => i)),
  'subSet': ([g]) =>
      (g == null
              ? Rand.subSet(Set.of(List.generate(10, (i) => i)), 4)
              : g.subSet(Set.of(List.generate(10, (i) => i)), 4))
          .toList(),
  'sample': ([g]) => g == null
      ? Rand.sample(from: ['a', 'b', 'c'], count: 10)
      : g.sample(from: ['a', 'b', 'c'], count: 10),
  'sampleWeighted': ([g]) => g == null
      ? Rand.sample(from: ['a', 'b', 'c'], count: 10, weights: [1, 10, 100])
      : g.sample(from: ['a', 'b', 'c'], count: 10, weights: [1, 10, 100]),
  'alias': ([g]) => _n(2, g == null ? Rand.alias : g.alias),
  'firstName': ([g]) => _n(2, g == null ? Rand.firstName : g.firstName),
  'lastName': ([g]) => _n(2, g == null ? Rand.lastName : g.lastName),
  'city': ([g]) => _n(2, g == null ? Rand.city : g.city),
  'fullName': ([g]) => _n(4, g == null ? Rand.fullName : g.fullName),
  'word': ([g]) => _n(3, g == null ? Rand.word : g.word),
  'words': ([g]) => g == null ? Rand.words(count: 4) : g.words(count: 4),
  'wordsDefault': ([g]) => g == null ? Rand.words() : g.words(),
  'sentence': ([g]) => g == null ? Rand.sentence() : g.sentence(),
  'sentences': ([g]) => g == null ? Rand.sentence(2) : g.sentence(2),
  'paragraph': ([g]) => g == null ? Rand.paragraph(2) : g.paragraph(2),
  'paragraphDefault': ([g]) => g == null ? Rand.paragraph() : g.paragraph(),
  'article': ([g]) => g == null ? Rand.article(1) : g.article(1),
  'articleDefault': ([g]) => g == null ? Rand.article() : g.article(),
  'slug': ([g]) => g == null ? Rand.slug() : g.slug(),
  'color': ([g]) => _n(3, () => (g == null ? Rand.color() : g.color()).name),
  'colorDark': ([g]) => (g == null ? Rand.colorDark() : g.colorDark()).name,
  'colorLight': ([g]) => (g == null ? Rand.colorLight() : g.colorLight()).name,
  'email': ([g]) => _n(8, g == null ? Rand.email : g.email),
  'ipv4': ([g]) => g == null ? Rand.ipv4() : g.ipv4(),
  'ipv6': ([g]) => g == null ? Rand.ipv6() : g.ipv6(),
  'mac': ([g]) => g == null ? Rand.mac() : g.mac(),
  'hex': ([g]) => g == null ? Rand.hex(length: 16) : g.hex(length: 16),
  'uuidV4': ([g]) => _n(2, g == null ? Rand.uuidV4 : g.uuidV4),
  'uuidV7': ([g]) => g == null ? Rand.uuidV7(time: _t) : g.uuidV7(time: _t),
  'ulid': ([g]) => g == null ? Rand.ulid(time: _t) : g.ulid(time: _t),
};

const Map<String, Object?> _golden = {
  'integer': [748325939, 523363758, 376088004],
  'integerRange': [3, 5, 2, -6, -4],
  'float': [0.15092545597797424, 0.6041479725361217, 0.6616810157870647],
  'floatDefault': [2.713176560875689e+307, 1.0860726626691728e+308],
  'boolean': [true, false, false, true, false, true, true, true],
  'nullable': [null, 1, 1, null, 1, null],
  'latitude': [-62.83342, 18.74664],
  'latitude0': [-63.0, 19.0, 29.0, -50.0],
  'longitude': [-125.67, 37.49],
  'geoPoint': [-62.83342, 37.49327],
  'charCode': [70, 119, 89, 120, 112, 89, 80, 102],
  'semver': ['7.8.4', '5.7.4'],
  'otp': ['784574', '550890'],
  'duration': [391198781894, 1565951544813, 1715077192920],
  'durationNegative': [-10, -7, -7, -9, -7, -10, -8, -10],
  'dateTime': [323873471530795, 1296451283951202, 1419912408018527],
  'dateTimeRange': [1601660805817400, 1673203249079150, 1682285001048832],
  'datePre1970': [-10, -7, -7, -9, -7, -10, -8, -10],
  'element': [3, 4, 5, 1],
  'elementSet': ['b', 'a', 'a', 'b'],
  'mapEntry': ['b', 'a'],
  'mapKey': ['b', 'a'],
  'mapValue': [2, 1],
  'enumValue': ['d', 'c', 'a'],
  'shuffled': [2, 0, 1, 5, 8, 3, 9, 4, 6, 7],
  'subSet': [7, 6, 4, 9],
  'sample': ['b', 'a', 'a', 'b', 'a', 'c', 'b', 'b', 'b', 'b'],
  'sampleWeighted': ['c', 'c', 'c', 'b', 'c', 'c', 'c', 'c', 'c', 'c'],
  'alias': ['Surge', 'Electra'],
  'firstName': ['Sophia', 'Maya'],
  'lastName': ['Gray', 'Powell'],
  'city': ['Rockhampton', 'London'],
  'fullName': [
    'Sophia Tran',
    'David Collins',
    'Nora Ramos James',
    'Noah Edwards',
  ],
  'word': ['dictumst', 'potenti', 'vivamus'],
  'words': 'dictumst potenti elit semper',
  'wordsDefault': 'potenti imperdiet placerat molestie lacus dapibus',
  'sentence': 'Congue nisi vitae suscipit tellus mauris a diam maecenas sed.',
  'sentences': 'Congue nisi vitae suscipit tellus mauris a diam maecenas sed. Feugiat vivamus at augue eget arcu.',
  'paragraph': 'Congue nisi vitae suscipit tellus mauris a diam maecenas sed. Enim facilisis gravida neque convallis a cras semper auctor neque.',
  'paragraphDefault': 'Enim facilisis gravida neque convallis a cras semper auctor neque. Cras semper auctor neque vitae. Sit amet venenatis urna cursus eget nunc scelerisque. Massa tincidunt dui ut ornare lectus sit amet est. Egestas dui id ornare arcu. Curabitur vitae nunc sed velit.',
  'article': 'Enim facilisis gravida neque convallis a cras semper auctor neque. Cras semper auctor neque vitae. Sit amet venenatis urna cursus eget nunc scelerisque. Massa tincidunt dui ut ornare lectus sit amet est. Egestas dui id ornare arcu. Curabitur vitae nunc sed velit.',
  'articleDefault': 'Cras semper auctor neque vitae. Sit amet venenatis urna cursus eget nunc scelerisque. Massa tincidunt dui ut ornare lectus sit amet est. Egestas dui id ornare arcu. Curabitur vitae nunc sed velit.\n\nTellus molestie nunc non blandit massa enim nec dui. Laoreet id donec ultrices tincidunt arcu non sodales neque. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Facilisi nullam vehicula ipsum a arcu cursus. Egestas erat imperdiet sed euismod nisi porta lorem mollis aliquam. Laoreet sit amet cursus sit amet dictum sit.\n\nFacilisi etiam dignissim diam quis enim. Scelerisque viverra mauris in aliquam. Dictumst quisque sagittis purus sit amet volutpat consequat mauris nunc. Laoreet id donec ultrices tincidunt. Tempus imperdiet nulla malesuada pellentesque. Dignissim diam quis enim lobortis scelerisque. Pulvinar etiam non quam lacus. Erat velit scelerisque in dictum non consectetur a erat nam. In pellentesque massa placerat duis ultricies lacus sed turpis. Enim nec dui nunc mattis enim ut tellus.\n\nCursus vitae congue mauris rhoncus aenean vel. At varius vel pharetra vel. In pellentesque massa placerat duis ultricies lacus sed turpis. Odio tempor orci dapibus ultrices. Nibh cras pulvinar mattis nunc sed blandit libero volutpat. Nunc sed id semper risus in. Metus vulputate eu scelerisque felis imperdiet.\n\nUltricies mi eget mauris pharetra et ultrices neque ornare aenean. Vel elit scelerisque mauris pellentesque. Aliquam faucibus purus in massa tempor nec feugiat nisl pretium. Velit euismod in pellentesque massa. Sit amet nisl suscipit adipiscing. Gravida cum sociis natoque penatibus et magnis dis parturient. Orci porta non pulvinar neque laoreet suspendisse interdum consectetur. Nunc sed velit dignissim sodales ut.',
  'slug': 'dictumst-potenti-elit',
  'color': ['yellowGreen', 'mediumPurple', 'darkGray'],
  'colorDark': 'saddleBrown',
  'colorLight': 'springGreen',
  'email': [
    'sophia61@mail.test',
    'david88@example.com',
    'nora83@example.com',
    'elena70@mail.test',
    'noah48@demo.test',
    'luke22@example.org',
    'ella69@mail.test',
    'michael69@example.com',
  ],
  'ipv4': '51.174.196.93',
  'ipv6': '3e4d:58fd:08f4:33da:797e:4af0:a4e0:0584',
  'mac': '3e:4d:58:fd:08:f4',
  'hex': '3e4d58fd08f433da',
  'uuidV4': [
    '33aec45d-b568-4f3d-b0b8-ffe433734d1a',
    'a759e7ae-a41a-4f20-9a64-6e50a0558894',
  ],
  'uuidV7': '01a101c2-a895-7f3d-b0b8-ffe433734d1a',
  'ulid': '01M40W5A4NKE4XN8FXGRZ4KKDT',
};

void main() {
  test('Rand.seed(42) reproduces the golden values', () {
    final actual = {
      for (final MapEntry(:key, :value) in _draws.entries) key: _seeded(value),
    };
    printOnFailure(
      [
        '{',
        for (final MapEntry(:key, :value) in actual.entries)
          "  '$key': ${_lit(value)},",
        '}',
      ].join('\n'),
    );
    check(actual).deepEquals(_golden);
  });

  test('Rand.withSeed(42, …) reproduces the golden values', () {
    final actual = {
      for (final MapEntry(:key, :value) in _draws.entries)
        key: Rand.withSeed(42, value),
    };
    check(actual).deepEquals(_golden);
  });

  test('RandGen(Random(42)) reproduces the golden values', () {
    final actual = {
      for (final MapEntry(:key, :value) in _draws.entries)
        key: value(RandGen(Random(42))),
    };
    check(actual).deepEquals(_golden);
  });

  test('RandGen.seeded(42) reproduces the golden values', () {
    final actual = {
      for (final MapEntry(:key, :value) in _draws.entries)
        key: value(RandGen.seeded(42)),
    };
    check(actual).deepEquals(_golden);
  });
}
