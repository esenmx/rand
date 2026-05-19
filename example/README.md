# rand example

A CLI demo of every `Rand.*` method in the
[rand](https://pub.dev/packages/rand) package, with formatted ANSI output.

## Run

From the repository root:

```bash
dart run example/main.dart
```

Or from inside `example/`:

```bash
dart pub get
dart run main.dart
```

## What it shows

- Numbers, booleans, floats, lat/lng.
- Identity and city corpora.
- Lorem text — word / sentence / paragraph granularity.
- Cryptographic helpers — `nonce`, `password`, `bytes`.
- `DateTime` and `Duration` ranges.
- CSS color picking with `isDark` filtering.
- Collection sampling — `element`, `subSet`, `mapKey/Value/Entry`.
- Weighted sampling — football-team formation, loot-box rarity.
- `nullable` probability.

## See also

[Package README](../README.md) — full API surface and usage in your own code.
