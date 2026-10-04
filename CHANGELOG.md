# Changelog

## Unreleased

### Added

- `RandGen` — the non-cryptographic API as an instance over your own `Random`: `RandGen(Random(1)).fullName()`. Independent instances are independent streams.
- `Rand.withSeed(seed, body)` — runs `body` with every non-cryptographic `Rand.*` call drawing from `Random(seed)`. Zone-scoped: follows async continuations, nests, and never touches the global RNG.
- `Rand.seed()` without a value picks a random seed; `Rand.currentSeed` reports it (`setUp(() { Rand.seed(); printOnFailure('Rand seed: ${Rand.currentSeed}'); })`).
- Seedable test IDs: `Rand.uuidV4()`, `Rand.uuidV7({time})`, `Rand.ulid({time})` (also on `RandGen`). Drawn from the non-cryptographic RNG, so reproducible under `seed`/`withSeed`; `time` defaults to now; not monotonic within a millisecond. Production IDs → `package:uuid`.

### Changed

- Requires Dart 3.13 / Flutter 3.47 (was Dart `>=3.0.0`).
- `sample` throws `ArgumentError` naming `weights` for negative weights, all-zero weights, or weights summing past 2^32 (was a silent skew or an unnamed error).
- Seeded `charCode` sequences change (now uniform over base62).
- Seeded default `email` domains change: `test.com`, `demo.dev`, `sample.app`, `fake.io` became `acme.test`, `demo.test`, `sample.test`, `fake.test`.
- `paragraph`/`article` text changes: sentences are joined by `" "` (single periods).
- Seeded `fullName` output changes wherever a middle or last name would have repeated an earlier part: a fresh name is drawn instead, which also shifts every later draw from that seeded stream.
- Negative counts and lengths throw `ArgumentError` naming the parameter: `words`, `paragraph`, `article`, `subSet`, `sample`, `bytes`, `nonce`. A count or length of 0 still returns an empty result.
- `duration` and `dateTime` throw `ArgumentError` on reversed ranges, including `dateTime(start)` with `start` after 2038-01-01 and no `end` (was a silently reversed range).
- `latitude`, `longitude` and `geoPoint` throw `RangeError` outside precision 0..15.
- NaN `boolean`/`nullable` chances and non-finite `float` bounds throw `ArgumentError`.
- Seeded negative-range `duration` and pre-1970 `dateTime` values change (now floored into `[min, max)`).
- `float`, `duration` and `dateTime` no longer consume a draw when `min == max`, so later draws from a seeded stream that makes such calls shift.
- Agent skill directory renamed `skills/dart-rand` → `skills/rand-test-data` (installable with `dart run skills@ get --package rand --all`).

### Fixed

- `sample` with `weights` longer than `from` no longer throws `RangeError`; the extra weights are ignored, as documented.
- `sample` with an empty `from` returns a growable list.
- `nonce`, `secureCharCode` and `charCode` are uniform over base62. Digits were 33 % of characters instead of 16 %, so a 16-char nonce had 78.5 bits of min-entropy instead of ~95.
- Default `email` domains are all RFC 2606 reserved; `test.com`, `demo.dev`, `sample.app` and `fake.io` are real domains.
- `paragraph` and `article` no longer emit `..` between sentences.
- `fullName` never repeats a name within one result.
- Non-cryptographic methods no longer create `Random.secure()`, so they work where it is unavailable (e.g. `dart test -p node`).
- Half-open `[min, max)` holds for negative `duration` and pre-1970 `dateTime` ranges; truncation toward zero could return `max` and never `min`.
- `float` returns exactly `min` when `min == max` (could be off by one ulp).
- `integer` accepts spans up to 2^32 − 1 (was 2^31 − 1), and its range error names `max` (was `difference`).
- `bytes` draws 4 bytes per CSPRNG call.
- `dateTime`'s documented default end is 2038-01-01 (was documented as 2038-01-19).
- The agent skill's networking snippet compiles (named arguments, not set literals).
- README: corpus size (167 unique words, not 1023), the `subSet` pitfall (a list literal is a compile error), example values, and the reason to seed in `setUp` corrected.

### Removed

- `SECURITY.md` (no private vulnerability-report channel; the crypto-scope guidance is in the README).

## 4.2.0

**Multi-sentence lorem.** No breaking changes.

### Added

- **Text** — `Rand.sentence([count])` accepts an optional count and returns that
  many unique sentences joined by `" "`, drawn via `subSet` from the
  856-sentence corpus. `Rand.sentence()` is unchanged. Throws `ArgumentError`
  below 1, `RangeError` above the corpus size — unlike `paragraph(count)`,
  which allows repeats.

## 4.1.1

**Performance optimizations and bug fixes.**

