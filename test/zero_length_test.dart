import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  setUp(() => Rand.seed(42));

  test('counts accept 0 and return an empty result', () {
    check(Rand.bytes(length: 0)).isEmpty();
    check(Rand.words(count: 0)).equals('');
    check(Rand.sentence(count: 0)).equals('');
    check(Rand.paragraph(count: 0)).equals('');
    check(Rand.article(count: 0)).equals('');
    check(Rand.subset({1, 2}, count: 0)).isEmpty();
    check(Rand.sample([1, 2], count: 0)).isEmpty();
  });

  test('single-token generators reject a length below 1', () {
    for (final (call, name) in <(Object? Function(), String)>[
      (() => Rand.nonce(length: 0), 'length'),
      (() => Rand.hex(length: 0), 'length'),
      (() => Rand.digits(length: 0), 'length'),
      (() => Rand.base64(byteLength: 0), 'byteLength'),
      (() => Rand.slug(wordCount: 0), 'wordCount'),
    ]) {
      check(call)
          .throws<ArgumentError>()
          .has((e) => e.name, 'name')
          .equals(name);
    }
  });
}
