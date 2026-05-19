/// Random data generator for Dart.
///
/// Provides [Rand], a static utility class with methods for numbers, text,
/// names, dates, CSS colors, cryptographic tokens, and weighted samples.
///
/// Configure the global non-cryptographic RNG via [Rand.useRng] or
/// [Rand.seed]. Cryptographic methods ([Rand.password], [Rand.nonce],
/// [Rand.bytes], [Rand.secureCharCode]) always use [Random.secure] and
/// are not affected.
///
/// ```dart
/// import 'package:rand/rand.dart';
///
/// void main() {
///   Rand.seed(42);
///   print(Rand.fullName());  // 'Emma Rodriguez'
///   print(Rand.password());  // 'k9#Mx!pL2@qR'
///   print(Rand.color());     // CssColors.coral
/// }
/// ```
library;

import 'dart:math';
import 'dart:typed_data';

part 'src/_internal.dart';
part 'src/_booleans.dart';
part 'src/_numbers.dart';
part 'src/_crypto.dart';
part 'src/_time.dart';
part 'src/_collections.dart';
part 'src/_sampling.dart';
part 'src/_text.dart';
part 'src/_identity.dart';
part 'src/_colors.dart';
part 'src/rand_impl.dart';
part 'data/alias.dart';
part 'data/cities.dart';
part 'data/colors.dart';
part 'data/first_name.dart';
part 'data/last_name.dart';
part 'data/lorem.dart';

/// Random data generator. All methods are static.
///
/// Use [seed] or [useRng] to control the non-cryptographic RNG for
/// reproducibility. Cryptographic methods are always secure and ignore
/// these mutators.
final class Rand {
  const Rand._();

  static final _RandImpl _i = _RandImpl();

  /// Replaces the global non-cryptographic RNG.
  ///
  /// Affects every non-cryptographic generator (numbers, text, time,
  /// collections, sampling). Cryptographic methods ([password], [nonce],
  /// [bytes], [secureCharCode]) always use [Random.secure] and ignore
  /// this setting.
  ///
  /// ```dart
  /// Rand.useRng(Random(42));
  /// Rand.integer(max: 100);          // deterministic
  ///
  /// Rand.useRng(Random.secure());
  /// Rand.sample(from: items, count: 3); // CSPRNG-backed
  /// ```
  ///
  /// In parallel tests, call this in `setUp`, not `setUpAll` — the
  /// global is shared.
  // ignore: use_setters_to_change_properties — verb-form pairs with `seed`
  static void useRng(Random rng) => _i.rng = rng;

  /// Seeds the global non-cryptographic RNG.
  ///
  /// Shortcut for `useRng(Random(value))`. Cryptographic methods are
  /// not affected.
  ///
  /// ```dart
  /// Rand.seed(42);
  /// Rand.integer(max: 100);  // same value across runs for this seed
  /// ```
  ///
  /// See also: [useRng].
  static void seed(int value) => useRng(Random(value));

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Boolean & Nullable
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Returns `true` with [trueChance] probability (0-100).
  ///
  /// ```dart
  /// Rand.boolean();      // 50% true
  /// Rand.boolean(90);    // 90% true
  /// Rand.boolean(99.9);  // 99.9% true
  /// ```
  ///
  /// Throws [ArgumentError] when [trueChance] is outside `[0, 100]`.
  static bool boolean([double trueChance = 50]) => _i.boolean(trueChance);

  /// Returns [value] with `(100 - nullChance)%` probability, else `null`.
  ///
  /// ```dart
  /// Rand.nullable('value');       // 50% null
  /// Rand.nullable('value', 90);   // 90% null
  /// ```
  ///
  /// See also: [boolean].
  static T? nullable<T>(T value, [double nullChance = 50]) =>
      _i.nullable(value, nullChance);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Numbers
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random integer in `[min, max]` — inclusive on both ends.
  ///
  /// ```dart
  /// Rand.integer();                  // 0..2^31-1
  /// Rand.integer(max: 100);          // 0..100 inclusive
  /// Rand.integer(min: -10, max: 10);
  /// ```
  ///
  /// Maximum range (`max - min`) is `2^31 - 1`.
  ///
  /// Throws [ArgumentError] when `min > max`.
  ///
  /// For a list index use `max: list.length - 1`, or call [element].
  ///
  /// See also: [float], [element].
  static int integer({int min = 0, int max = _maxInt}) =>
      _i.integer(min: min, max: max);

