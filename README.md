# rand

[![pub](https://img.shields.io/pub/v/rand.svg)](https://pub.dev/packages/rand)
[![pub points](https://img.shields.io/pub/points/rand)](https://pub.dev/packages/rand/score)
[![CI](https://github.com/esenmx/rand/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/rand/actions/workflows/ci.yaml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Random data for Dart.** Numbers, text, names, dates, networking,
CSS colors, seedable test IDs, cryptographic tokens. One static class (plus
`RandGen` for injected streams), two RNGs, all six platforms. Pure Dart, no
Flutter dependency.

```dart
Rand.fullName();       // → 'Emma Rodriguez'
Rand.email();          // → 'olivia42@example.com'
Rand.ipv4();           // → '203.0.113.42'
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
- **Not a UUID library.** `Rand.uuidV4()`, `uuidV7()` and `ulid()` are
  seedable *test* IDs drawn from the non-cryptographic RNG. For production
  IDs use [`package:uuid`](https://pub.dev/packages/uuid).

For composing structured fixtures (User, Address, Order, paginated responses,
chat history) on top of these primitives, see
[`example/recipes.dart`](example/recipes.dart).

---

## Install

```bash
dart pub add rand
```

---

## Configuring the RNG

```dart
Rand.useRng(Random(42));      // any Random instance
Rand.seed(42);                // useRng(Random(42)), and Rand.currentSeed == 42
Rand.useRng(Random.secure()); // cryptographically secure for non-crypto methods

final user = Rand.withSeed(7, () => (Rand.fullName(), Rand.email()));
final gen = RandGen(Random(1)); // independent stream, same non-crypto API
gen.fullName();
```

`useRng` and `seed` mutate the global non-cryptographic RNG. `withSeed` scopes
a seed to one callback: it is zone-based, so it follows `await`s, nests (the
inner scope wins), and never touches the global. `RandGen` is the
non-cryptographic API as an instance over your own `Random` — inject it where
explicit wiring beats a global; independent instances are independent streams.
Cryptographic methods (`password`, `nonce`, `bytes`, `base64`,
`secureCharCode`) live only on `Rand`, always use `Random.secure()`, and
ignore all of these.

Seed reporting — a random seed per run that you can replay on failure:

```dart
setUp(() {
  Rand.seed();                                  // random seed in [0, 2^32)
  printOnFailure('Rand seed: ${Rand.currentSeed}'); // replay with Rand.seed(n)
});
```

Seed in `setUp`, not `setUpAll`: each test starts from the same state whatever
ran before it (`--name`, `--test-randomize-ordering-seed`).

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

## Networking

```dart
Rand.email();                       // 'olivia42@example.com'
Rand.email(domain: 'mycompany.io'); // 'james7@mycompany.io'
Rand.ipv4();                        // '203.0.113.42'
Rand.ipv6();                        // '2001:0db8:85a3:0000:0000:8a2e:0370:7334'
Rand.mac();                         // '3a:5f:9c:8e:2d:71'
Rand.mac(separator: '-');           // '3a-5f-9c-8e-2d-71'
Rand.hex(length: 40);               // git-SHA-shaped opaque hex
Rand.semver();                      // '3.7.42'
Rand.otp();                         // '047215'
Rand.slug();                        // 'lorem-ipsum-dolor'
```

`email` defaults pick from a built-in list of RFC 2606 example/test
TLDs — safe to ship in fixtures without collision risk. `ipv4` is not
filtered for reserved ranges; compose your own filter if you need only
routable addresses. `ipv6` is returned in full form (no `::` collapse)
so fixture length stays stable. `hex` is general-purpose lowercase hex
— git SHAs, ETags, opaque content hashes. `semver`, `otp`, `slug` use
the non-secure RNG and are reproducible under `Rand.seed`.

---

## IDs

```dart
Rand.uuidV4();                    // '1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed'
Rand.uuidV7();                    // 48-bit ms timestamp (now), then random bits
Rand.uuidV7(time: DateTime.utc(2026, 10, 3, 12, 34, 56, 789)); // '01a101c2-a895-7…'
Rand.ulid();                      // 26-char Crockford base32, '01M40W5A4N…'
```

All three draw from the non-cryptographic RNG, so they reproduce under
`seed`, `withSeed` and `RandGen` — stable IDs for snapshot tests. `time`
defaults to `DateTime.now()`; v7 and ULID sort by time across milliseconds
but are not monotonic within one; a `time` before 1970 or past year 10889
throws. Production IDs → [`package:uuid`](https://pub.dev/packages/uuid).

---

## Cryptographic — secure vs non-secure

```dart
Rand.bytes(32);              // Uint8List, always Random.secure()
Rand.nonce();                // 16-char base62, always Random.secure()
Rand.nonce(length: 32);
Rand.password();             // 12-char mixed-charset, always Random.secure()
Rand.password(length: 20, symbols: false);
Rand.base64();               // 16 bytes encoded, always Random.secure()
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

Crypto methods throw under `dart test -p node`: dart2js has no secure RNG
there. Every other method works.

---

## Identity & geo

```dart
Rand.firstName();   // 'Olivia'
Rand.lastName();    // 'Thompson'
Rand.fullName();    // 'James Michael Wilson' — 0..2 weighted middle names
Rand.alias();       // 'Achilles'
Rand.city();        // 'Boston'
Rand.geoPoint();    // (lat: 42.36011, lng: -71.05891) — named record
```

Corpora are US/English-leaning. For locale-aware data, reach for
[`package:faker`](https://pub.dev/packages/faker).

Geo points are uniform in degrees, not over the sphere's area: |lat| > 60 is
~33 % of draws versus ~13 % of the Earth's surface, and rounding to
`precision` gives ±90 / ±180 half the weight of other values.

---

## Text — lorem corpus

```dart
Rand.word();                       // 'lorem'
Rand.words(count: 5);              // 'amet consectetur adipiscing elit sed'
Rand.words(count: 3, separator: '-');
Rand.sentence();                   // 'Lorem ipsum dolor sit amet.'
Rand.sentence(3);                  // 3 unique sentences joined by ' '
Rand.paragraph(3);                 // 3 sentences joined by ' '
Rand.article(5);                   // 5 paragraphs separated by '\n\n'
```

`words(count: N)` and `sentence(N)` use `subSet` — the same word/sentence never
repeats in one call (corpora: 167 unique words, 856 sentences). For repeats, call
`word()` / `sentence()` N times yourself, or use `paragraph(N)`.

---

## Time

```dart
Rand.dateTime();                                       // [1970-01-01, 2038-01-01) UTC
Rand.dateTime(DateTime(2020), DateTime(2025));         // custom range, half-open
Rand.duration(max: const Duration(days: 30));          // 0 to 30 days
Rand.duration(min: const Duration(days: 1), max: const Duration(days: 30));
```

`dateTime` and `duration` are `[min, max)` half-open, return `min` when
`min == max`, and throw `ArgumentError` on a reversed range — including
`dateTime(start)` with `start` after 2038-01-01 and no `end`.

---

## Collections

```dart
enum Status { active, suspended, deleted }
final fruits = ['apple', 'orange', 'lemon', 'grape', 'kiwi'];
final scores = {'Alice': 95, 'Bob': 87};

Rand.element(fruits);              // 'orange'
Rand.enumValue(Status.values);     // Status.suspended — typed enum draw
Rand.subSet({1, 2, 3, 4, 5}, 3);   // {2, 5, 1} — unique elements
Rand.shuffled(fruits);             // ['kiwi', 'grape', 'apple', ...] — copy
Rand.mapKey(scores);               // 'Bob'
Rand.mapValue(scores);             // 95
Rand.mapEntry(scores);             // MapEntry('Alice', 95)
```

Pick the right call:

|Need|Use|
|---|---|
|One element|`element(iterable)`|
|One enum member|`enumValue(MyEnum.values)`|
|N unique elements|`subSet(set, N)`|
|N elements, repeats okay|`sample(from: list, count: N)`|
|N elements with weighted frequency|`sample(..., weights: [...])`|
|Whole list, reordered|`shuffled(list)`|
|One key / value / entry of a Map|`mapKey` / `mapValue` / `mapEntry`|

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

## Pitfalls

|❌|✅|
|---|---|
|`Rand.integer(max: list.length)` — inclusive, can return `list.length`|`Rand.element(list)` or `Rand.integer(max: list.length - 1)`|
|`Rand.seed(42); Rand.password()` — seed never reaches CSPRNG|Build deterministic tokens from your own `Random(42)`|
|`Rand.subSet([1, 2, 2], 2)` — compile error: `subSet` takes a `Set<T>`|Pass a set: `Rand.subSet({1, 2}, 2)`, or dedupe with `.toSet()`|
|`Rand.nullable(x, 80)` thinking "80% present"|Arg is `nullChance` — 80% returns **null**. Flip to `Rand.nullable(x, 20)` for 80% present|
|Shipping `Rand.nonce` / `Rand.password` as production secrets|Use `package:cryptography` or a platform keystore|
|`setUpAll(() => Rand.seed(42))`|Use `setUp` — each test starts from the same state whatever ran before it (`--name`, `--test-randomize-ordering-seed`)|
|`list..shuffle()` to "get a random order" without keeping the original|`Rand.shuffled(list)` — non-mutating copy|

---

## Agent skill

This package ships an agent skill in `skills/rand-test-data/`. Install it into your project's agent config with:

```sh
dart run skills@ get --package rand --all
```

Add `--agent <name>` (claude, cursor, codex, copilot, …) when no agent config is detected.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

MIT — see [LICENSE](LICENSE).
