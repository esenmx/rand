part of '../rand.dart';

mixin _Booleans {
  Random get rng;

  /// See [Rand.boolean].
  bool boolean([double trueChance = 50]) {
    _checkChance(trueChance, 'trueChance');
    return (rng.nextDouble() * 100) < trueChance;
  }

  /// See [Rand.nullable].
  T? nullable<T>(T value, [double nullChance = 50]) {
    _checkChance(nullChance, 'nullChance');
    return boolean(nullChance) ? null : value;
  }
}