  /// Random double in `[min, max)` — half-open upper bound.
  ///
  /// ```dart
  /// Rand.float();                  // 0.0..double.maxFinite
  /// Rand.float(min: 0, max: 1);    // [0.0, 1.0)
  /// ```
  ///
  /// Throws [ArgumentError] when `min > max`.
  ///
  /// See also: [integer].
  static double float({num min = 0, num max = double.maxFinite}) =>
      _i.float(min: min, max: max);

  /// Random latitude in `[-90, 90]` with [precision] decimal places.
  ///
  /// ```dart
  /// Rand.latitude();   // 42.36011
  /// Rand.latitude(2);  // 42.36
  /// ```
  ///
  /// See also: [longitude].
  static double latitude([int precision = 5]) => _i.latitude(precision);

  /// Random longitude in `[-180, 180]` with [precision] decimal places.
  ///
  /// ```dart
  /// Rand.longitude();   // -71.05891
  /// Rand.longitude(2);  // -71.06
  /// ```
  ///
  /// See also: [latitude].
  static double longitude([int precision = 5]) => _i.longitude(precision);

  /// Random base62 character code (int).
  ///
  /// Returns a code point from `[0-9A-Za-z]`. Use [String.fromCharCode]
  /// to render: `String.fromCharCode(Rand.charCode())`.
  ///
  /// See also: [secureCharCode], [base62].
  static int charCode() => _i.charCode();

  /// Cryptographically secure random base62 character code (int).
  ///
  /// {@template rand.always_secure}
  /// Uses [Random.secure]; not affected by [Rand.useRng] or [Rand.seed].
  /// {@endtemplate}
  ///
  /// See also: [charCode], [nonce].
  static int secureCharCode() => _i.secureCharCode();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Cryptographic
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Cryptographically secure random bytes.
  ///
  /// {@macro rand.always_secure}
  ///
  /// ```dart
  /// Rand.bytes(32);  // Uint8List(32)
  /// ```
  ///
  /// For reproducible (non-secure) byte streams, generate them from your
  /// own seeded [Random] instance.
  ///
  /// See also: [nonce], [password].
  static Uint8List bytes(int length) => _i.bytes(length);

  /// Cryptographically secure random base62 string.
  ///
  /// {@macro rand.always_secure}
  ///
  /// Suitable for opaque tokens, request IDs, CSRF nonces — short random
  /// handles that survive URL and header transport without
  /// percent-encoding. 16 chars ≈ 95 bits of entropy.
  ///
  /// ```dart
  /// Rand.nonce();            // 'a8X2nQ4kZpL1mYbR'
  /// Rand.nonce(length: 32);  // 32-char token
  /// ```
  ///
  /// See also: [password], [bytes], [base62].
  static String nonce({int length = 16}) => _i.nonce(length: length);

