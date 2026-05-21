part of '../rand.dart';

class _RandImpl
    with
        _Booleans,
        _Numbers,
        _Crypto,
        _Time,
        _Collections,
        _Sampling,
        _Text,
        _Identity,
        _Colors,
        _Networking {
  @override
  Random rng = Random();

  @override
  final Random secureRng = Random.secure();
}
