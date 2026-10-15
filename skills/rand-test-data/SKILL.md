---
name: rand-test-data
description: Generate random Dart test data via `package:rand` — names, emails, IPv4/IPv6/MAC, hex, slugs, digit codes, semver, lorem, colors, weighted sampling, geo points, UUID v4/v7 and ULID test IDs, crypto tokens; isolated streams (`RandGen`), scoped seeds (`withSeed`), seed reporting. Use for test fixtures, mocked API responses, demo seeds, any fake/seeded data. Skip for production secrets (`cryptography`), locale-aware names (`faker`).
---

# rand-test-data

`import 'package:rand/rand.dart';` then `Rand.x()`. Static API, all methods discoverable by IDE / dartdoc. This skill covers only the non-obvious choices.

## Two-RNG split — load-bearing

|RNG|Methods|Reset by `useRng` / `seed`?|
|---|---|---|
|`Random` (replaceable)|everything not in the next row|yes|
|`Random.secure()` (fixed)|`password`, `nonce`, `bytes`, `base64`, `secureCharCode`|**no**|

Consequences:

- `Rand.seed(42); Rand.password()` is fresh CSPRNG every call. For deterministic password-shaped data, build from your own `Random(42)`.
- For a "secure" non-crypto draw, use your own generator: `RandGen(Random.secure()).sample(...)` — swapping the global with `useRng` also clears `currentSeed` for every later call.
- Don't ship rand-generated tokens as production secrets — package contract is "test data"; defaults can shift in major versions. Reach for `package:cryptography` or a platform keystore.

## Picking the right call

|Goal|Use|
|---|---|
|One element|`Rand.element(iterable)`|
|One enum member|`Rand.enumValue(MyEnum.values)`|
|N unique elements|`Rand.subSet(set, N)` — requires `Set<T>`|
|N elements, repeats okay|`Rand.sample(from: list, count: N)`|
|Weighted draws|`Rand.sample(..., weights: [...])`|
|Whole list, reordered|`Rand.shuffled(list)` — non-mutating copy|
|Map key / value / entry|`Rand.mapKey` / `mapValue` / `mapEntry`|
|Maybe-null fixture field|`Rand.nullable(value, nullChance: 20)`|
|Independent stream injected into code under test|`RandGen(Random(1))` — same non-crypto API as `Rand`, no crypto methods|
|Seed one call tree without touching the global|`Rand.withSeed(7, () => …)` — zone-scoped, follows `await`, nests|
|Random seed per run, replayable on failure|`Rand.seed(); printOnFailure('Rand seed: ${Rand.currentSeed}')` in `setUp`|
|Seedable test IDs|`Rand.uuidV4()` / `Rand.uuidV7(time: t)` / `Rand.ulid(time: t)` — reproducible under `seed`/`withSeed`; `time` is required (a fixed instant for snapshots, `DateTime.now()` for a live clock)|

`subSet` is `Set<T>` only — dedupe explicitly with `.toSet()`. `sample` needs `weights.length == from.length`, and an empty `from` throws unless `count` is 0.

## Common tasks

Recipe shapes that show up in fixture / mock requests. `rand` is intentionally flat — compose the primitives. Full composer examples (User, Address, Order, Paginated, ChatHistory) live in [`example/recipes.dart`](../../example/recipes.dart).

|Prompt|Recipe|
|---|---|
|*"10 fake users"*|`List.generate(10, (_) => (id: Rand.hex(length: 24), name: Rand.fullName(), email: Rand.email()))`|
|*"Paginated response, 5 items"*|`(page: 1, totalPages: 7, items: List.generate(5, (_) => buildItem()))`|
|*"Loot box: 1% legendary, 10% rare, 90% common"*|`Rand.sample(from: ['L','R','C'], count: 100, weights: [1, 10, 100])`|
|*"Timestamps for the past hour, sorted"*|`[for (var i = 0; i < 20; i++) Rand.dateTime(DateTime.now().subtract(const Duration(hours: 1)), DateTime.now())]..sort((a, b) => a.compareTo(b))`|
|*"Reproducible fixture I can rerun"*|`setUp(() => Rand.seed(42));` — non-crypto reproduces; `password`/`nonce`/`bytes`/`base64` stay live CSPRNG|
|*"Opaque session/auth token for tests"*|`Rand.base64(byteLength: 32)` — crypto-secure source|
|*"Git-style SHA"*|`Rand.hex(length: 40)`|
|*"Mostly-present nullable field"*|`Rand.nullable(value, nullChance: 20)` — 20% null|
|*"Pick a random enum"*|`Rand.enumValue(MyEnum.values)`|
|*"Shuffle a list non-destructively"*|`Rand.shuffled(list)` — returns a copy; `list..shuffle()` mutates|

