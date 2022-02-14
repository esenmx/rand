import 'package:rand/rand.dart';

void main() {
  /// a random moment in my life
  print(Rand.dateTime(min: DateTime(1990, 6, 26, 8, 30), max: DateTime.now()));
}
