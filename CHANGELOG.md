# Changelog

## 3.0.1

### Breaking Changes

- `integer()` and `float()` now use named parameters (`min:`, `max:`)
- `sample()` replaces `weightedRandomizedArray()`:

  ```dart
  // Before
  Rand.weightedRandomizedArray(weights: [...], pool: items, size: 5);
  
  // After
  Rand.sample(from: items, count: 5);                 // equal probability
  Rand.sample(from: items, count: 5, weights: [...]); // weighted
  ```

- `charCode()` and `safeCharCode()` replace `char()` and `charSecure()`
- Removed `dateTimeYear()` — use `dateTime(DateTime(year1), DateTime(year2))`
- Collection params renamed to `from`
- Password params simplified: `lowercase`, `uppercase`, `digits`, `symbols`

### New

- `color()`, `colorDark()`, `colorLight()` for CSS colors
- `CSSColors` enum with 148 named colors

### Improved

- Proper `ArgumentError` exceptions instead of assertions
- 40+ tests with `checks` package

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
