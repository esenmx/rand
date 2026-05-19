part of '../rand.dart';

mixin _Crypto {
  Random get secureRng;

  Uint8List bytes(int length) {
    return Uint8List.fromList(
      List.generate(length, (_) => secureRng.nextInt(256)),
    );
  }

  String nonce({int length = 16}) {
    return String.fromCharCodes(
      List.generate(length, (_) => secureRng.charCode()),
    );
  }

  String password({
    int length = 12,
    bool lowercase = true,
    bool uppercase = true,
    bool digits = true,
    bool symbols = true,
  }) {
    if (length < 4) {
      throw ArgumentError('length must be >= 4, got $length');
    }
    final pool = StringBuffer()
      ..write(lowercase ? _lowercase : '')
      ..write(uppercase ? _uppercase : '')
      ..write(digits ? _digits : '')
      ..write(symbols ? _symbols : '');
    if (pool.isEmpty) {
      throw ArgumentError('at least one character set must be enabled');
    }
    final chars = pool.toString();
    return String.fromCharCodes([
      for (var i = 0; i < length; i++)
        chars.codeUnitAt(secureRng.nextInt(chars.length)),
    ]);
  }
}
