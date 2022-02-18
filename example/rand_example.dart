import 'package:rand/rand.dart';

void main() {
  /// a random moment in my life
  print(Rand.dateTime(DateTime(1990, 6, 26, 8, 30), DateTime.now()));
}