### Fixed
- **Correctness** — Fixed `Rand.boolean()` to respect double-precision probabilities instead of rounding.
- **Correctness** — Fixed `Rand.dateTime()` to correctly return a UTC `DateTime` representation as documented.
- **Correctness** — Guaranteed representation of all enabled character sets in `Rand.password()`.
- **Correctness** — Fixed potential double overflow in boundary calculations.
- **Performance** — Removed expensive string format/parsing roundtrips in latitude/longitude calculations.
- **Performance** — Optimized `Rand.subSet()` set traversal complexity using Fisher-Yates list partition.
- **Performance** — Library-level caching for CSS colors and unique words to avoid dynamic allocations and repeated lazy filtering.
- **Performance** & **Memory** — Single-pass buffer allocation using `Uint16List` and direct `Uint8List` populations in cryptographic and networking primitives.
- **Optimization** — Converted all data corpus variables to `const` lists.

## 4.1.0

**Identity & networking test data.** 12 new primitives, no breaking changes.

### Added

- **Networking** — `Rand.email({domain})`, `Rand.ipv4()`, `Rand.ipv6()`,
  `Rand.mac({separator})`, `Rand.hex({length})`. `email` defaults to RFC 2606
  example/test TLDs (`example.com`, `test.com`, etc.) — fixture-safe.
  `ipv6` is returned in full uncompressed form so length is stable.
  `hex` is general-purpose lowercase hex (git SHAs at `length: 40`, ETags, etc.)
  and reproducible under `Rand.seed`.
- **String synthesis** — `Rand.semver({maxMajor, maxMinor, maxPatch})` (no
  pre-release suffix), `Rand.otp({length})` (zero-padded decimal digits),
  `Rand.slug({wordCount, separator})` (unique lorem words),
  `Rand.base64({byteLength})` (crypto-secure parallel to `nonce`).
- **Collection ergonomics** — `Rand.enumValue<T extends Enum>(values)`
  (type-safe wrapper over `element` for enums) and `Rand.shuffled<T>(list)`
  (non-mutating copy + shuffle; distinct from `sample`/`subSet`).
- **Geo** — `Rand.geoPoint({precision})` returns a named record
  `({double lat, double lng})` composing `latitude` + `longitude`.
- New mixin `_Networking` under `lib/src/_networking.dart`.
- Example app (`example/main.dart`) gains Networking section and uses
  the new methods in Geo, Collections, and Cryptographic sections.

### Changed

- README adds a Networking section and extends Collections with `enumValue`
  / `shuffled` rows. SKILL.md description and "Picking the right call"
  table updated to cover the new methods.

## 4.0.0

**Breaking — major overhaul.**

Bundles bug fixes, modern Dart conventions, mixin-based internal layout,
and an LLM-focused polish pass matching `fluiver` and `collection_notifiers`.
Ships a description-triggered LLM skill at `skills/dart-rand/SKILL.md`
(folder named `dart-rand` to avoid colliding with other languages' `rand`
namespaces).

### Breaking

|v3.x|v4.0|
|---|---|
|`CSSColors` (enum)|`CssColors` — modern Dart PascalCase|
|`c.color` (int field)|`c.argb` — clarifies it's a 32-bit ARGB packed int|
|`c.isDark` (stored field)|`c.isDark` (computed via `CssColorsX` extension, YIQ luminance)|
|`Rand.bytes(32, true)` / `Rand.bytes(32, secure: true)`|`Rand.bytes(32)` — always secure|
|`Rand.nonce(secure: true)`|`Rand.nonce()` — always secure|
|`Rand.subSet([1, 2, 2], 2)`|`Rand.subSet({1, 2}, 2)` — `Set<T>` only|
|`Rand.sample(..., secure: true)`|`Rand.useRng(Random.secure()); Rand.sample(...)`|
|`Rand.element([])` → `RangeError`|`Rand.element([])` → `StateError`|

### Fixed

- `Rand.nonce()` now returns a true base62 string. The v3 implementation
  used `Random.secure().nextInt(256)` and produced arbitrary byte codepoints
  including control characters and surrogates despite documentation saying
  "base62 string."
- `Rand.duration` and `Rand.dateTime` dartdoc now spells out the half-open
  `[min, max)` upper bound. Tests for both methods previously asserted
  `inMicroseconds > min` strictly; the underlying `_lerp` returns exactly
  `min` when `nextDouble()` returns 0, so the strict comparison was a flake
  waiting to happen. Both tests now use `>=`.
- `Rand.element(Iterable)` on an empty input now throws
  `StateError('Rand.element: cannot draw from empty iterable')` instead of
  the cryptic `RangeError: 0`. `Rand.mapKey({})` / `Rand.mapValue({})` /
  `Rand.mapEntry({})` get the same treatment.
