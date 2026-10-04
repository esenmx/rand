import 'package:checks/checks.dart';
import 'package:rand/rand.dart';
import 'package:test/test.dart';

bool _isRfc2606(String domain) {
  const reservedSld = {'example.com', 'example.net', 'example.org'};
  const reservedTld = {'test', 'example', 'invalid', 'localhost'};
  return reservedSld.contains(domain) ||
      reservedTld.contains(domain.split('.').last);
}

void main() {
  setUp(() => Rand.seed(42));

  group('Networking', () {
    test('email contains @ and a domain', () {
      final ipv4Pattern = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
      for (var i = 0; i < 50; i++) {
        final e = Rand.email();
        check(e.contains('@')).isTrue();
        final parts = e.split('@');
        check(parts.length).equals(2);
        check(parts[0]).isNotEmpty();
        check(parts[1]).isNotEmpty();
        check(ipv4Pattern.hasMatch(parts[1])).isFalse();
      }
    });

    test('email honors explicit domain', () {
      for (var i = 0; i < 20; i++) {
        check(Rand.email(domain: 'mycompany.io')).endsWith('@mycompany.io');
      }
    });

    test('ipv4 is dotted quad with each octet in 0..255', () {
      final pattern = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
      for (var i = 0; i < 200; i++) {
        final ip = Rand.ipv4();
        final m = pattern.firstMatch(ip);
        check(m).isNotNull();
        for (var g = 1; g <= 4; g++) {
          final octet = int.parse(m!.group(g)!);
          check(octet).isGreaterOrEqual(0);
          check(octet).isLessOrEqual(255);
        }
      }
    });

    test('ipv6 is 8 groups of 4 lowercase hex chars', () {
      final pattern = RegExp(r'^([0-9a-f]{4}:){7}[0-9a-f]{4}$');
      for (var i = 0; i < 100; i++) {
        check(pattern.hasMatch(Rand.ipv6())).isTrue();
      }
    });

    test('ipv4 and ipv6 parse with the dart:core Uri parsers', () {
      Rand.seed(8);
      for (var i = 0; i < 5000; i++) {
        check(Uri.parseIPv4Address(Rand.ipv4())).length.equals(4);
        check(Uri.parseIPv6Address(Rand.ipv6())).length.equals(16);
      }
    });

    test('mac is 6 hex bytes with configurable separator', () {
      final colon = RegExp(r'^([0-9a-f]{2}:){5}[0-9a-f]{2}$');
      final dash = RegExp(r'^([0-9a-f]{2}-){5}[0-9a-f]{2}$');
      for (var i = 0; i < 50; i++) {
        check(colon.hasMatch(Rand.mac())).isTrue();
        check(dash.hasMatch(Rand.mac(separator: '-'))).isTrue();
      }
    });

    test('hex returns lowercase hex of requested length', () {
      const hexPool = '0123456789abcdef';
      for (final len in [1, 8, 40, 64, 128]) {
        final h = Rand.hex(length: len);
        check(h).length.equals(len);
        for (var i = 0; i < h.length; i++) {
          check(hexPool.contains(h[i])).isTrue();
        }
      }
    });

    test('hex throws on non-positive length', () {
      check(() => Rand.hex(length: 0)).throws<ArgumentError>();
      check(() => Rand.hex(length: -1)).throws<ArgumentError>();
    });

    test('hex is reproducible under seed', () {
      Rand.seed(42);
      final a = List.generate(20, (_) => Rand.hex(length: 16));
      Rand.seed(42);
      final b = List.generate(20, (_) => Rand.hex(length: 16));
      check(a).deepEquals(b);
    });

    test('every default email domain is RFC 2606 reserved', () {
      Rand.seed(5);
      final domains = {
        for (var i = 0; i < 2000; i++) Rand.email().split('@').last,
      };
      check(domains.where((d) => !_isRfc2606(d))).isEmpty();
    });

    test('email passes a conservative RFC 5322 dot-atom check', () {
      final pattern = RegExp(
        r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*"
        r'@[a-z0-9-]+(\.[a-z0-9-]+)+$',
      );
      for (var i = 0; i < 2000; i++) {
        check(Rand.email()).matchesPattern(pattern);
      }
    });
  });
}
