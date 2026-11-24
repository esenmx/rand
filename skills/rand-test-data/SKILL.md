---
name: rand-test-data
description: Generate random Dart test data via `package:rand` — names, emails, IPv4/IPv6/MAC, hex, slugs, digit codes, semver, lorem, colors, weighted sampling, geo points, UUID v4/v7 and ULID test IDs, crypto tokens; isolated streams (`RandGen`), scoped seeds (`withSeed`), seed reporting. Use for test fixtures, mocked API responses, demo seeds, any fake/seeded data. Skip for production secrets (`cryptography`), locale-aware names (`faker`).
---

# rand-test-data

`import 'package:rand/rand.dart';` -> `Rand.x()`. Static API; non-obvious contracts below.

## Two-RNG split (load-bearing)

|RNG|Methods|Reset by `useRng`/`seed`?|
|-|-|-|
|`Random` (replaceable)|everything else|yes|
|`Random.secure()` (fixed)|`password`, `nonce`, `bytes`, `base64`, `secureCharCode`|**no**|

- `Rand.seed(42); Rand.password()` is fresh CSPRNG every call; for deterministic password-shaped data, build from own `Random(42)`.
- Secure non-crypto draw: `RandGen(Random.secure()).sample(...)` (`useRng` also clears `currentSeed` globally).
- Never ship `rand` tokens as production secrets (defaults can shift in majors) -> use `package:cryptography` or platform keystore.

## Pick the call

|Goal|Use|
|-|-|
|One element|`Rand.element(iterable)`|
|One enum member|`Rand.enumValue(MyEnum.values)`|
|N unique elements|`Rand.subset(set, count: N)` (`Set<T>` only; `.toSet()` first; keeps the source's equality, ordering and runtime element type)|
|N elements, repeats ok|`Rand.sample(list, count: N)` (empty `from` throws unless `count == 0`)|
|Weighted draws (1%/10%/89%)|`Rand.sample(['L','R','C'], count: 100, weights: [1, 10, 89])` (relative; one weight per element of `from`)|
|Non-mutating shuffle|`Rand.shuffled(list)`|
|Map entry/key/value|`Rand.mapKey` / `mapValue` / `mapEntry`|
|Nullable field, 20% null|`Rand.nullable(value, nullChance: 20)`|
|10 fake users|`List.generate(10, (_) => (id: Rand.hex(length: 24), name: Rand.fullName(), email: Rand.email()))`|
|Paginated response|`(page: 1, totalPages: 7, items: List.generate(5, (_) => buildItem()))`|
|Sorted timestamps, last hour|`[for (var i = 0; i < 20; i++) Rand.dateTime(min: DateTime.now().subtract(const Duration(hours: 1)), max: DateTime.now())]..sort((a, b) => a.compareTo(b))`|
|Git SHA / opaque token|`Rand.hex(length: 40)` / `Rand.base64(byteLength: 32)` (CSPRNG)|
|Isolated injected stream|`RandGen(Random(1))` (same non-crypto API, no crypto methods)|
|Zone-scoped seed|`Rand.withSeed(7, () => ...)` (follows `await`, nests)|
|Reproducible fixture|`setUp(() => Rand.seed(42));`|
|Replayable random seed|`Rand.seed(); printOnFailure('Rand seed: ${Rand.currentSeed}')` in `setUp`|
|Seedable test IDs|`Rand.uuidV4()` / `Rand.uuidV7(time: t)` / `Rand.ulid(time: t)` (`time` required)|

Compose primitives flatly; full User/Address/Order/Paginated/ChatHistory composers in [`example/recipes.dart`](../../example/recipes.dart).

## Networking, strings, geo & colors (reproducible under `seed`)

```dart
Rand.email(); // 'olivia42@example.com', RFC 2606 domains
Rand.email(domain: 'mycompany.io');
Rand.ipv4(); // not filtered for reserved ranges
Rand.ipv6(); // full form, no `::` collapse
Rand.mac(separator: '-'); // default ':'
Rand.hex(); // lowercase, default length 8
Rand.semver(); // 'major.minor.patch', no pre-release
Rand.digits(length: 4); // decimal (default 6), leading zeros kept
Rand.slug(wordCount: 5); // default 3 unique lorem words, '-' joined
final (:lat, :lng) = Rand.geoPoint();
Rand.geoPoint(precision: 2); // composes latitude + longitude
```

`Rand.color()` / `colorDark()` / `colorLight()` -> `CssColors` (148 variants). `.argb` is 32-bit ARGB int (`Color(c.argb)`); `.isDark` is computed YIQ luminance (for WCAG contrast use `fluiver`'s `Color.contrastText`).

## Bounds, traps & determinism

- `integer`, `float`, `duration`, `dateTime` are half-open `[min, max)` (`min >= max` throws `ArgumentError`; die roll is `min: 1, max: 7`). `float()` defaults to `[0, 1)`; `dateTime` returns UTC.
- On JS web, `integer`/`duration`/`dateTime` throw `ArgumentError` beyond ±(2^53 - 1) (microseconds for time, ~1685..2255). Native/Wasm unrestricted.
- Counts allow 0; `nonce`/`hex`/`digits`/`base64`/`slug` require length >= 1. `password` rejects `length < 4` or all charsets off, and guarantees >=1 char per enabled set.
- `seed(N)` reproduces on same Dart SDK/platform only (not across major SDKs). Seed in `setUp`, never `setUpAll`.
- Skip `rand` for: production IDs (`package:uuid`), locale-aware data (`package:faker`), single `nextInt`/`nextDouble` (`dart:math.Random`), production secrets (`package:cryptography`).
