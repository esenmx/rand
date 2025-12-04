# 🎲 Rand

[![pub package](https://img.shields.io/pub/v/rand.svg)](https://pub.dev/packages/rand)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/Dart-3.0+-00B4AB.svg)](https://dart.dev)

**A powerful yet simple and intuitive random generator for Dart.** Generate random numbers, text, colors, dates, passwords, and more with a clean, ergonomic API.

```dart
final name = Rand.fullName();      // → "Emma Rodriguez"
final pass = Rand.password();      // → "k9#Mx!pL2@qR"
final color = Rand.color();        // → CSSColors.coral
final date = Rand.dateTime();      // → 2024-03-15 14:32:07
```

---

## ✨ Features

| Category | Methods |
|----------|---------|
| **Numbers** | `integer()` `float()` `charCode()` `boolean()` `latitude()` `longitude()` |
| **Text** | `word()` `words()` `sentence()` `paragraph()` `article()` |
| **Identity** | `firstName()` `lastName()` `fullName()` `alias()` |
| **Cryptographic** | `password()` `nonce()` `bytes()` `secureCharCode()` |
| **Time** | `dateTime()` `duration()` |
| **Collections** | `element()` `subSet()` `mapKey()` `mapValue()` `mapEntry()` |
| **Colors** | `color()` `colorDark()` `colorLight()` |
| **Probability** | `sample()` `nullable()` |
| **Misc** | `city()` |

---

## 📦 Installation

```yaml
dependencies:
  rand: ^3.1.0
```

```dart
import 'package:rand/rand.dart';
```

---

## 🚀 Quick Start

### Numbers

```dart
// Integers with named parameters (min defaults to 0)
Rand.integer();                    // 0 to 2^31-1
Rand.integer(max: 100);            // 0 to 100
Rand.integer(min: 50, max: 100);   // 50 to 100

// Floats
Rand.float();                      // 0.0 to double.maxFinite
Rand.float(min: 0, max: 1);        // 0.0 to 1.0

// Boolean with custom probability
Rand.boolean();      // 50% true
Rand.boolean(90);    // 90% true
```

### Text Generation

```dart
Rand.word();              // → "lorem"
Rand.words(count: 5);     // → "amet consectetur adipiscing elit sed"
Rand.sentence();          // → "Lorem ipsum dolor sit amet."
Rand.paragraph(3);        // 3 sentences joined
Rand.article(5);          // 5 paragraphs separated by newlines
```

### Identity

```dart
Rand.firstName();   // → "Olivia"
Rand.lastName();    // → "Thompson"
Rand.fullName();    // → "James Michael Wilson"
Rand.alias();       // → "ShadowHunter"
```

### Cryptographic (Secure RNG)

```dart
// Secure random strings (uses dart:math.Random.secure())
Rand.nonce();             // → 16-char secure string (default)
Rand.nonce(64);           // → 64-char secure string

// Passwords with options
Rand.password();                     // → "k9#Mx!pL2@qR"
Rand.password(length: 20);           // longer password
Rand.password(symbols: false);       // no symbols
Rand.password(uppercase: false);     // lowercase + digits only

// Secure bytes
Rand.bytes(32);           // → Uint8List of 32 random bytes
Rand.bytes(32, true);     // secure: true for cryptographic use
```

### Time & Duration

```dart
// Random DateTime (default: 1970-2038)
Rand.dateTime();

// Custom range
Rand.dateTime(DateTime(2020), DateTime(2025));

// Random duration
Rand.duration(max: Duration(days: 30));                          // 0 to 30 days
Rand.duration(min: Duration(days: 1), max: Duration(days: 30));  // 1 to 30 days
```

### Collections

```dart
final fruits = ['🍎', '🍊', '🍋', '🍇', '🍓'];
final scores = {'Alice': 95, 'Bob': 87};

Rand.element(fruits);   // → '🍊'
Rand.subSet(fruits, 3); // → {'🍎', '🍋', '🍓'}

Rand.mapKey(scores);      // → 'Bob'
Rand.mapValue(scores);    // → 95
Rand.mapEntry(scores);    // → MapEntry('Alice', 95)
```

### Colors

```dart
// All CSS named colors with ARGB values
final color = Rand.color();       // → CSSColors.coral
print(color.name);                // → "coral"
print(color.color);               // → 0xFFFF7F50
print(color.isDark);              // → true

// Filter by brightness
Rand.colorDark();    // dark colors only (good for light backgrounds)
Rand.colorLight();   // light colors only (good for dark backgrounds)
```

### Sampling

Select random elements with or without weights:

```dart
// Equal probability (no weights)
final dice = Rand.sample(from: [1, 2, 3, 4, 5, 6], count: 3);
// → [4, 2, 6]

// Loot box with rarity weights
final loot = Rand.sample(
  from: ['Legendary', 'Rare', 'Common'],
  count: 10,
  weights: [1, 10, 100],  // optional - higher = more likely
);
// → ['Common', 'Common', 'Rare', 'Common', ...]
```

### Nullable Helper

```dart
// 50% chance to return null (useful for test data)
Rand.nullable('value');       // → 'value' or null
Rand.nullable('value', 90);   // 90% null chance
```

### Geo

```dart
Rand.latitude();    // → 42.3601 (range: -90 to 90)
Rand.longitude();   // → -71.0589 (range: -180 to 180)
Rand.city();        // → "Tokyo"
```

---

## 🔧 Advanced Usage

### Seeding for Reproducibility

```dart
// Set seed for reproducible results (great for testing)
Rand.seed(42);
print(Rand.integer(max: 100)); // Always same value for same seed
```

### Secure vs Non-Secure

| Method | RNG Type | Use Case |
|--------|----------|----------|
| `integer()`, `float()`, etc. | `Random()` | General purpose, fast |
| `password()`, `nonce()`, `secureCharCode()` | `Random.secure()` | Cryptographic, tokens |
| `bytes(length, true)` | `Random.secure()` | When you need secure bytes |

---

*Made with 🎲 by [Mehmet Esen](https://mehmetesen.com)*