  /// Cryptographically secure random password with configurable character sets.
  ///
  /// {@macro rand.always_secure}
  ///
  /// Minimum [length] is 4. At least one of [lowercase], [uppercase],
  /// [digits], or [symbols] must remain `true`.
  ///
  /// ```dart
  /// Rand.password();                  // 12-char mixed-charset
  /// Rand.password(length: 20);
  /// Rand.password(symbols: false);    // no symbols
  /// Rand.password(uppercase: false, digits: false, symbols: false); // lowercase only
  /// ```
  ///
  /// Throws [ArgumentError] when `length < 4` or all character sets are
  /// disabled.
  ///
  /// Not for production secrets — see SECURITY.md for the package's
  /// stability contract.
  static String password({
    int length = 12,
    bool lowercase = true,
    bool uppercase = true,
    bool digits = true,
    bool symbols = true,
  }) =>
      _i.password(
        length: length,
        lowercase: lowercase,
        uppercase: uppercase,
        digits: digits,
        symbols: symbols,
      );

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Time
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random [Duration] in `[min, max)` — half-open upper bound.
  ///
  /// ```dart
  /// Rand.duration(max: const Duration(days: 30));
  /// Rand.duration(
  ///   min: const Duration(days: 1),
  ///   max: const Duration(days: 30),
  /// );
  /// ```
  ///
  /// [max] is required — no implicit upper bound.
  ///
  /// See also: [dateTime].
  static Duration duration({
    required Duration max,
    Duration min = Duration.zero,
  }) =>
      _i.duration(max: max, min: min);

  /// Random UTC [DateTime] in `[start, end)` — half-open upper bound.
  ///
  /// Defaults to `[1970-01-01, 2038-01-19)` UTC if [start] / [end] are
  /// omitted.
  ///
  /// ```dart
  /// Rand.dateTime();
  /// Rand.dateTime(DateTime(2020), DateTime(2025));
  /// ```
  ///
  /// See also: [duration].
  static DateTime dateTime([DateTime? start, DateTime? end]) =>
      _i.dateTime(start, end);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Collections
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random element from [from].
  ///
  /// Optimized for [List] (O(1)). For lazy iterables, the receiver is
  /// walked twice (once for [Iterable.length], once for
  /// [Iterable.elementAt]); materialize with `.toList()` first if
  /// iteration is expensive.
  ///
  /// ```dart
  /// Rand.element([1, 2, 3]);            // 2
  /// Rand.element({'a', 'b', 'c'});      // 'b'
  /// ```
  ///
  /// Throws [StateError] when [from] is empty.
  ///
  /// See also: [subSet], [sample].
  static T element<T>(Iterable<T> from) => _i.element(from);

  /// Random [MapEntry] from [from].
  ///
  /// Throws [StateError] when [from] is empty.
  ///
  /// See also: [mapKey], [mapValue].
  static MapEntry<K, V> mapEntry<K, V>(Map<K, V> from) => _i.mapEntry(from);

  /// Random key from [from].
  ///
  /// Throws [StateError] when [from] is empty.
  ///
  /// See also: [mapValue], [mapEntry].
  static K mapKey<K, V>(Map<K, V> from) => _i.mapKey(from);

  /// Random value from [from].
  ///
  /// Throws [StateError] when [from] is empty.
  ///
  /// See also: [mapKey], [mapEntry].
  static V mapValue<K, V>(Map<K, V> from) => _i.mapValue(from);

  /// Random subset of [count] unique elements from [from].
  ///
  /// ```dart
  /// Rand.subSet({1, 2, 3, 4, 5}, 3);  // {2, 5, 1}
  /// Rand.subSet([1, 2, 2, 3].toSet(), 2); // dedupe explicitly
  /// ```
  ///
  /// Throws [RangeError] when `count > from.length`.
  ///
  /// For sampling **with** replacement, use [sample].
  ///
  /// See also: [sample], [element].
  static Set<T> subSet<T>(Set<T> from, int count) => _i.subSet(from, count);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Identity & Geo
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random alias / nickname from a built-in corpus.
  ///
  /// ```dart
  /// Rand.alias();  // 'ShadowHunter'
  /// ```
  static String alias() => _i.alias();

  /// Random first name from a US/English-leaning corpus.
  ///
  /// ```dart
  /// Rand.firstName();  // 'Olivia'
  /// ```
  ///
  /// See also: [lastName], [fullName].
  static String firstName() => _i.firstName();

  /// Random last name from a US/English-leaning corpus.
  ///
  /// ```dart
  /// Rand.lastName();  // 'Thompson'
  /// ```
  ///
  /// See also: [firstName], [fullName].
  static String lastName() => _i.lastName();

