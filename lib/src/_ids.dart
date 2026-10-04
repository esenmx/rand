part of '../rand.dart';

const String _crockford = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
const int _maxUnixMs48 = 0xFFFFFFFFFFFF;

mixin _Ids {
  Random get rng;

  Uint8List _randomBytes(int n) {
    final b = Uint8List(n);
    for (var i = 0; i < n; i++) {
      b[i] = rng.nextInt(256);
    }
    return b;
  }

  String uuidV4() {
    final b = _randomBytes(16);
    b[6] = (b[6] & 0x0F) | 0x40;
    b[8] = (b[8] & 0x3F) | 0x80;
    return _formatUuid(b);
  }

  String uuidV7({DateTime? time}) {
    var ms = _unixMs48(time);
    final b = _randomBytes(16);
    for (var i = 5; i >= 0; i--) {
      b[i] = ms % 256;
      ms ~/= 256;
    }
    b[6] = (b[6] & 0x0F) | 0x70;
    b[8] = (b[8] & 0x3F) | 0x80;
    return _formatUuid(b);
  }

  String ulid({DateTime? time}) {
    var ms = _unixMs48(time);
    final codes = Uint16List(26);
    for (var i = 9; i >= 0; i--) {
      codes[i] = _crockford.codeUnitAt(ms % 32);
      ms ~/= 32;
    }
    for (var i = 10; i < 26; i++) {
      codes[i] = _crockford.codeUnitAt(rng.nextInt(32));
    }
    return String.fromCharCodes(codes);
  }
}

int _unixMs48(DateTime? time) {
  final ms = (time ?? DateTime.now()).millisecondsSinceEpoch;
  if (ms < 0 || ms > _maxUnixMs48) {
    throw ArgumentError.value(time, 'time', 'must be within 1970..10889');
  }
  return ms;
}

String _formatUuid(Uint8List b) {
  final codes = Uint16List(36);
  var j = 0;
  for (var i = 0; i < 16; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) codes[j++] = 0x2D;
    codes[j++] = _hexChars.codeUnitAt(b[i] ~/ 16);
    codes[j++] = _hexChars.codeUnitAt(b[i] % 16);
  }
  return String.fromCharCodes(codes);
}