- `base62` constant is no longer marked `@visibleForTesting` — it's a real
  public constant, exported as such.

### Added

- `Rand.useRng(Random rng)` — replaces the global non-cryptographic RNG.
  `Rand.seed(value)` is now a shortcut for `useRng(Random(value))`.
- `CssColors implements Comparable<CssColors>` — sort by named-color order.
- `CssColorsX` extension exposing `isDark` as a computed getter (YIQ
  luminance from `argb`). Replaces the hand-curated `isDark` field. Some
  borderline colors may flip classification vs v3.
- `skills/dart-rand/SKILL.md` — tool-agnostic LLM skill. Description-triggered
  (activates only when the user's task matches its scope), so it stays out
  of the way for unrelated work. Folder named `dart-rand` to avoid colliding
  with other languages' `rand` namespaces. Vendor to
  `~/.claude/skills/dart-rand/` or `.claude/skills/dart-rand/`.
- GitHub Actions CI (format, analyze, test on stable+beta matrix, coverage,
  pana, example analyze) and tag-triggered OIDC publish workflow.
- `SECURITY.md` with a scope-of-security statement and private
  vulnerability-reporting flow.
- `makefile`, `codecov.yml`, PR template, bug/feature issue templates,
  dependabot config.
- `pubspec.yaml` declares `platforms:` (android, ios, linux, macos, web,
  windows) and `documentation:` URL.
- Heavy dartdoc on every public `Rand.*` method with fenced examples,
  range notation (`[min, max]` inclusive vs `[min, max)` half-open spelled
  out), `Throws` clauses, and `See also:` cross-references.
- Test coverage for seed reproducibility, `useRng` equivalence, distribution
  uniformity, and crypto-methods-ignore-seed invariants.

### Changed

- File layout: `lib/rand.dart` is now the class shell with 32 static
  delegators and the heavy dartdoc. Real implementation lives in per-category
  mixins under `lib/src/_*.dart` (`_Booleans`, `_Numbers`, `_Crypto`, `_Time`,
  `_Collections`, `_Sampling`, `_Text`, `_Identity`, `_Colors`).
  `_RandImpl` composes them and holds `rng` + `secureRng` fields.
- README rewritten — no emoji, code-heavy, ~250 lines. Adds "What it's for"
  and "What it isn't" framing and a `Color(c.argb)` Flutter-usage note.
- `topics:` — drop `faker` (misleading), add `fixtures`.
- `analysis_options.yaml` — comment explains why `lib/data/*.dart` is
  excluded (static corpora, no actionable lint signal, faster analyzer).

### Removed

- `meta` dependency — no longer needed after dropping `@visibleForTesting`.
- `example/.metadata` — stray Flutter project artifact from a reverted
  Flutter conversion (commit `7ccb947`).
- `secure:` parameter on `Rand.bytes`, `Rand.nonce`, and `Rand.sample`. The
  first two are now always secure; for a secure `sample`, switch the
  global RNG first via `Rand.useRng(Random.secure())`.

## 3.1.0

- `duration()` now uses named parameters: `duration(max:, min:)`
- `nullable()` parameter renamed: `probability` → `nullChance`
- `boolean()` parameter renamed: `probability` → `trueChance`
- Removed `id()` — use `nonce()` (now has default length of 16)
- `latitude()` / `longitude()` now use decimal places (not significant figures)

## 3.0.2

- Not documented.

## 3.0.1

- `integer()` and `float()` now use named parameters (`min:`, `max:`)
- `sample()` replaces `weightedRandomizedArray()`
- `charCode()` and `secureCharCode()` replace `char()` and `charSecure()`
- Removed `dateTimeYear()` — use `dateTime(DateTime(year1), DateTime(year2))`
- Collection params renamed to `from`
- Password params: `lowercase`, `uppercase`, `digits`, `symbols`
- `color()`, `colorDark()`, `colorLight()` for CSS colors
- `CSSColors` enum with 148 named colors
- `ArgumentError` exceptions instead of assertions
- Comprehensive tests with `checks` package

## 3.0.0

- Not documented.

## 2.0.3

- Updated dependencies

## 2.0.2+2

- Not documented.

## 2.0.2+1

- Not documented.

## 2.0.2

- Fixed `boolean()` regression
- Fixed max int for web

## 2.0.1

- Fixed `nullable()` default value

## 2.0.0

- Removed `documentId`, `uid` — use `id()`
- Renamed `mayBeNull` → `nullable`
- Added `alias`, `firstName`, `lastName`, `city`, `latitude`, `longitude`

## 1.0.3

- Not documented.

## 1.0.2

- Not documented.

## 1.0.1

- Not documented.

## 1.0.0

- Initial release
