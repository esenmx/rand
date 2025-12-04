// This file is used to demonstrate the usage of the Rand package.
// ignore_for_file: avoid_print

import 'package:rand/rand.dart';

void main() {
  print('\x1B[36m');
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║                     🎲 Rand Package Demo                     ║');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('\x1B[0m');

  _section('🔢 Numbers');
  print('  Integer (0-100):     ${Rand.integer(max: 100)}');
  print('  Integer (50-100):    ${Rand.integer(min: 50, max: 100)}');
  print('  Float (0-1):         ${Rand.float(max: 1).toStringAsFixed(4)}');
  print('  Boolean (50%):       ${Rand.boolean()}');
  print('  Boolean (90% true):  ${Rand.boolean(90)}');

  _section('🌍 Geo');
  print('  Latitude:   ${Rand.latitude()}');
  print('  Longitude:  ${Rand.longitude()}');
  print('  City:       ${Rand.city()}');

  _section('👤 Identity');
  print('  First Name: ${Rand.firstName()}');
  print('  Last Name:  ${Rand.lastName()}');
  print('  Full Name:  ${Rand.fullName()}');
  print('  Alias:      ${Rand.alias()}');

  _section('📝 Text');
  print('  Word:      ${Rand.word()}');
  print('  Words(5):  ${Rand.words(count: 5)}');
  print('  Sentence:  ${Rand.sentence()}');
  print('');
  print('  Paragraph (3 sentences):');
  print('  ${_indent(Rand.paragraph(3))}');

  _section('🔐 Cryptographic');
  print('  ID (16):       ${Rand.id()}');
  print('  ID (8):        ${Rand.id(8)}');
  print('  Nonce (32):    ${Rand.nonce(32)}');
  print('  Password:      ${Rand.password()}');
  print('  Password (no special): ${Rand.password(withSpecial: false)}');
  print('  Bytes (8):     ${Rand.bytes(8)}');

  _section('⏰ Time');
  print('  DateTime:          ${Rand.dateTime()}');
  print('  DateTime (2020-2025): ${Rand.dateTimeYear(2020, 2025)}');
  print(
    '  Duration (1-30 days): ${Rand.duration(const Duration(days: 30), const Duration(days: 1))}',
  );

  _section('🎨 Colors');
  final color = Rand.color();
  final dark = Rand.colorDark();
  final light = Rand.colorLight();
  print('  Random:     ${color.name} (${_hex(color.color)})');
  print('  Dark only:  ${dark.name} (${_hex(dark.color)})');
  print('  Light only: ${light.name} (${_hex(light.color)})');

  _section('📦 Collections');
  final fruits = ['🍎', '🍊', '🍋', '🍇', '🍓'];
  final scores = {'Alice': 95, 'Bob': 87, 'Charlie': 92};
  print('  Element:    ${Rand.element(fruits)} from $fruits');
  print('  SubSet(3):  ${Rand.subSet(fruits, 3)}');
  print('  Map Key:    ${Rand.mapKey(scores)} from ${scores.keys}');
  print('  Map Value:  ${Rand.mapValue(scores)} from ${scores.values}');

  _section('⚖️ Weighted Random');
  final positions = Rand.weightedRandomizedArray(
    weights: [10, 40, 40, 10], // GK rare, DEF/MID common, FWD rare
    pool: ['🧤 GK', '🛡️ DEF', '⚡ MID', '⚽ FWD'],
    size: 11,
  );
  print('  Football team (weighted):');
  print('  ${positions.join(', ')}');
  print('');
  final rarityDemo = Rand.weightedRandomizedArray(
    weights: [1, 10, 100],
    pool: ['🌟 Legendary', '💎 Rare', '📦 Common'],
    size: 20,
  );
  final legendary = rarityDemo.where((e) => e.contains('Legendary')).length;
  final rare = rarityDemo.where((e) => e.contains('Rare')).length;
  final common = rarityDemo.where((e) => e.contains('Common')).length;
  print(
    '  Loot box (20 items): $legendary legendary, $rare rare, $common common',
  );

  _section('🎯 Nullable');
  print('  nullable("value", 50%): ${Rand.nullable("value") ?? "null"}');
  print('  nullable("value", 90%): ${Rand.nullable("value", 90) ?? "null"}');

  print(
    '\n\x1B[36m═══════════════════════════════════════════════════════════════\x1B[0m\n',
  );
}

void _section(String title) {
  print('\n\x1B[33m▸ $title\x1B[0m');
}

String _indent(String text, [int spaces = 2]) {
  return text.split('\n').map((line) => '${' ' * spaces}$line').join('\n');
}

String _hex(int color) =>
    '#${(color & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
