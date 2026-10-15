part of '../rand.dart';

void _checkSemverMax(int value, String name) {
  if (value < 0 || value > _maxIntSpan) {
    throw ArgumentError('$name must be in 0..$_maxIntSpan, got $value', name);
  }
}

mixin _Numbers {
  Random get rng;

  /// See [Rand.integer].
  int integer({int min = 0, int max = _intDefaultMax}) {
    if (min >= max) throw ArgumentError('min ($min) must be < max ($max)');
    final span = max - min;
    if (span < 0 || span > _maxIntSpan + 1) {
      throw ArgumentError(
        'max - min must be <= 4294967296, got min: $min, max: $max',
        'max',
      );
    }
    return rng.nextInt(span) + min;
  }

  // Inclusive draw behind the package's own bounded values (semver parts,
  // email suffixes, octets, default text lengths); kept apart from the public
  // half-open [integer] so their seeded output stays put.
  int _closed(int min, int max) {
    if (max == min) return max;
    return rng.nextInt(max - min + 1) + min;
  }

  /// See [Rand.float].
  double float({num min = 0, num max = 1}) {
    if (!min.isFinite || !max.isFinite) {
      throw ArgumentError(
        'min and max must be finite, got min: $min, max: $max',
      );
    }
    final lo = min.toDouble();
    final hi = max.toDouble();
    if (lo >= hi) throw ArgumentError('min ($min) must be < max ($max)');
    final v = _lerp(lo, hi, rng.nextDouble());
    return v < hi ? v : lo;
  }

  /// See [Rand.latitude].
  double latitude([int precision = 5]) {
    RangeError.checkValueInInterval(precision, 0, 15, 'precision');
    final value = float(min: -90, max: 90);
    final mod = pow(10.0, precision);
    return (value * mod).roundToDouble() / mod;
  }

  /// See [Rand.longitude].
  double longitude([int precision = 5]) {
    RangeError.checkValueInInterval(precision, 0, 15, 'precision');
    final value = float(min: -180, max: 180);
    final mod = pow(10.0, precision);
    return (value * mod).roundToDouble() / mod;
  }

  /// See [Rand.geoPoint].
  ({double lat, double lng}) geoPoint({int precision = 5}) {
    return (lat: latitude(precision), lng: longitude(precision));
  }

  /// See [Rand.charCode].
  int charCode() => rng.charCode();

  /// See [Rand.semver].
  String semver({int maxMajor = 9, int maxMinor = 9, int maxPatch = 99}) {
    _checkSemverMax(maxMajor, 'maxMajor');
    _checkSemverMax(maxMinor, 'maxMinor');
    _checkSemverMax(maxPatch, 'maxPatch');
    final major = _closed(0, maxMajor);
    final minor = _closed(0, maxMinor);
    final patch = _closed(0, maxPatch);
    return '$major.$minor.$patch';
  }

  /// See [Rand.digits].
  String digits({int length = 6}) {
    if (length < 1) {
      throw ArgumentError('length must be >= 1, got $length', 'length');
    }
    return List<int>.generate(length, (_) => rng.nextInt(10)).join();
  }
}
