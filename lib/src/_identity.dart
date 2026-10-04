part of '../rand.dart';

mixin _Identity on _Collections, _Booleans {
  String alias() => element(_alias);

  String firstName() => element(_firstNames);

  String lastName() => element(_lastNames);

  String fullName() {
    final parts = [firstName()];
    final middleCount = _weightedChoice([0, 1, 2], [100, 10, 1], rng);
    for (var i = 0; i < middleCount; i++) {
      parts.add(_fresh(parts, () => boolean() ? firstName() : lastName()));
    }
    parts.add(_fresh(parts, lastName));
    return parts.join(' ');
  }

  String city() => element(_cities);
}

String _fresh(List<String> used, String Function() draw) {
  var name = draw();
  while (used.contains(name)) {
    name = draw();
  }
  return name;
}
