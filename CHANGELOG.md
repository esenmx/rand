## 2.0.1

- `nullable()` default `nullChance` value fix

```dart
// BEFORE
nullable<T>(T value, [double nullChance = 50])
// AFTER
nullable<T>(T value, [double nullChance = .5])
```

## 2.0.0

- **BREAKING CHANGE**: `documentId` and `uid` removed, just use `id` function, `mayBeNull` renamed as `nullable`
- Added functions: `alias`, `firstName`, `lastName`, `city`, `latitude`, `longitude`
- Improved in-line documentation

## 1.0.3

- Added `seed` support for `math.Random` field

## 1.0.2

- Tweaks and fixes for lorem functions

## 1.0.1

- Lorem functions added

## 1.0.0

- Initial release
