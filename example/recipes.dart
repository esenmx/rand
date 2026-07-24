// coverage:ignore-file
// Composer recipes — assembling composite fixtures from `rand` primitives.
//
// `rand` exposes flat values by design (no `User`, `Address`, `ApiResponse`).
// This file shows the patterns to reach for when building structured test
// data on top of those primitives. Treat each `_build…` as a copyable seed.
//
// Run: dart run example/recipes.dart
// ignore_for_file: avoid_print

import 'package:rand/rand.dart';

void main() {
  Rand.seed(42); // reproducible output for the recipes

  _section('User fixture (record)');
  print(_buildUser());

  _section('Address fixture');
  print(_buildAddress());

  _section('Order with line items');
  final order = _buildOrder(itemCount: 3);
  print('id=${order.id}  total=\$${order.total}  items=${order.items.length}');
  for (final line in order.items) {
    print('  - ${line.sku}  x${line.qty}  @\$${line.price}');
  }

  _section('Paginated API response (page 2 of 7)');
  final page = _buildPage<({String id, String name})>(
    page: 2,
    pageSize: 5,
    totalPages: 7,
    item: () => (id: Rand.hex(length: 12), name: Rand.fullName()),
  );
  print('page ${page.page}/${page.totalPages}, ${page.items.length} items');
  for (final user in page.items) {
    print('  ${user.id}  ${user.name}');
  }

  _section('Chat history (10 messages, chronological)');
  final chat = _buildChatHistory(messageCount: 10);
  for (final msg in chat) {
    print('  [${msg.at.toIso8601String()}] ${msg.sender}: ${msg.body}');
  }
}

// ────────────────────────────────────────────────────────────────────
// Recipes
// ────────────────────────────────────────────────────────────────────

/// User as a named record. Records keep test fixtures ceremony-free.
typedef _User = ({
  String id,
  String name,
  String email,
  String? avatar,
  DateTime joinedAt,
});

_User _buildUser() {
  return (
    id: Rand.hex(length: 24),
    name: Rand.fullName(),
    email: Rand.email(),
    // `nullable(x, 20)` → 20% null. Arg is `nullChance`, not `presenceChance`.
    avatar: Rand.nullable(
      'https://i.pravatar.cc/${Rand.integer(min: 64, max: 256)}',
      20,
    ),
    joinedAt: Rand.dateTime(DateTime(2020), DateTime.now()),
  );
}

typedef _Address = ({
  String street,
  String city,
  String postalCode,
  String country,
});

_Address _buildAddress() {
  return (
    street: '${Rand.integer(min: 1, max: 9999)} ${Rand.word()} St',
    city: Rand.city(),
    postalCode: Rand.otp(length: 5),
    country: Rand.element(const ['US', 'GB', 'DE', 'JP', 'BR']),
  );
}

class _LineItem {
  _LineItem({required this.sku, required this.qty, required this.price});

  final String sku;
  final int qty;
  final double price;
}

class _Order {
  _Order({required this.id, required this.items, required this.total});

  final String id;
  final List<_LineItem> items;
  final double total;
}

_Order _buildOrder({required int itemCount}) {
  final items = List.generate(itemCount, (_) {
    return _LineItem(
      sku: Rand.hex(length: 10).toUpperCase(),
      qty: Rand.integer(min: 1, max: 5),
      price: double.parse(Rand.float(min: 5, max: 200).toStringAsFixed(2)),
    );
  });
  final total = items.fold<double>(0, (sum, it) => sum + it.price * it.qty);
  return _Order(
    id: 'ord_${Rand.hex(length: 12)}',
    items: items,
    total: double.parse(total.toStringAsFixed(2)),
  );
}

/// Generic paginated envelope. `item` produces one element of T per call —
/// pass any fixture builder.
typedef _Page<T> = ({
  int page,
  int pageSize,
  int totalPages,
  int totalItems,
  List<T> items,
});

_Page<T> _buildPage<T>({
  required int page,
  required int pageSize,
  required int totalPages,
  required T Function() item,
}) {
  return (
    page: page,
    pageSize: pageSize,
    totalPages: totalPages,
    totalItems: totalPages * pageSize,
    items: List.generate(pageSize, (_) => item()),
  );
}

({String sender, String body, DateTime at}) _chatMessage(String sender) {
  return (
    sender: sender,
    body: Rand.sentence(),
    at: Rand.dateTime(
      DateTime.now().subtract(const Duration(hours: 1)),
      DateTime.now(),
    ),
  );
}

List<({String sender, String body, DateTime at})> _buildChatHistory({
  required int messageCount,
}) {
  // `sample` with equal weights → realistic sender alternation.
  final senders = Rand.sample(
    from: const ['user', 'assistant'],
    count: messageCount,
  );
  return [for (final s in senders) _chatMessage(s)]
    ..sort((a, b) => a.at.compareTo(b.at));
}

void _section(String title) {
  print('\n\x1B[33m▸ $title\x1B[0m');
}
