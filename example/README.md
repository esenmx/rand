# rand example

A CLI demo of every `Rand.*` method in the
[rand](https://pub.dev/packages/rand) package, with formatted ANSI output.

## Run

From the repository root:

```bash
dart run example/main.dart
dart run example/recipes.dart
```

Or from inside `example/`:

```bash
dart pub get
dart run main.dart
dart run recipes.dart
```

## What it shows

`main.dart` — every primitive in `Rand.*`:

- Numbers, booleans, floats, lat/lng, `geoPoint`.
- Identity and city corpora.
- Lorem text — word / sentence / paragraph granularity.
- Networking — `email`, `ipv4`, `ipv6`, `mac`, `hex`, `slug`, `semver`, `otp`.
- Cryptographic helpers — `nonce`, `password`, `bytes`, `base64`.
- `DateTime` and `Duration` ranges.
- CSS color picking with `isDark` filtering.
- Collection sampling — `element`, `subSet`, `shuffled`, `mapKey/Value/Entry`, `enumValue`.
- Weighted sampling — football-team formation, loot-box rarity.
- IDs & seeding — `uuidV4`, `uuidV7`, `ulid`, `RandGen`, `withSeed`.
- `nullable` probability.

`recipes.dart` — composing structured fixtures (`User`, `Address`, `Order`, paginated responses, chronological chat history) on top of `Rand.*` primitives.

## See also

[Package README](../README.md) — full API surface and usage in your own code.
