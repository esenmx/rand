// Pinned lorem strings exceed 80 columns.
// ignore_for_file: lines_longer_than_80_chars
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
    "'${s.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'",
  final List<Object?> l => '[${l.map(_lit).join(', ')}]',
  _ => '$v',
};

final Map<String, Object? Function()> _draws = {
  'integer': () => _n(3, Rand.integer),
  'integerRange': () => _n(5, () => Rand.integer(min: -10, max: 10)),
  'float': () => _n(3, () => Rand.float(max: 1)),
  'floatDefault': () => _n(2, Rand.float),
  'boolean': () => _n(8, Rand.boolean),
  'nullable': () => _n(6, () => Rand.nullable(1)),
  'latitude': () => _n(2, Rand.latitude),
  'latitude0': () => _n(4, () => Rand.latitude(0)),
  'longitude': () => _n(2, () => Rand.longitude(2)),
  'geoPoint': () {
    final (:lat, :lng) = Rand.geoPoint();
    return [lat, lng];
  },
  'charCode': () => _n(8, Rand.charCode),
  'semver': () => _n(2, Rand.semver),
  'otp': () => _n(2, Rand.otp),
  'duration': () =>
      _n(3, () => Rand.duration(max: const Duration(days: 30)).inMicroseconds),
  'durationNegative': () => _n(
    8,
    () => Rand.duration(
      min: const Duration(microseconds: -10),
      max: const Duration(microseconds: -5),
    ).inMicroseconds,
  ),
  'dateTime': () => _n(3, () => Rand.dateTime().microsecondsSinceEpoch),
  'dateTimeRange': () => _n(
    3,
    () => Rand.dateTime(
      DateTime.utc(2020),
      DateTime.utc(2025),
    ).microsecondsSinceEpoch,
  ),
  'datePre1970': () => _n(
    8,
    () => Rand.dateTime(
      _pre1970,
      _pre1970.add(const Duration(microseconds: 5)),
    ).microsecondsSinceEpoch,
  ),
  'element': () => _n(4, () => Rand.element([1, 2, 3, 4, 5])),
  'elementSet': () => _n(4, () => Rand.element({'a', 'b', 'c'})),
  'mapEntry': () => _n(2, () => Rand.mapEntry(_map).key),
  'mapValue': () => _n(2, () => Rand.mapValue(_map)),
  'enumValue': () => _n(3, () => Rand.enumValue(_E.values).name),
  'shuffled': () => Rand.shuffled(List.generate(10, (i) => i)),
  'subSet': () => Rand.subSet(Set.of(List.generate(10, (i) => i)), 4).toList(),
  'sample': () => Rand.sample(from: ['a', 'b', 'c'], count: 10),
  'sampleWeighted': () =>
      Rand.sample(from: ['a', 'b', 'c'], count: 10, weights: [1, 10, 100]),
  'alias': () => _n(2, Rand.alias),
  'firstName': () => _n(2, Rand.firstName),
  'lastName': () => _n(2, Rand.lastName),
  'city': () => _n(2, Rand.city),
  'fullName': () => _n(4, Rand.fullName),
  'word': () => _n(3, Rand.word),
  'words': () => Rand.words(count: 4),
  'sentence': Rand.sentence,
  'sentences': () => Rand.sentence(2),
  'paragraph': () => Rand.paragraph(2),
  'article': () => Rand.article(1),
  'slug': Rand.slug,
  'color': () => _n(3, () => Rand.color().name),
  'colorDark': () => Rand.colorDark().name,
  'colorLight': () => Rand.colorLight().name,
  'email': () => _n(8, Rand.email),
  'ipv4': Rand.ipv4,
  'ipv6': Rand.ipv6,
  'mac': Rand.mac,
  'hex': () => Rand.hex(length: 16),
  'uuidV4': () => _n(2, Rand.uuidV4),
  'uuidV7': () => Rand.uuidV7(time: _t),
  'ulid': () => Rand.ulid(time: _t),
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
  'durationNegative': [-9, -6, -6, -8, -6, -9, -7, -9],
  'dateTime': [323873471530795, 1296451283951202, 1419912408018527],
  'dateTimeRange': [1601660805817400, 1673203249079150, 1682285001048832],
  'datePre1970': [-9, -6, -6, -8, -6, -9, -7, -9],
  'element': [3, 4, 5, 1],
  'elementSet': ['b', 'a', 'a', 'b'],
  'mapEntry': ['b', 'a'],
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
  'sentence': 'Congue nisi vitae suscipit tellus mauris a diam maecenas sed.',
  'sentences': 'Congue nisi vitae suscipit tellus mauris a diam maecenas sed. Feugiat vivamus at augue eget arcu.',
  'paragraph': 'Congue nisi vitae suscipit tellus mauris a diam maecenas sed. Enim facilisis gravida neque convallis a cras semper auctor neque.',
  'article': 'Enim facilisis gravida neque convallis a cras semper auctor neque. Cras semper auctor neque vitae. Sit amet venenatis urna cursus eget nunc scelerisque. Massa tincidunt dui ut ornare lectus sit amet est. Egestas dui id ornare arcu. Curabitur vitae nunc sed velit.',
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
}
