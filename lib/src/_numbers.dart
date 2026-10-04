part of '../rand.dart';

mixin _Numbers {
  Random get rng;

  int integer({int min = 0, int max = _maxInt}) {
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    if (max == min) return max;
    final span = max - min;
    if (span < 0 || span > 0xFFFFFFFF) {
      throw ArgumentError(
        'max - min must be <= 4294967295, got min: $min, max: $max',
        'max',
      );
    }
    return rng.nextInt(span + 1) + min;
  }

  double float({num min = 0, num max = double.maxFinite}) {
    if (!min.isFinite || !max.isFinite) {
      throw ArgumentError(
        'min and max must be finite, got min: $min, max: $max',
      );
    }
    if (min > max) throw ArgumentError('min ($min) must be <= max ($max)');
    if (min == max) return min.toDouble();
    return _lerp(min, max, rng.nextDouble());
  }

  double latitude([int precision = 5]) {
    RangeError.checkValueInInterval(precision, 0, 15, 'precision');
    final value = float(min: -90, max: 90);
    final mod = pow(10.0, precision);
    return (value * mod).roundToDouble() / mod;
  }

  double longitude([int precision = 5]) {
    RangeError.checkValueInInterval(precision, 0, 15, 'precision');
    final value = float(min: -180, max: 180);
    final mod = pow(10.0, precision);
    return (value * mod).roundToDouble() / mod;
  }

  ({double lat, double lng}) geoPoint({int precision = 5}) {
    return (lat: latitude(precision), lng: longitude(precision));
  }

  int charCode() => rng.charCode();

  String semver({int maxMajor = 9, int maxMinor = 9, int maxPatch = 99}) {
    final major = integer(max: maxMajor);
    final minor = integer(max: maxMinor);
    final patch = integer(max: maxPatch);
    return '$major.$minor.$patch';
  }

  String otp({int length = 6}) {
    if (length < 1) {
      throw ArgumentError('length must be >= 1, got $length');
    }
    return List<int>.generate(length, (_) => rng.nextInt(10)).join();
  }
}
