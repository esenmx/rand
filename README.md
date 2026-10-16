# rand

[![pub](https://img.shields.io/pub/v/rand.svg)](https://pub.dev/packages/rand)
[![pub points](https://img.shields.io/pub/points/rand)](https://pub.dev/packages/rand/score)
[![CI](https://github.com/esenmx/rand/actions/workflows/ci.yaml/badge.svg)](https://github.com/esenmx/rand/actions/workflows/ci.yaml)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

`rand` generates realistic random values for Dart — names, emails, dates, IP
addresses, UUIDs, lorem text, CSS colors, weighted picks — one static call each.
Seed it, and every call except the cryptographic ones returns the same values on
the next run. Pure Dart, all six platforms, no Flutter dependency.

## Why

Test data usually ends up as fixed strings (`'John Doe'`, `'test@test.com'`)
that exercise one path forever, or as a small `Random` helper that every project
writes again. Varied data covers more cases, but a random test that fails once
is hard to reproduce. `rand` gives you:

- **The helper, already written.** `Rand.email()`,
  `Rand.dateTime(min: a, max: b)`, `Rand.sample(items, count: 10, weights: w)`
  instead of code you maintain.
- **Failures you can replay.** Give each test a random seed and print it on
  failure; `Rand.seed(n)` brings back exactly the same data.
- **A strict, predictable API.** Ranges are half-open like `Random.nextInt`,
  default emails use reserved domains (`example.com`, `*.test`), never real
  ones, and invalid arguments throw instead of being quietly adjusted.

## Quick start

If only your tests use `rand`, add it as a dev dependency:

```bash
dart pub add dev:rand
```

App code uses it too (demo data, prototypes)? Run `dart pub add rand` instead.

A test that gets new data on every run and can still replay a failure:

```dart
import 'dart:convert';

import 'package:rand/rand.dart';
import 'package:test/test.dart';

void main() {
  // Fresh data on every run; a failing test prints the seed that replays it.
  setUp(() {
    Rand.seed();
    printOnFailure('Replay with Rand.seed(${Rand.currentSeed})');
  });

  test('a user survives a JSON round trip', () {
    final user = {'name': Rand.fullName(), 'email': Rand.email()};
    expect(jsonDecode(jsonEncode(user)), user);
  });
}
```

Fixed values instead? Seed with a constant. These are the values `Rand.seed(42)`
produces:

```dart
Rand.seed(42);
Rand.fullName();  // 'Sophia Tran'
Rand.email();     // 'david88@example.com'
Rand.ipv4();      // '143.61.48.184'
Rand.password();  // 12 chars, CSPRNG — not seeded
Rand.color();     // CssColors.darkKhaki
Rand.dateTime();  // 1972-02-25 21:42:51.597617Z
// 10 draws, 'common' 100 times as likely as 'rare'
Rand.sample(['rare', 'common'], count: 10, weights: [1, 100]);
```

---

## When to use it

- Test fixtures and seed data.
- Mocking API responses.
- Demos, prototypes, throwaway tokens.
- Game prototyping (loot-box weighting, dice, color palettes).

For composing structured fixtures (User, Address, Order, paginated responses,
chat history) on top of these primitives, see
[`example/recipes.dart`](example/recipes.dart).

## When not to use it

- **Not faker.** `rand` returns flat values. Compose typed entities yourself:
  `User(name: Rand.fullName(), city: Rand.city())`.
- **Not a crypto library.** `Rand.password()` and `Rand.nonce()` use the
  platform CSPRNG, but the package's stability contract is "test data," not
  production secrets. Defaults may shift across major versions.
- **Not a UUID library.** `Rand.uuidV4()`, `uuidV7()` and `ulid()` are seedable
  _test_ IDs drawn from the non-cryptographic RNG. For production IDs use
  [`package:uuid`](https://pub.dev/packages/uuid).

---

## API at a glance

Everything below is a static member of `Rand`, apart from the `RandGen` class
and the `CssColors` enum. A `RandGen` carries the same generators over your own
`Random`, minus the cryptographic ones and the seeding controls.

| Area | API |
| --- | --- |
| [Seeding](#seeding-and-reproducibility) | `seed`, `currentSeed`, `withSeed`, `useRng`, `RandGen` |
| [Numbers](#numbers) | `integer`, `float`, `latitude`, `longitude`, `charCode` |
| [Probability](#probability) | `boolean`, `nullable` |
| [Text](#text) | `word`, `words`, `sentence`, `paragraph`, `article` |
| [Identity and geo](#identity-and-geo) | `firstName`, `lastName`, `fullName`, `alias`, `city`, `geoPoint` |
| [Networking](#networking) | `email`, `ipv4`, `ipv6`, `mac`, `hex`, `semver`, `digits`, `slug` |
| [IDs](#ids) | `uuidV4`, `uuidV7`, `ulid` |
| [Time](#time) | `dateTime`, `duration` |
| [Collections](#collections) | `element`, `enumValue`, `subset`, `shuffled`, `mapKey`, `mapValue`, `mapEntry` |
| [Weighted sampling](#weighted-sampling) | `sample` |
| [Colors](#colors) | `color`, `colorDark`, `colorLight`, `CssColors` |
| [Cryptographic tokens](#cryptographic-tokens) | `bytes`, `nonce`, `password`, `base64`, `secureCharCode`, `base62Alphabet` (`Rand` only) |

---

## Seeding and reproducibility

`rand` uses two RNGs. Every non-cryptographic method draws from a replaceable
`Random`; the cryptographic ones always use `Random.secure()`.

```dart
import 'dart:math';

void main() {
  Rand.useRng(Random(42)); // any Random instance
  Rand.seed(42); // useRng(Random(42)), and Rand.currentSeed == 42
  Rand.useRng(Random.secure()); // global swap to a CSPRNG; clears currentSeed

  // One callback with its own seed; the global stream is untouched.
  final user = Rand.withSeed(7, () => (Rand.fullName(), Rand.email()));

  // An independent stream with the same non-crypto API.
  final gen = RandGen(Random(1));
  final name = gen.fullName();

  // One secure draw; the global RNG and currentSeed stay untouched.
  final picks = RandGen(Random.secure()).sample(['a', 'b', 'c'], count: 2);
}
```

`useRng` and `seed` mutate the global non-cryptographic RNG. `withSeed` scopes a
seed to one callback: it is zone-based, so it follows `await`s, nests (the inner
scope wins), and never touches the global. `RandGen` is the non-cryptographic
API as an instance over your own `Random` — inject it where explicit wiring
beats a global; independent instances are independent streams.
`RandGen.seeded(1)` is shorthand for `RandGen(Random(1))` without importing
`dart:math`. Cryptographic methods (`password`, `nonce`, `bytes`, `base64`,
`secureCharCode`) live only on `Rand`, always use `Random.secure()`, and ignore
all of these.

### Replay a failing test

Pick a random seed per test and print it only when the test fails:

```dart
import 'package:test/test.dart';

setUp(() {
  Rand.seed(); // random seed in [0, 2^32)
  printOnFailure('Rand seed: ${Rand.currentSeed}'); // replay with Rand.seed(n)
});
```

Seed in `setUp`, not `setUpAll`: each test starts from the same state whatever
ran before it (`--name`, `--test-randomize-ordering-seed`).

---

## Ranges and counts

Every range is `[min, max)` half-open, like `Random.nextInt` and `nextDouble`:
`integer`, `float`, `dateTime`, `duration`. An empty range (`min >= max`) throws
`ArgumentError`, like `nextInt(0)`.

Counts accept 0 and return an empty result (`words`, `sentence`, `paragraph`,
`article`, `bytes`, `subset`, `sample`). Single-token generators — `nonce`,
`hex`, `digits`, `base64`, `slug` — need a length of at least 1.

---

## Numbers

```dart
Rand.integer();                    // [0, 2^31)
Rand.integer(min: 50, max: 100);   // 50..99
Rand.float();                      // [0.0, 1.0), like nextDouble
Rand.float(min: 10, max: 20);      // [10.0, 20.0)
Rand.latitude();                   // -90..90, 5 decimal places
Rand.longitude(precision: 3);      // -180..180, 3 decimal places
Rand.charCode();                   // base62 code point (int)
```

`integer(max: list.length)` is always a valid index of a non-empty list (or just
call `Rand.element(list)`). `float`'s default `max` is 1, so `float(min: 5)`
throws — pass a `max`.

---

## Probability

```dart
Rand.boolean();                         // 50% true
Rand.boolean(trueChance: 90);           // 90% true
Rand.boolean(trueChance: 99.9);         // 99.9% true
Rand.nullable('value');                 // 50% null, useful in fixtures
Rand.nullable('value', nullChance: 90); // 90% null
```

---

## Text

Lorem ipsum from a built-in corpus.

```dart
Rand.word();                       // 'lorem'
Rand.words(count: 5);              // 'amet consectetur adipiscing elit sed'
Rand.words(count: 3, separator: '-');
Rand.sentence();                   // 'Lorem ipsum dolor sit amet.'
Rand.sentence(count: 3);           // 3 unique sentences joined by ' '
Rand.paragraph(count: 3);          // 3 sentences joined by ' '
Rand.article(count: 5);            // 5 paragraphs separated by '\n\n'
```

`words(count: N)` and `sentence(count: N)` use `subset` — the same word/sentence
never repeats in one call (corpora: 167 unique words, 856 sentences). For
repeats, call `word()` / `sentence()` N times yourself, or use
`paragraph(count: N)`.

---

## Identity and geo

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
~33% of draws versus ~13% of the Earth's surface, and rounding to `precision`
gives ±90 / ±180 half the weight of other values.

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
Rand.digits();                      // '047215'
Rand.slug();                        // 'lorem-ipsum-dolor'
```

`email` picks its default domain from a built-in list of RFC 2606 reserved names
(`example.com`, `example.org`, `example.net` and `*.test` domains) — safe to
ship in fixtures without collision risk. `ipv4` is not filtered for reserved
ranges; compose your own filter if you need only routable addresses. `ipv6` is
returned in full form (no `::` collapse) so fixture length stays stable. `hex`
is general-purpose lowercase hex — git SHAs, ETags, opaque content hashes. All
of these use the non-secure RNG and are reproducible under `Rand.seed`.

---

## IDs

```dart
final instant = DateTime.utc(2026, 10, 3, 12, 34, 56, 789);
Rand.uuidV4();                     // '1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed'
Rand.uuidV7(time: instant);        // '01a101c2-a895-7…'
Rand.uuidV7(time: DateTime.now()); // live clock
Rand.ulid(time: instant);          // '01M40W5A4N…', 26 chars
```

All three draw from the non-cryptographic RNG, so they reproduce under `seed`,
`withSeed` and `RandGen`. `uuidV7` and `ulid` take a required `time`: a fixed
instant keeps the whole ID stable for snapshot tests, `DateTime.now()` gives a
live clock. v7 and ULID sort by time across milliseconds but are not monotonic
within one; a `time` before 1970 or past year 10889 throws. Production IDs →
[`package:uuid`](https://pub.dev/packages/uuid).

---

## Time

```dart
Rand.dateTime();                              // [1970-01-01, 2038-01-01) UTC
Rand.dateTime(min: DateTime.utc(2020), max: DateTime.utc(2025));
Rand.duration(max: const Duration(days: 30)); // 0 to 30 days
Rand.duration(min: const Duration(days: 1), max: const Duration(days: 30));
```

`dateTime` and `duration` are `[min, max)` half-open and throw `ArgumentError`
on an empty or reversed range — including `dateTime(min: t)` with `t` at or
after 2038-01-01 and no `max`. `dateTime` always returns UTC.

---

## Collections

```dart
enum Status { active, suspended, deleted }
final fruits = ['apple', 'orange', 'lemon', 'grape', 'kiwi'];
final scores = {'Alice': 95, 'Bob': 87};

Rand.element(fruits);              // 'orange'
Rand.enumValue(Status.values);     // Status.suspended — typed enum draw
Rand.subset({1, 2, 3, 4, 5}, count: 3); // {2, 5, 1} — unique elements
Rand.shuffled(fruits);             // ['kiwi', 'grape', 'apple', ...] — copy
Rand.mapKey(scores);               // 'Bob'
Rand.mapValue(scores);             // 95
Rand.mapEntry(scores);             // MapEntry('Alice', 95)
```

Pick the right call:

| Need | Use |
| --- | --- |
| One element | `element(iterable)` |
| One enum member | `enumValue(MyEnum.values)` |
| N unique elements | `subset(set, count: N)` |
| N elements, repeats okay | `sample(list, count: N)` |
| N elements with weighted frequency | `sample(..., weights: [...])` |
| Whole list, reordered | `shuffled(list)` |
| One key / value / entry of a Map | `mapKey` / `mapValue` / `mapEntry` |

`subset` requires `Set<T>` — dedupe explicitly with `.toSet()` if your source
has duplicates.

---

## Weighted sampling

`sample` draws with replacement, optionally weighted.

```dart
// Loot box: weights are relative, so 1 : 10 : 100 is ~0.9% / ~9% / ~90%
final loot = Rand.sample(
  ['Legendary', 'Rare', 'Common'],
  count: 100,
  weights: [1, 10, 100],
);

// Equal probability — drop weights
final dice = Rand.sample([1, 2, 3, 4, 5, 6], count: 10);
```

`weights.length` must equal `from.length`. An empty `from` throws `StateError`
unless `count` is 0. For a _secure_ sample, draw from your own generator —
`RandGen(Random.secure()).sample(...)` — so the global RNG and
`Rand.currentSeed` stay untouched.

---

## Colors

```dart
final c = Rand.color();  // CssColors.coral
final name = c.name;     // 'coral'
final argb = c.argb;     // 0xFFFF7F50 — ARGB packed int
final isDark = c.isDark; // computed via YIQ luminance

Rand.colorDark();        // dark colors only — good for light backgrounds
Rand.colorLight();       // light colors only — good for dark backgrounds
```

148 CSS named variants. The `argb` int is Flutter-friendly: `Color(c.argb)`
works without conversion. `isDark` is a `CssColors` getter — computed from
`argb` via the YIQ luminance formula, not stored on the enum. Use it (or your
own contrast helper, e.g. [`fluiver`](https://pub.dev/packages/fluiver)'s
`Color.contrastText`) to pick a foreground.

---

## Cryptographic tokens

```dart
Rand.bytes(length: 32);      // Uint8List, always Random.secure()
Rand.nonce();                // 16-char base62, always Random.secure()
Rand.nonce(length: 32);
Rand.password();             // 12-char mixed-charset, always Random.secure()
Rand.password(length: 20, symbols: false);
Rand.base64();               // 16 bytes encoded, always Random.secure()
Rand.secureCharCode();       // base62 code point, always Random.secure()

// The 62 characters nonce, secureCharCode and charCode draw from
const alphabet = Rand.base62Alphabet; // 0-9, then A-Z, then a-z
```

Three rules:

1. **Seed doesn't reach secure methods.** `Rand.seed(42); Rand.password()` is
   fresh CSPRNG output every call. For reproducible token tests, generate them
   from your own `Random` instance.
2. **Don't ship rand-generated tokens as production secrets.** The RNG is
   correct; the package contract is "test data." Defaults can shift across major
   versions. Use [`package:cryptography`](https://pub.dev/packages/cryptography)
   or your platform's keystore for real secrets.
3. **`bytes` and `nonce` are always secure** post-v4 — the `secure:` parameter
   is gone.

Crypto methods throw under `dart test -p node`: dart2js has no secure RNG there.
Every other method works.

---

## Pitfalls

| ❌ | ✅ |
| --- | --- |
| `Rand.integer(min: 1, max: 6)` for a die roll — `max` is exclusive, never 6 | `Rand.integer(min: 1, max: 7)` |
| `Rand.float(min: 5)` — default `max` is 1, so it throws | Pass both bounds: `Rand.float(min: 5, max: 10)` |
| `Rand.integer(max: list.length)` on a list that may be empty — `[0, 0)` is empty and throws | Guard with `list.isNotEmpty`, or call `Rand.element(list)` |
| `Rand.seed(42); Rand.password()` — seed never reaches CSPRNG | Build deterministic tokens from your own `Random(42)` |
| `Rand.subset([1, 2, 2], count: 2)` — compile error: `subset` takes a `Set<T>` | Pass a set: `Rand.subset({1, 2}, count: 2)`, or dedupe with `.toSet()` |
| Shipping `Rand.nonce` / `Rand.password` as production secrets | Use `package:cryptography` or a platform keystore |
| `setUpAll(() => Rand.seed(42))` | Use `setUp` — each test starts from the same state whatever ran before it (`--name`, `--test-randomize-ordering-seed`) |
| `list..shuffle()` to "get a random order" without keeping the original | `Rand.shuffled(list)` — non-mutating copy |

---

## Agent skill

This package ships an agent skill in `skills/rand-test-data/`. Install it into
your project's agent config with:

```sh
dart run skills@ get --package rand --all
```

Add `--agent <name>` (claude, cursor, codex, copilot, …) when no agent config is
detected.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

MIT — see [LICENSE](LICENSE).
