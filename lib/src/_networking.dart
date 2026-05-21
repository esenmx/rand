part of '../rand.dart';

const List<String> _domains = [
  'example.com',
  'example.org',
  'example.net',
  'test.com',
  'mail.test',
  'demo.dev',
  'sample.app',
  'fake.io',
];

const String _hexChars = '0123456789abcdef';

mixin _Networking on _Numbers, _Collections, _Identity {
  String email({String? domain}) {
    final user = '${firstName().toLowerCase()}${integer(min: 1, max: 99)}';
    return '$user@${domain ?? element(_domains)}';
  }

  String ipv4() {
    return List<int>.generate(4, (_) => integer(max: 255)).join('.');
  }

  String ipv6() {
    return List<String>.generate(8, (_) => hex(length: 4)).join(':');
  }

  String mac({String separator = ':'}) {
    return List<String>.generate(6, (_) => hex(length: 2)).join(separator);
  }

  String hex({int length = 8}) {
    if (length < 1) {
      throw ArgumentError('length must be >= 1, got $length');
    }
    return String.fromCharCodes([
      for (var i = 0; i < length; i++)
        _hexChars.codeUnitAt(rng.nextInt(16)),
    ]);
  }
}