  /// Random full name: first + 0..2 weighted middle names + last.
  ///
  /// Middle-name distribution: 0 (100), 1 (10), 2 (1).
  ///
  /// ```dart
  /// Rand.fullName();  // 'James Michael Wilson'
  /// ```
  ///
  /// See also: [firstName], [lastName].
  static String fullName() => _i.fullName();

  /// Random city name from a built-in corpus.
  ///
  /// ```dart
  /// Rand.city();  // 'Tokyo'
  /// ```
  static String city() => _i.city();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Text — lorem corpus
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random lorem word.
  ///
  /// ```dart
  /// Rand.word();  // 'lorem'
  /// ```
  ///
  /// See also: [words], [sentence].
  static String word() => _i.word();

  /// Random unique lorem words joined by [separator].
  ///
  /// Default [count] is 3..10. Words are drawn via [subSet] — never
  /// repeats within one call.
  ///
  /// ```dart
  /// Rand.words(count: 5);                   // 'amet consectetur adipiscing elit sed'
  /// Rand.words(count: 3, separator: '-');   // 'lorem-ipsum-dolor'
  /// ```
  static String words({int? count, String separator = ' '}) =>
      _i.words(count: count, separator: separator);

  /// Random pre-built lorem sentence.
  ///
  /// ```dart
  /// Rand.sentence();  // 'Lorem ipsum dolor sit amet.'
  /// ```
  static String sentence() => _i.sentence();

  /// Random paragraph of [count] sentences (default 5..10), joined by `". "`.
  static String paragraph([int? count]) => _i.paragraph(count);

  /// Random article of [count] paragraphs (default 3..7), joined by `"\n\n"`.
  static String article([int? count]) => _i.article(count);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Colors
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random CSS named color.
  ///
  /// ```dart
  /// final c = Rand.color();
  /// c.name;    // 'coral'
  /// c.argb;    // 0xFFFF7F50 — Flutter-friendly: Color(c.argb)
  /// c.isDark;  // computed via CssColorsX extension
  /// ```
  ///
  /// See also: [colorDark], [colorLight], [CssColors], [CssColorsX.isDark].
  static CssColors color() => _i.color();

  /// Random dark CSS color — good for light backgrounds.
  ///
  /// Darkness is computed via [CssColorsX.isDark] (YIQ luminance).
  ///
  /// See also: [color], [colorLight].
  static CssColors colorDark() => _i.colorDark();

  /// Random light CSS color — good for dark backgrounds.
  ///
  /// Lightness is the complement of [CssColorsX.isDark].
  ///
  /// See also: [color], [colorDark].
  static CssColors colorLight() => _i.colorLight();

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Sampling
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Select [count] elements from [from] **with replacement**.
  ///
  /// Optionally weighted via [weights].
  ///
  /// If [weights] is `null` all items have equal probability. Otherwise
  /// `weights[i]` is the relative weight for `from[i]`; `weights.length`
  /// must be `>= from.length`.
  ///
  /// ```dart
  /// // Equal probability
  /// Rand.sample(from: [1, 2, 3, 4, 5, 6], count: 10);
  ///
  /// // Loot box: 1% legendary, 10% rare, ~89% common
  /// Rand.sample(
  ///   from: ['Legendary', 'Rare', 'Common'],
  ///   count: 100,
  ///   weights: [1, 10, 100],
  /// );
  /// ```
  ///
  /// Returns `const []` when [from] is empty or [count] is 0.
  ///
  /// Throws [ArgumentError] when `weights.length < from.length`.
  ///
  /// For sampling **without** replacement, use [subSet]. For a
  /// cryptographically secure sample, call
  /// `Rand.useRng(Random.secure())` first.
  ///
  /// See also: [subSet], [element].
  static List<T> sample<T>({
    required List<T> from,
    required int count,
    List<int>? weights,
  }) =>
      _i.sample(from: from, count: count, weights: weights);
}