## Bounds

- `Rand.integer`, `Rand.float`, `Rand.duration`, `Rand.dateTime` — all `[min, max)` half-open, like `nextInt` / `nextDouble`; an empty range (`min >= max`) throws `ArgumentError`. `Rand.float()` defaults to `[0, 1)`. `Rand.dateTime` always returns a UTC representation.
- Counts accept 0 (empty result); `nonce`, `hex`, `digits`, `base64`, `slug` need a length of at least 1.

## Networking primitives

```dart
Rand.email();                       // 'olivia42@example.com' — RFC 2606 safe TLDs
Rand.email(domain: 'mycompany.io');
Rand.ipv4();                        // not filtered for reserved ranges
Rand.ipv6();                        // full form, no `::` collapse
Rand.mac(separator: ':');           // default colon; '-' also common
Rand.hex(length: 8);                // generic lowercase hex — git SHAs (length: 40), ETags
Rand.semver();                      // 'major.minor.patch', no pre-release suffix
Rand.digits(length: 6);             // decimal digits, leading zeros kept
Rand.slug(wordCount: 3);            // unique lorem words, '-' separator
```

All use the non-secure RNG — reproducible under `Rand.seed`. `Rand.base64(byteLength: 16)` is the crypto-secure parallel for opaque payload fixtures.

## Geo

```dart
final (:lat, :lng) = Rand.geoPoint();        // named record
Rand.geoPoint(precision: 2);                  // (lat: 42.36, lng: -71.06)
```

`geoPoint` composes `latitude` + `longitude` — same precision contract.

## Colors

`Rand.color()` / `colorDark()` / `colorLight()` → `CssColors` (148 variants). `.argb` is a 32-bit ARGB int (`Color(c.argb)` in Flutter). `.isDark` is a `CssColors` getter — computed YIQ luminance, not stored. For proper Flutter contrast picking, use `fluiver`'s `Color.contrastText`.

## Common traps

```dart
final list = [1, 2, 3];

// ❌ max is exclusive — a die roll never returns 6
final roll = Rand.integer(min: 1, max: 6);
// ✅
final die = Rand.integer(min: 1, max: 7);
final item = Rand.element(list);  // or: list[Rand.integer(max: list.length)]

// ❌ seed has no effect on password — CSPRNG every call
Rand.seed(42);
Rand.password();
// ✅ build deterministic tokens from your own Random

// ❌ subSet on a list with duplicates — compile error (requires Set):
// Rand.subSet([1, 2, 2], 2);
// ✅
Rand.subSet({1, 2}, 2);

// ❌ nonce / password as production secret
final jwtKey = Rand.nonce(length: 32);
// ✅ use a real KDF or platform keystore

// ❌ password rejected
Rand.password(length: 3);                                 // < 4 throws
Rand.password(lowercase: false, uppercase: false,
              digits: false, symbols: false);             // all-off throws

// Note: Rand.password() guarantees that at least one character
// from each enabled character set is present in the output.
```

## When NOT to use rand

- Production IDs → `package:uuid`.
- Locale-aware data → `package:faker`.
- A single `nextDouble` / `nextInt` → `dart:math.Random` directly, skip the dep.
- Tokens your security depends on → `package:cryptography` or platform keystore.

## Determinism

- `seed(N)` reproduces across runs on the **same Dart SDK / platform**. Not guaranteed across major SDK upgrades — `math.Random` internals can change.
- Seed in `setUp`, not `setUpAll` — each test starts from the same state whatever ran before it (`--name`, `--test-randomize-ordering-seed`).
- Crypto methods ignore `seed` / `useRng`.
