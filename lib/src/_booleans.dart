part of '../rand.dart';

mixin _Booleans {
  Random get rng;

  bool boolean([double trueChance = 50]) {
    if (trueChance < 0 || trueChance > 100) {
      throw ArgumentError('trueChance must be in [0, 100], got $trueChance');
    }
    return trueChance > rng.nextInt(100);
  }

  T? nullable<T>(T value, [double nullChance = 50]) {
    return boolean(nullChance) ? null : value;
  }
}
