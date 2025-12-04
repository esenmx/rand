# Changelog

## 3.0.0

### Breaking Changes

- `integer()` and `float()` now use named parameters:

  ```dart
  // Before
  Rand.integer(100, 50);
  
  // After
  Rand.integer(min: 50, max: 100);
  ```

- Replaced assertions with `ArgumentError` exceptions

### New Features

- Added `color()`, `colorDark()`, `colorLight()` methods
- Exported `CSSColors` enum (148 CSS named colors)

### Improvements

- Better error messages
- Comprehensive test coverage (40+ tests)
- Migrated tests to `checks` package
- Enhanced example
- Rewrote README

## 2.0.3

- Updated dependencies
- Formatting improvements

## 2.0.2+2

- Changed `meta` dependency to version range

## 2.0.2+1

- Fixed max int for web

## 2.0.2

- Fixed `boolean()` regression

## 2.0.1

- Fixed `nullable()` default value

## 2.0.0

- **Breaking:** Removed `documentId` and `uid` (use `id` instead)
- **Breaking:** Renamed `mayBeNull` to `nullable`
- Added `alias`, `firstName`, `lastName`, `city`, `latitude`, `longitude`
- Improved documentation

## 1.0.3

- Added `seed()` for reproducible results

## 1.0.2

- Fixed lorem functions

## 1.0.1

- Added lorem functions

## 1.0.0

- Initial release
