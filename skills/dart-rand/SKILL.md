---
name: dart-rand
description: Use the `rand` Dart package correctly when generating random test data, fixtures, mock values, names, dates, CSS colors, weighted samples, or cryptographic tokens for testing. Covers the secure vs non-secure RNG split, `Rand.useRng` / `Rand.seed` semantics, `subSet` vs `sample` (without vs with replacement, weighted vs uniform), `CssColors` ARGB usage and the computed `isDark` extension, and common misuse patterns (off-by-one on `integer(max:)`, seeding crypto methods, using `nonce()` as a production secret). Trigger when the user's file imports `package:rand/rand.dart`, when the user asks for "random test data", "fake names", "test fixtures", "Lorem ipsum", "loot box weights", "weighted sampling", "CSS colors", or "secure tokens for tests". Skip for production secret/password generation (use `package:cryptography` or platform keystore), RFC 4122 UUIDs (use `package:uuid`), realistic locale-aware fake data (use `package:faker`), or a single `dart:math.Random.nextInt` call (no dep needed).
---

# rand

`import 'package:rand/rand.dart';` then `Rand.x()`. Static API, all methods discoverable by IDE / dartdoc. This skill covers only the non-obvious choices.

## Two-RNG split — load-bearing

| RNG | Methods | Reset by `useRng` / `seed`? |
|---|---|---|
| `Random` (replaceable) | everything not in the next row | yes |
| `Random.secure()` (fixed) | `password`, `nonce`, `bytes`, `secureCharCode` | **no** |

Consequences:

- `Rand.seed(42); Rand.password()` is fresh CSPRNG every call. For deterministic password-shaped data, build from your own `Random(42)`.
- For a "secure" non-crypto draw, switch the global once: `Rand.useRng(Random.secure())`.
- Don't ship rand-generated tokens as production secrets — package contract is "test data"; defaults can shift in major versions. Reach for `package:cryptography` or a platform keystore.

## Picking the right call

| Goal | Use |
|---|---|
| One element | `Rand.element(iterable)` |
| N unique elements | `Rand.subSet(set, N)` — requires `Set<T>` |
| N elements, repeats okay | `Rand.sample(from: list, count: N)` |
| Weighted draws | `Rand.sample(..., weights: [...])` |
| Map key / value / entry | `Rand.mapKey` / `mapValue` / `mapEntry` |
| Maybe-null fixture field | `Rand.nullable(value, chance)` |

`subSet` is `Set<T>` only — dedupe explicitly with `.toSet()`. `weights.length >= from.length` for `sample`.

## Bounds

- `Rand.integer({min, max})` — **inclusive both ends**.
- `Rand.float`, `Rand.duration`, `Rand.dateTime` — `[min, max)` half-open.

## Colors

`Rand.color()` / `colorDark()` / `colorLight()` → `CssColors` (148 variants). `.argb` is a 32-bit ARGB int (`Color(c.argb)` in Flutter). `.isDark` is a `CssColorsX` extension getter — computed YIQ luminance, not stored. For proper Flutter contrast picking, use `fluiver`'s `Color.contrastText`.

## Common traps

```dart
// ❌ inclusive max — can return list.length (out of bounds)
final idx = Rand.integer(max: list.length);
// ✅
final item = Rand.element(list);  // or: Rand.integer(max: list.length - 1)

// ❌ seed has no effect on password — CSPRNG every call
Rand.seed(42);
Rand.password();
// ✅ build deterministic tokens from your own Random

// ❌ subSet on a list with duplicates — compile error post-v4
Rand.subSet([1, 2, 2], 2);
// ✅
Rand.subSet({1, 2}, 2);

// ❌ nonce / password as production secret
final jwtKey = Rand.nonce(length: 32);
// ✅ use a real KDF or platform keystore

// ❌ password rejected
Rand.password(length: 3);                                 // < 4 throws
Rand.password(lowercase: false, uppercase: false,
              digits: false, symbols: false);             // all-off throws
```

## When NOT to use rand

- Stable IDs across runs → UUID v4 or app-issued IDs.
- Locale-aware data → `package:faker`.
- A single `nextDouble` / `nextInt` → `dart:math.Random` directly, skip the dep.
- Tokens your security depends on → `package:cryptography` or platform keystore.

## Determinism

- `seed(N)` reproduces across runs on the **same Dart SDK / platform**. Not guaranteed across major SDK upgrades — `math.Random` internals can change.
- In parallel tests set in `setUp`, not `setUpAll` — the global RNG is shared.
- Crypto methods ignore `seed` / `useRng`.
