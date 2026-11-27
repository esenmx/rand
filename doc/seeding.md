# Seeding and testing

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

## When to use it

- Test fixtures and seed data.
- Mocking API responses.
- Demos, prototypes, throwaway tokens.
- Game prototyping (loot-box weighting, dice, color palettes).

For composing structured fixtures (User, Address, Order, paginated responses,
chat history) on top of these primitives, see
[`example/recipes.dart`](../example/recipes.dart).

## When not to use it

- **Not faker.** `rand` returns flat values. Compose typed entities yourself:
  `User(name: Rand.fullName(), city: Rand.city())`.
- **Not a crypto library.** `Rand.password()` and `Rand.nonce()` use the
  platform CSPRNG, but the package's stability contract is "test data," not
  production secrets. Defaults may shift across major versions.
- **Not a UUID library.** `Rand.uuidV4()`, `uuidV7()` and `ulid()` are seedable
  _test_ IDs drawn from the non-cryptographic RNG. For production IDs use
  [`package:uuid`](https://pub.dev/packages/uuid).

## Seeding and reproducibility

`rand` uses two RNGs. Every non-cryptographic method draws from a replaceable
`Random`; the cryptographic ones always use `Random.secure()`.

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

## Ranges and counts

Every range is `[min, max)` half-open, like `Random.nextInt` and `nextDouble`:
`integer`, `float`, `dateTime`, `duration`. An empty range (`min >= max`) throws
`ArgumentError`, like `nextInt(0)`.

Compiled to JavaScript, where ints are doubles, `integer`, `dateTime` and
`duration` also throw `ArgumentError` for a bound beyond ±(2^53 - 1), in
microseconds for time (about 1685..2255 for `dateTime`). Native and dart2wasm
ints are 64-bit and have no such limit.

Counts accept 0 and return an empty result (`words`, `sentence`, `paragraph`,
`article`, `bytes`, `subset`, `sample`). Single-token generators — `nonce`,
`hex`, `digits`, `base64`, `slug` — need a length of at least 1.
