// ignore_for_file: avoid_print

import 'package:rand/rand.dart';

void main() {
  final divider = ''.padLeft(45, '=');

  print('\x1B[34m$divider\nRand Demo Output\n$divider\x1B[0m\n');

  {
    final dateTime = Rand.dateTime();
    print('\x1B[32m[Random DateTime]\x1B[0m');
    print('  $dateTime\n');
  }

  {
    final myLifeMoment =
        Rand.dateTime(DateTime(1990, 6, 26, 8, 30), DateTime.now());
    print('\x1B[32m[Random moment in my life]\x1B[0m');
    print('  $myLifeMoment\n');
  }

  {
    final weightedNumber = Rand.weightedRandomizedArray(
      weights: [80, 10, 10],
      pool: [60, 90, 30],
      size: 1,
    ).first;
    print('\x1B[32m[Weighted Random Number]\x1B[0m');
    print('  $weightedNumber\n');
  }

  {
    final weightedPositions = Rand.weightedRandomizedArray(
      weights: [10, 40, 50, 10],
      pool: _Position.values,
      size: 11,
    );
    print('\x1B[32m[Weighted Randomized Football Positions]\x1B[0m');
    print('  ${weightedPositions.map((e) => e.name).toList()}\n');
  }

  print('\x1B[34m$divider\x1B[0m');
}

enum _Position { gk, def, mid, fwd }
