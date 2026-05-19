part of '../rand.dart';

mixin _Text on _Collections, _Numbers {
  String word() => element(_words);

  String words({int? count, String separator = ' '}) {
    final n = count ?? integer(min: 3, max: 10);
    return subSet(_words.toSet(), n).join(separator);
  }

  String sentence() => element(_sentences);

  String paragraph([int? count]) {
    final n = count ?? integer(min: 5, max: 10);
    return List.generate(n, (_) => sentence()).join('. ');
  }

  String article([int? count]) {
    final n = count ?? integer(min: 3, max: 7);
    return List.generate(n, (_) => paragraph()).join('\n\n');
  }
}
