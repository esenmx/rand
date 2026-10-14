part of '../rand.dart';

mixin _Identity on _Collections, _Booleans {
  /// See [Rand.alias].
  String alias() => element(_alias);

  /// See [Rand.firstName].
  String firstName() => element(_firstNames);

  /// See [Rand.lastName].
  String lastName() => element(_lastNames);

  /// See [Rand.fullName].
  String fullName() {
    final parts = [firstName()];
    final middleCount = _weightedChoice([0, 1, 2], [100, 10, 1], 111, rng);
    for (var i = 0; i < middleCount; i++) {
      parts.add(_fresh(parts, () => boolean() ? firstName() : lastName()));
    }
    parts.add(_fresh(parts, lastName));
    return parts.join(' ');
  }

  /// See [Rand.city].
  String city() => element(_cities);
}

String _fresh(List<String> used, String Function() draw) {
  var name = draw();
  while (used.contains(name)) {
    name = draw();
  }
  return name;
}
