import 'package:rand/rand.dart';

void main() {
  /// a random moment in my life
  print(Rand.dateTime(DateTime(1990, 6, 26, 8, 30), DateTime.now()));

  print(Rand.probabilityDistribution(
    probs: [80, 10, 10],
    values: [60, 90, 30],
    size: 1,
  ).first);

  print(Rand.probabilityDistribution(
    probs: [10, 40, 40, 20],
    values: _Position.values,
    size: 11,
  ));
}

enum _Position { gk, def, mid, fwd }
