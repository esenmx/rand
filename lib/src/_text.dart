part of '../rand.dart';

final Set<String> _wordSet = _words.toSet();
final Set<String> _sentenceSet = _sentences.toSet();

mixin _Text on _Collections, _Numbers {
  /// See [Rand.word].
  String word() => element(_words);

  /// See [Rand.words].
  String words({int? count, String separator = ' '}) {
    if (count != null) _checkNonNegative(count, 'count');
    final n = count ?? integer(min: 3, max: 10);
    return subSet(_wordSet, n).join(separator);
  }

  /// See [Rand.sentence].
  String sentence([int? count]) {
    if (count == null) return element(_sentences);
    if (count < 1) {
      throw ArgumentError('count must be >= 1, got $count', 'count');
    }
    return subSet(_sentenceSet, count).join(' ');
  }

  /// See [Rand.paragraph].
  String paragraph([int? count]) {
    if (count != null) _checkNonNegative(count, 'count');
    final n = count ?? integer(min: 5, max: 10);
    return List.generate(n, (_) => sentence()).join(' ');
  }

  /// See [Rand.article].
  String article([int? count]) {
    if (count != null) _checkNonNegative(count, 'count');
    final n = count ?? integer(min: 3, max: 7);
    return List.generate(n, (_) => paragraph()).join('\n\n');
  }

  /// See [Rand.slug].
  String slug({int wordCount = 3, String separator = '-'}) {
    if (wordCount < 1) {
      throw ArgumentError.value(wordCount, 'wordCount', 'must be >= 1');
    }
    if (wordCount > _wordSet.length) {
      throw RangeError.range(wordCount, 1, _wordSet.length, 'wordCount');
    }
    return subSet(_wordSet, wordCount).join(separator);
  }
}
