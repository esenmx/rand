# Pitfalls

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

For composing structured fixtures (User, Address, Order, paginated responses,
chat history), see [`example/recipes.dart`](../example/recipes.dart).
