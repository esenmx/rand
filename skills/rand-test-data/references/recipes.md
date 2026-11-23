# rand recipes, networking, geo & colors

Compose primitives flatly (full User/Address/Order/Paginated/ChatHistory examples in [`example/recipes.dart`](../../../example/recipes.dart)):

|Prompt|Recipe|
|-|-|
|10 fake users|`List.generate(10, (_) => (id: Rand.hex(length: 24), name: Rand.fullName(), email: Rand.email()))`|
|Paginated response|`(page: 1, totalPages: 7, items: List.generate(5, (_) => buildItem()))`|
|Weighted draws (1%/10%/89%)|`Rand.sample(['L','R','C'], count: 100, weights: [1, 10, 89])` (relative weights)|
|Sorted timestamps, last hour|`[for (var i = 0; i < 20; i++) Rand.dateTime(min: DateTime.now().subtract(const Duration(hours: 1)), max: DateTime.now())]..sort((a, b) => a.compareTo(b))`|
|Reproducible fixture|`setUp(() => Rand.seed(42));` (crypto methods stay live CSPRNG)|
|Opaque test token|`Rand.base64(byteLength: 32)` (CSPRNG)|
|Git SHA|`Rand.hex(length: 40)`|
|20% null field|`Rand.nullable(value, nullChance: 20)`|
|Random enum|`Rand.enumValue(MyEnum.values)`|
|Non-mutating shuffle|`Rand.shuffled(list)`|

## Networking & strings (reproducible under `seed`)

```dart
Rand.email(); // 'olivia42@example.com', RFC 2606 domains
Rand.email(domain: 'mycompany.io');
Rand.ipv4(); // not filtered for reserved ranges
Rand.ipv6(); // full form, no `::` collapse
Rand.mac(separator: '-'); // default ':'
Rand.hex(length: 40); // lowercase hex (default 8)
Rand.semver(); // 'major.minor.patch', no pre-release
Rand.digits(length: 4); // decimal (default 6), leading zeros kept
Rand.slug(wordCount: 5); // default 3 unique lorem words, '-' joined
```

`Rand.base64(byteLength: 16)` is the CSPRNG parallel for opaque payloads.

## Geo & colors

```dart
final (:lat, :lng) = Rand.geoPoint();
Rand.geoPoint(precision: 2); // composes latitude + longitude
```

`Rand.color()` / `colorDark()` / `colorLight()` -> `CssColors` (148 variants). `.argb` is 32-bit ARGB int (`Color(c.argb)`); `.isDark` is computed YIQ luminance (for WCAG contrast use `fluiver`'s `Color.contrastText`).
