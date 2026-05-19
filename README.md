# rand

[![pub](https://img.shields.io/pub/v/rand.svg)](https://pub.dev/packages/rand)
[![CI](https://github.com/esenmx/rand/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/rand/actions/workflows/ci.yaml)
[![codecov](https://codecov.io/gh/esenmx/rand/branch/master/graph/badge.svg)](https://codecov.io/gh/esenmx/rand)
[![pub points](https://img.shields.io/pub/points/rand)](https://pub.dev/packages/rand/score)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Random data for Dart.** Numbers, text, names, dates, CSS colors,
cryptographic tokens. One static class, two RNGs, all six platforms.

```dart
Rand.fullName();       // → 'Emma Rodriguez'
Rand.password();       // → 'k9#Mx!pL2@qR'
Rand.color();          // → CssColors.coral
Rand.dateTime();       // → 2024-03-15 14:32:07.000Z
Rand.sample(from: ['rare', 'common'], count: 10, weights: [1, 100]);
```

---

## What it's for

- Test fixtures and seed data.
- Mocking API responses.
- Demos, prototypes, throwaway tokens.
- Game prototyping (loot-box weighting, dice, color palettes).

## What it isn't

- **Not faker.** `rand` returns flat values. Compose typed entities yourself:
  `User(name: Rand.fullName(), city: Rand.city())`.
- **Not a crypto library.** `Rand.password()` and `Rand.nonce()` use the
  platform CSPRNG, but the package's stability contract is "test data," not
  production secrets. Defaults may shift across major versions.
- **Not a UUID library.** `Rand.nonce()` is opaque base62, not RFC 4122.

---

## Install

```bash
dart pub add rand
```

```dart
import 'package:rand/rand.dart';
```

Pure Dart. Works on android, ios, linux, macos, web, windows. No Flutter
dependency.

---

## Configuring the RNG

```dart
Rand.useRng(Random(42));      // any Random instance
Rand.seed(42);                // shortcut for useRng(Random(42))
Rand.useRng(Random.secure()); // cryptographically secure for non-crypto methods
```

`useRng` and `seed` mutate the global non-cryptographic RNG. Cryptographic
methods (`password`, `nonce`, `bytes`, `secureCharCode`) always use
`Random.secure()` and ignore both.

In parallel tests, set the RNG in `setUp`, not `setUpAll` — the global is
shared.

---

## Numbers

```dart
Rand.integer();                    // 0 to 2^31-1, inclusive both ends
Rand.integer(min: 50, max: 100);
Rand.float();                      // 0.0 to double.maxFinite, half-open
Rand.float(min: 0, max: 1);        // [0.0, 1.0)
Rand.boolean();                    // 50% true
Rand.boolean(90);                  // 90% true
Rand.latitude();                   // -90..90, 5 decimal places
Rand.longitude(3);                 // -180..180, 3 decimal places
Rand.charCode();                   // base62 code point (int)
```

`integer(max: list.length)` is **inclusive** — it can return `list.length`
(out of bounds for indexing). Use `max: list.length - 1`, or just call
`Rand.element(list)`.

---

## Cryptographic — secure vs non-secure

```dart
Rand.bytes(32);              // Uint8List, always Random.secure()
Rand.nonce();                // 16-char base62, always Random.secure()
Rand.nonce(length: 32);
Rand.password();             // 12-char mixed-charset, always Random.secure()
Rand.password(length: 20, symbols: false);
Rand.secureCharCode();       // base62 code point, always Random.secure()
```

Three rules:

1. **Seed doesn't reach secure methods.** `Rand.seed(42); Rand.password()` is
   fresh CSPRNG output every call. For reproducible token tests, generate
   them from your own `Random` instance.
2. **Don't ship rand-generated tokens as production secrets.** The RNG is
   correct; the package contract is "test data." Defaults can shift across
   major versions. Use [`package:cryptography`](https://pub.dev/packages/cryptography)
   or your platform's keystore for real secrets.
3. **`bytes()` and `nonce()` are always secure** post-v4 — the `secure:`
   parameter is gone.

---

## Identity & geo

```dart
Rand.firstName();   // 'Olivia'
Rand.lastName();    // 'Thompson'
Rand.fullName();    // 'James Michael Wilson' — 0..2 weighted middle names
Rand.alias();       // 'ShadowHunter'
Rand.city();        // 'Tokyo'
```

Corpora are US/English-leaning. For locale-aware data, reach for
[`package:faker`](https://pub.dev/packages/faker).

---

## Text — lorem corpus

```dart
Rand.word();                       // 'lorem'
Rand.words(count: 5);              // 'amet consectetur adipiscing elit sed'
Rand.words(count: 3, separator: '-');
Rand.sentence();                   // 'Lorem ipsum dolor sit amet.'
Rand.paragraph(3);                 // 3 sentences joined by '. '
Rand.article(5);                   // 5 paragraphs separated by '\n\n'
```

`words(count: N)` uses `subSet` — same word never repeats in one call. For
repeats, call `word()` N times yourself.

---

## Time

```dart
Rand.dateTime();                                       // 1970-01-01..2038-01-19 UTC
Rand.dateTime(DateTime(2020), DateTime(2025));         // custom range, half-open
Rand.duration(max: const Duration(days: 30));          // 0 to 30 days
Rand.duration(min: const Duration(days: 1), max: const Duration(days: 30));
```

`dateTime` and `duration` are `[min, max)` half-open.

---

## Collections

```dart
final fruits = ['apple', 'orange', 'lemon', 'grape', 'kiwi'];
final scores = {'Alice': 95, 'Bob': 87};

Rand.element(fruits);          // 'orange'
Rand.subSet({1, 2, 3, 4, 5}, 3); // {2, 5, 1} — unique elements
Rand.mapKey(scores);           // 'Bob'
Rand.mapValue(scores);         // 95
Rand.mapEntry(scores);         // MapEntry('Alice', 95)
```

Pick the right call:

| Need                                | Use                              |
| ----------------------------------- | -------------------------------- |
| One element                         | `element(iterable)`              |
| N unique elements                   | `subSet(set, N)`                 |
| N elements, repeats okay            | `sample(from: list, count: N)`   |
| N elements with weighted frequency  | `sample(..., weights: [...])`    |
| One key / value / entry of a Map    | `mapKey` / `mapValue` / `mapEntry` |

`subSet` requires `Set<T>` — dedupe explicitly with `.toSet()` if your
source has duplicates.

---

## Sampling — weighted draws with replacement

```dart
// Loot box: legendary 1%, rare 10%, common ~90%
final loot = Rand.sample(
  from: ['Legendary', 'Rare', 'Common'],
  count: 100,
  weights: [1, 10, 100],
);

// Equal probability — drop weights
final dice = Rand.sample(from: [1, 2, 3, 4, 5, 6], count: 10);
```

`weights.length` must be `>= from.length`. For a *secure* sample call
`Rand.useRng(Random.secure())` first.

---

## Colors

```dart
final c = Rand.color();
c.name;     // 'coral'
c.argb;     // 0xFFFF7F50 — ARGB packed int
c.isDark;   // computed via CssColorsX extension (YIQ luminance)

Rand.colorDark();   // dark colors only — good for light backgrounds
Rand.colorLight();  // light colors only — good for dark backgrounds
```

148 CSS named variants. The `argb` int is Flutter-friendly:
`Color(c.argb)` works without conversion. `isDark` is a `CssColorsX`
extension getter — computed from `argb` via the YIQ luminance formula,
not stored on the enum. Use it (or your own contrast helper, e.g.
[`fluiver`](https://pub.dev/packages/fluiver)'s `Color.contrastText`)
to pick a foreground.

---

## Probability helpers

```dart
Rand.boolean();             // 50% true
Rand.boolean(99.9);         // 99.9% true
Rand.nullable('value');     // 50% null, useful in fixtures
Rand.nullable('value', 90); // 90% null
```

---

## LLM skill

A tool-agnostic skill ships at
[`skills/dart-rand/SKILL.md`](skills/dart-rand/SKILL.md). The folder name
is `dart-rand` to avoid colliding with other languages' `rand` namespaces
(Go, Rust, etc.). Unlike an always-on rule, the skill activates **only**
when its description matches the current task (file import, asked feature,
keyword), so it stays out of the way for unrelated work. Vendor it into
your agent's skills directory:

```bash
# Claude Code (user-level)
mkdir -p ~/.claude/skills/dart-rand
curl -L https://raw.githubusercontent.com/esenmx/rand/master/skills/dart-rand/SKILL.md \
  -o ~/.claude/skills/dart-rand/SKILL.md

# Claude Code (project-level)
mkdir -p .claude/skills/dart-rand
curl -L https://raw.githubusercontent.com/esenmx/rand/master/skills/dart-rand/SKILL.md \
  -o .claude/skills/dart-rand/SKILL.md
```

Other agents: copy the SKILL.md body wherever your tool reads
description-triggered context (`.cursor/`, `AGENTS.md` snippets, etc.).

---

## Migrating from 3.x

v4.0 is a breaking release. Highlights:

- `CSSColors` → `CssColors`, `.color` → `.argb`.
- `CssColors.isDark` is now a `CssColorsX` extension getter (computed
  from `argb` via YIQ luminance), not a stored field. The boundary
  values may shift slightly from the v3 hand-curated table.
- `bytes()` and `nonce()` are always secure; the `secure:` parameter is gone.
- `nonce()` now returns true base62 (the v3 implementation was bytes).
- `subSet()` requires `Set<T>` — dedupe with `.toSet()` at the call site.
- `sample()` drops `secure:` — call `Rand.useRng(Random.secure())` first.
- `element([])` throws `StateError` (was a cryptic `RangeError`).
- New `Rand.useRng(Random)` mutator; `seed(N)` is now `useRng(Random(N))`.

Full table in [CHANGELOG.md](CHANGELOG.md).

---

## License

MIT.
