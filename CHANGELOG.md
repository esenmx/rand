# Changelog

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

## 2.0.3

- Updated dependencies

## 2.0.2

- Fixed `boolean()` regression
- Fixed max int for web

## 2.0.1

- Fixed `nullable()` default value

## 2.0.0

- Removed `documentId`, `uid` — use `id()`
- Renamed `mayBeNull` → `nullable`
- Added `alias`, `firstName`, `lastName`, `city`, `latitude`, `longitude`

## 1.0.0

- Initial release
