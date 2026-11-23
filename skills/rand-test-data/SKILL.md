---
name: rand-test-data
description: Generate random Dart test data via `package:rand` — names, emails, IPv4/IPv6/MAC, hex, slugs, digit codes, semver, lorem, colors, weighted sampling, geo points, UUID v4/v7 and ULID test IDs, crypto tokens; isolated streams (`RandGen`), scoped seeds (`withSeed`), seed reporting. Use for test fixtures, mocked API responses, demo seeds, any fake/seeded data. Skip for production secrets (`cryptography`), locale-aware names (`faker`).
---

# rand-test-data

`import 'package:rand/rand.dart';` -> `Rand.x()`. Static API; non-obvious contracts below.

## Lazy references

- Fixture composer recipes, networking/hex/semver/slug primitives, `geoPoint`, `CssColors` -> [references/recipes.md](references/recipes.md).

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
|N unique elements|`Rand.subset(set, count: N)` (`Set<T>` only; `.toSet()` first)|
|N elements, repeats ok|`Rand.sample(list, count: N)` (`weights:` must match `from.length`; empty `from` throws unless `count == 0`)|
|Non-mutating shuffle|`Rand.shuffled(list)`|
|Map entry/key/value|`Rand.mapKey` / `mapValue` / `mapEntry`|
|Nullable field|`Rand.nullable(value, nullChance: 20)`|
|Isolated injected stream|`RandGen(Random(1))` (same non-crypto API, no crypto methods)|
|Zone-scoped seed|`Rand.withSeed(7, () => ...)` (follows `await`, nests)|
|Replayable random seed|`Rand.seed(); printOnFailure('Rand seed: ${Rand.currentSeed}')` in `setUp`|
|Seedable test IDs|`Rand.uuidV4()` / `Rand.uuidV7(time: t)` / `Rand.ulid(time: t)` (`time` required)|

## Bounds, traps & determinism

- `integer`, `float`, `duration`, `dateTime` are half-open `[min, max)` (`min >= max` throws `ArgumentError`; die roll is `min: 1, max: 7`). `float()` defaults to `[0, 1)`; `dateTime` returns UTC.
- On JS web, `integer`/`duration`/`dateTime` throw `ArgumentError` beyond ±(2^53 - 1) (microseconds for time, ~1685..2255). Native/Wasm unrestricted.
- Counts allow 0; `nonce`/`hex`/`digits`/`base64`/`slug` require length >= 1. `password` rejects `length < 4` or all charsets off, and guarantees >=1 char per enabled set.
- `seed(N)` reproduces on same Dart SDK/platform only (not across major SDKs). Seed in `setUp`, never `setUpAll`.
- Skip `rand` for: production IDs (`package:uuid`), locale-aware data (`package:faker`), single `nextInt`/`nextDouble` (`dart:math.Random`), production secrets (`package:cryptography`).
