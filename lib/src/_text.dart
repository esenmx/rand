part of '../rand.dart';

final Set<String> _wordSet = _words.toSet();
final Set<String> _sentenceSet = _sentences.toSet();

mixin _Text on _Collections, _Numbers {
  String word() => element(_words);

  String words({int? count, String separator = ' '}) {
    final n = count ?? integer(min: 3, max: 10);
    return subSet(_wordSet, n).join(separator);
  }

  String sentence([int? count]) {
    if (count == null) return element(_sentences);
    if (count < 1) throw ArgumentError('count must be >= 1, got $count');
    return subSet(_sentenceSet, count).join(' ');
  }

  String paragraph([int? count]) {
    final n = count ?? integer(min: 5, max: 10);
    return List.generate(n, (_) => sentence()).join('. ');
  }

  String article([int? count]) {
    final n = count ?? integer(min: 3, max: 7);
    return List.generate(n, (_) => paragraph()).join('\n\n');
  }

  String slug({int wordCount = 3, String separator = '-'}) {
    if (wordCount < 1) {
      throw ArgumentError('wordCount must be >= 1, got $wordCount');
    }
    return subSet(_wordSet, wordCount).join(separator);
  }
}
