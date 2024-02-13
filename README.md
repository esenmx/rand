# rand

A stateful random generator with extra functionalities. To use:

```dart
print(Rand.boolean(20) ? 'head' : 'tail'); // it's a head for 20% probability
Rand.dateTimeYear(2001, 2024) // A random 21th century [DateTime]
Rand.password() // Create a strong password
```
