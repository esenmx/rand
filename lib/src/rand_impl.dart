part of '../rand.dart';

/// A non-cryptographic random-data generator over its own [Random].
///
/// Methods behave like the same-named [Rand] statics (see there), but draw
/// from [rng] instead of the global or [Rand.withSeed]-scoped RNG.
/// Independent instances are independent streams:
///
/// ```dart
/// final a = RandGen(Random(1));
/// final b = RandGen(Random(2));
/// a.fullName(); // same value on every run
/// b.email();    // drawing from b never shifts a's sequence
/// ```
///
/// Cryptographic methods ([Rand.bytes], [Rand.nonce], [Rand.password],
/// [Rand.base64], [Rand.secureCharCode]) exist only on [Rand]: they never
/// draw from a seedable RNG.
final class RandGen
    with
        _Booleans,
        _Numbers,
        _Time,
        _Collections,
        _Sampling,
        _Text,
        _Identity,
        _Colors,
        _Networking,
        _Ids {
  /// Creates a generator drawing from [rng].
  new(this.rng);

  @override
  final Random rng;
}

final class _Secure with _Crypto {
  Random? _rng;

  @override
  Random get secureRng => _rng ??= Random.secure();
}

final class _Scope {
  new(this.gen, this.seed);

  RandGen gen;
  int? seed;
}

final Object _scopeKey = Object();
