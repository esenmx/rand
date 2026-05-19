part of '../rand.dart';

mixin _Numbers {
  Random get rng;
  Random get secureRng;

  int integer({int min = 0, int max = _maxInt}) {
    if (max == min) return max;
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    RangeError.checkValueInInterval(max - min, 1, _maxInt, 'difference');
    return rng.nextInt(max - min + 1) + min;
  }

  double float({num min = 0, num max = double.maxFinite}) {
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    return _lerp(min, max, rng.nextDouble());
  }

  double latitude([int precision = 5]) {
    return double.parse(float(min: -90, max: 90).toStringAsFixed(precision));
  }

  double longitude([int precision = 5]) {
    return double.parse(float(min: -180, max: 180).toStringAsFixed(precision));
  }

  int charCode() => rng.charCode();

  int secureCharCode() => secureRng.charCode();
}
