import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  setUp(() => Rand.seed(42));

  group('Text', () {
    test('word returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.word()).isNotEmpty();
      }
    });

    test('words returns correct count', () {
      check(Rand.words(count: 5).split(' ')).length.equals(5);
      check(Rand.words(count: 10, separator: '-').split('-')).length.equals(10);
    });

    test('words defaults to 3..10 words', () {
      for (var i = 0; i < 200; i++) {
        check(Rand.words().split(' ').length)
          ..isGreaterOrEqual(3)
          ..isLessOrEqual(10);
      }
    });

    test('sentence returns non-empty string', () {
      for (var i = 0; i < 10; i++) {
        check(Rand.sentence()).isNotEmpty();
      }
    });

    test('sentence(count) returns count unique sentences', () {
      for (final n in [1, 5, 50]) {
        final parts = Rand.sentence(n).split('. ');
        check(parts.length).equals(n);
        check(parts.toSet().length).equals(n);
      }
    });

    test('sentence rejects count below 1', () {
      check(() => Rand.sentence(0)).throws<ArgumentError>();
      check(() => Rand.sentence(-1)).throws<ArgumentError>();
    });

    test('sentence throws when count exceeds corpus', () {
      check(() => Rand.sentence(100000)).throws<RangeError>();
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

    test('article defaults to 3..7 paragraphs', () {
      for (var i = 0; i < 50; i++) {
        check(Rand.article().split('\n\n').length)
          ..isGreaterOrEqual(3)
          ..isLessOrEqual(7);
      }
    });

    test('slug returns wordCount unique words joined by separator', () {
      for (final wc in [1, 3, 5]) {
        final s = Rand.slug(wordCount: wc);
        final parts = s.split('-');
        check(parts.length).equals(wc);
        check(parts.toSet().length).equals(wc);
      }
      check(Rand.slug(separator: '_').split('_')).length.equals(3);
    });

    test('slug is URL-safe lowercase ascii', () {
      Rand.seed(8);
      final pattern = RegExp(r'^[a-z]+(-[a-z]+)*$');
      for (var i = 0; i < 2000; i++) {
        check(Rand.slug()).matchesPattern(pattern);
      }
    });

    test('slug throws on non-positive wordCount', () {
      check(() => Rand.slug(wordCount: 0)).throws<ArgumentError>();
    });
  });
}
