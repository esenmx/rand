# Changelog

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
