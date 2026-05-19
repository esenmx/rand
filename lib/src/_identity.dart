part of '../rand.dart';

mixin _Identity on _Collections, _Booleans {
  String alias() => element(_alias);

  String firstName() => element(_firstNames);

  String lastName() => element(_lastNames);

  String fullName() {
    final buffer = StringBuffer(firstName());
    final middleCount = _weightedChoice([0, 1, 2], [100, 10, 1], rng);
    for (var i = 0; i < middleCount; i++) {
      buffer.write(' ${boolean() ? firstName() : lastName()}');
    }
    buffer.write(' ${lastName()}');
    return buffer.toString();
  }

  String city() => element(_cities);
}
