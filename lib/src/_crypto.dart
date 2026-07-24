part of '../rand.dart';

mixin _Crypto {
  Random get secureRng;

  Uint8List bytes(int length) {
    final list = Uint8List(length);
    for (var i = 0; i < length; i++) {
      list[i] = secureRng.nextInt(256);
    }
    return list;
  }

  String nonce({int length = 16}) {
    final codes = Uint16List(length);
    for (var i = 0; i < length; i++) {
      codes[i] = secureRng.charCode();
    }
    return String.fromCharCodes(codes);
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
    final pools = <String>[];
    if (lowercase) pools.add(_lowercase);
    if (uppercase) pools.add(_uppercase);
    if (digits) pools.add(_digits);
    if (symbols) pools.add(_symbols);

    if (pools.isEmpty) {
      throw ArgumentError('at least one character set must be enabled');
    }

    final charCodes = Uint16List(length);
    var index = 0;

    // Guarantee at least one character from each enabled pool
    for (final pool in pools) {
      charCodes[index++] = pool.codeUnitAt(secureRng.nextInt(pool.length));
    }

    // Fill the remaining characters from the combined pool
    final combined = pools.join();
    while (index < length) {
      final code = combined.codeUnitAt(secureRng.nextInt(combined.length));
      charCodes[index++] = code;
    }

    // Shuffle the characters cryptographically
    for (var i = length - 1; i > 0; i--) {
      final j = secureRng.nextInt(i + 1);
      final temp = charCodes[i];
      charCodes[i] = charCodes[j];
      charCodes[j] = temp;
    }

    return String.fromCharCodes(charCodes);
  }

  String base64({int byteLength = 16}) {
    if (byteLength < 1) {
      throw ArgumentError('byteLength must be >= 1, got $byteLength');
    }
    return base64Encode(bytes(byteLength));
  }
}
