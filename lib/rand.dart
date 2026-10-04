/// Random data generator for Dart.
///
/// Provides [Rand], a static utility class with methods for numbers, text,
/// names, dates, CSS colors, cryptographic tokens, and weighted samples.
///
/// Configure the global non-cryptographic RNG via [Rand.useRng] or
/// [Rand.seed], scope a seed to one call tree with [Rand.withSeed], or
/// inject an independent stream with [RandGen]. Cryptographic methods
/// ([Rand.password], [Rand.nonce], [Rand.bytes], [Rand.base64],
/// [Rand.secureCharCode]) always use [Random.secure] and are not affected.
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

import 'dart:async';
import 'dart:convert';
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
part 'src/_networking.dart';
part 'src/_ids.dart';
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
/// reproducibility, or [withSeed] to scope a seed to one callback. For an
/// explicitly injected, independent stream use [RandGen]. Cryptographic
/// methods are always secure and ignore these mutators.
final class Rand {
  const new _();

  static final _Scope _root = _Scope(RandGen(Random()), null);
  static final _Secure _s = _Secure();
  static _Scope get _scope => Zone.current[_scopeKey] as _Scope? ?? _root;
  static RandGen get _i => _scope.gen;

  /// Replaces the global non-cryptographic RNG.
  ///
  /// Affects every non-cryptographic generator (numbers, text, time,
  /// collections, sampling). Cryptographic methods ([password], [nonce],
  /// [bytes], [base64], [secureCharCode]) always use [Random.secure] and
  /// ignore this setting. Inside [withSeed] it replaces only that scope's RNG.
  /// Clears [currentSeed].
  ///
  /// ```dart
  /// Rand.useRng(Random(42));
  /// Rand.integer(max: 100);          // deterministic
  ///
  /// Rand.useRng(Random.secure());
  /// Rand.sample(from: items, count: 3); // CSPRNG-backed
  /// ```
  ///
  /// In tests, call this in `setUp`, not `setUpAll`, so each test starts
  /// from the same state whatever ran before it (`--name`,
  /// `--test-randomize-ordering-seed`).
  static void useRng(Random rng) => _scope
    ..gen = RandGen(rng)
    ..seed = null;

  /// Seeds the global non-cryptographic RNG and records the seed in
  /// [currentSeed].
  ///
  /// `seed(value)` is `useRng(Random(value))` plus seed reporting.
  /// Without [value], picks a random seed in `[0, 2^32)`. Inside [withSeed]
  /// it re-seeds only that scope. Cryptographic methods are not affected.
  ///
  /// ```dart
  /// Rand.seed(42);
  /// Rand.integer(max: 100);  // same value across runs for this seed
  /// ```
  ///
  /// Random per run, replayable on failure:
  ///
  /// ```dart
  /// setUp(() {
  ///   Rand.seed();
  ///   printOnFailure('Rand seed: ${Rand.currentSeed}');
  /// });
  /// ```
  ///
  /// See also: [useRng], [currentSeed], [withSeed].
  static void seed([int? value]) {
    final s = value ?? Random().nextInt(0x100000000);
    _scope
      ..gen = RandGen(Random(s))
      ..seed = s;
  }

  /// The seed last set by [seed] in the current scope.
  ///
  /// `null` before any [seed] call and after [useRng]. Inside [withSeed]
  /// it reflects the innermost scope.
  static int? get currentSeed => _scope.seed;

  /// Runs [body] with every non-cryptographic `Rand` method drawing from
  /// `Random(seed)`, and returns its result.
  ///
  /// The scope is a [Zone]: it follows [body]'s async continuations
  /// (`await`, and futures or timers created inside it) and never touches
  /// the global RNG, so the global stream continues unchanged afterwards.
  /// Scopes nest — the inner one shadows the outer. [Rand.seed] and
  /// [Rand.useRng] inside [body] re-seed only the innermost scope. Code
  /// scheduled from another zone (timers created before the call) does not
  /// see the scope; spawned isolates never do. If [body] throws, the error
  /// propagates unchanged and there is nothing to restore.
  ///
  /// Draws equal those of `RandGen(Random(seed))`. Cryptographic methods
  /// are not affected.
  ///
  /// ```dart
  /// final user = Rand.withSeed(7, () => (Rand.fullName(), Rand.email()));
  /// ```
  ///
  /// See also: [Rand.seed], [RandGen].
  static R withSeed<R>(int seed, R Function() body) => runZoned(
    body,
    zoneValues: {_scopeKey: _Scope(RandGen(Random(seed)), seed)},
  );

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
  /// Throws [ArgumentError] when [trueChance] is outside `[0, 100]` or NaN.
  static bool boolean([double trueChance = 50]) => _i.boolean(trueChance);

  /// Returns [value] with `(100 - nullChance)%` probability, else `null`.
  ///
  /// ```dart
  /// Rand.nullable('value');       // 50% null
  /// Rand.nullable('value', 90);   // 90% null
  /// ```
  ///
  /// Throws [ArgumentError] when [nullChance] is outside `[0, 100]` or NaN.
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
  /// Maximum range (`max - min`) is `2^32 - 1`.
  ///
  /// Throws [ArgumentError] when `min > max` or `max - min > 2^32 - 1`.
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
  /// Returns [min] when `min == max`.
  ///
  /// Throws [ArgumentError] when `min > max` or either bound is not finite.
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
  /// Throws [RangeError] unless `0 <= precision <= 15`.
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
  /// Throws [RangeError] unless `0 <= precision <= 15`.
  ///
  /// See also: [latitude].
  static double longitude([int precision = 5]) => _i.longitude(precision);

  /// Random `(lat, lng)` record — composes [latitude] and [longitude].
  ///
  /// Returns a named record `({double lat, double lng})` so callers
  /// destructure cleanly:
  ///
  /// ```dart
  /// final (:lat, :lng) = Rand.geoPoint();
  /// Rand.geoPoint(precision: 2);  // (lat: 42.36, lng: -71.06)
  /// ```
  ///
  /// Throws [RangeError] unless `0 <= precision <= 15`.
  ///
  /// See also: [latitude], [longitude].
  static ({double lat, double lng}) geoPoint({int precision = 5}) =>
      _i.geoPoint(precision: precision);

  /// Random base62 character code (int).
  ///
  /// Returns a code point from `[0-9A-Za-z]`. Use [String.fromCharCode]
  /// to render: `String.fromCharCode(Rand.charCode())`.
  ///
  /// See also: [secureCharCode], [base62].
  static int charCode() => _i.charCode();

  /// Random semantic-version string `"major.minor.patch"`.
  ///
  /// Each component independently uniform in `[0, maxX]` (inclusive).
  ///
  /// ```dart
  /// Rand.semver();                    // '3.7.42'
  /// Rand.semver(maxMajor: 1);          // '0.5.91' or '1.2.13' — 0 or 1 only
  /// ```
  ///
  /// No pre-release suffixes (`-rc.1` etc.) — compose your own if needed.
  static String semver({
    int maxMajor = 9,
    int maxMinor = 9,
    int maxPatch = 99,
  }) {
    return _i.semver(
      maxMajor: maxMajor,
      maxMinor: maxMinor,
      maxPatch: maxPatch,
    );
  }

  /// Random zero-padded decimal OTP code.
  ///
  /// Each digit drawn uniformly from `[0-9]`. Reproducible under
  /// [Rand.seed] — useful for test fixtures, not for real one-time codes.
  ///
  /// ```dart
  /// Rand.otp();              // '047215'
  /// Rand.otp(length: 4);      // '8203'
  /// ```
  ///
  /// Throws [ArgumentError] when [length] is less than 1.
  static String otp({int length = 6}) => _i.otp(length: length);

  /// Cryptographically secure random base62 character code (int).
  ///
  /// {@template rand.always_secure}
  /// Uses [Random.secure]; not affected by [Rand.useRng] or [Rand.seed].
  /// {@endtemplate}
  ///
  /// See also: [charCode], [nonce].
  static int secureCharCode() => _s.secureCharCode();

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
  /// Throws [ArgumentError] when [length] is negative.
  ///
  /// See also: [nonce], [password].
  static Uint8List bytes(int length) => _s.bytes(length);

  /// Cryptographically secure random base62 string.
  ///
  /// {@macro rand.always_secure}
  ///
  /// Suitable for opaque tokens, request IDs, CSRF nonces — short random
  /// handles that survive URL and header transport without
  /// percent-encoding. 16 chars ≈ 95 bits (log2 62 ≈ 5.95 bits/char).
  ///
  /// ```dart
  /// Rand.nonce();            // 'a8X2nQ4kZpL1mYbR'
  /// Rand.nonce(length: 32);  // 32-char token
  /// ```
  ///
  /// Throws [ArgumentError] when [length] is negative.
  ///
  /// See also: [password], [bytes], [base62].
  static String nonce({int length = 16}) => _s.nonce(length: length);

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
  /// Not for production secrets — see the README's "Cryptographic" section
  /// for the package's stability contract.
  static String password({
    int length = 12,
    bool lowercase = true,
    bool uppercase = true,
    bool digits = true,
    bool symbols = true,
  }) {
    return _s.password(
      length: length,
      lowercase: lowercase,
      uppercase: uppercase,
      digits: digits,
      symbols: symbols,
    );
  }

  /// Cryptographically secure random base64-encoded string.
  ///
  /// {@macro rand.always_secure}
  ///
  /// Encodes [byteLength] random bytes via [base64Encode]. Output length
  /// is `4 * ceil(byteLength / 3)` characters (padded with `=`).
  ///
  /// ```dart
  /// Rand.base64();                  // 22 chars + '=='  for 16 bytes
  /// Rand.base64(byteLength: 32);    // 44 chars
  /// ```
  ///
  /// Throws [ArgumentError] when [byteLength] is less than 1.
  ///
  /// See also: [bytes], [nonce].
  static String base64({int byteLength = 16}) =>
      _s.base64(byteLength: byteLength);

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
  /// [max] is required — no implicit upper bound. Returns [min] when
  /// `min == max`.
  ///
  /// Throws [ArgumentError] when `min > max`.
  ///
  /// See also: [dateTime].
  static Duration duration({
    required Duration max,
    Duration min = Duration.zero,
  }) {
    return _i.duration(max: max, min: min);
  }

  /// Random UTC [DateTime] in `[start, end)` — half-open upper bound.
  ///
  /// Defaults to `[1970-01-01, 2038-01-01)` UTC if [start] / [end] are
  /// omitted. Returns [start] when `start == end`.
  ///
  /// ```dart
  /// Rand.dateTime();
  /// Rand.dateTime(DateTime(2020), DateTime(2025));
  /// ```
  ///
  /// Throws [ArgumentError] when the effective start is after the effective
  /// end — including a [start] after 2038-01-01 with no [end]; pass [end]
  /// then.
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

  /// Random value from an enum.
  ///
  /// Pass `MyEnum.values` — the `T extends Enum` bound makes this
  /// type-safe and IDE-discoverable.
  ///
  /// ```dart
  /// enum Status { active, suspended, deleted }
  /// Rand.enumValue(Status.values);  // Status.suspended
  /// ```
  ///
  /// See also: [element].
  static T enumValue<T extends Enum>(List<T> values) => _i.enumValue(values);

  /// Returns a new shuffled copy of [from] — input is not mutated.
  ///
  /// Uses the global non-cryptographic RNG; reproducible under [Rand.seed].
  ///
  /// ```dart
  /// Rand.shuffled([1, 2, 3, 4]);  // [3, 1, 4, 2]
  /// ```
  ///
  /// For sampling with replacement, see [sample]. For unique-subset
  /// draws, see [subSet].
  static List<T> shuffled<T>(List<T> from) => _i.shuffled(from);

  /// Random subset of [count] unique elements from [from].
  ///
  /// ```dart
  /// Rand.subSet({1, 2, 3, 4, 5}, 3);  // {2, 5, 1}
  /// Rand.subSet([1, 2, 2, 3].toSet(), 2); // dedupe explicitly
  /// ```
  ///
  /// Throws [ArgumentError] when [count] is negative, [RangeError] when
  /// `count > from.length`.
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
  /// Rand.alias();  // 'Achilles'
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
  /// Rand.city();  // 'Boston'
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
  ///
  /// Throws [ArgumentError] when [count] is negative, [RangeError] when it
  /// exceeds the corpus.
  static String words({int? count, String separator = ' '}) =>
      _i.words(count: count, separator: separator);

  /// Random pre-built lorem sentence, or [count] unique ones joined by `" "`.
  ///
  /// Sentences are drawn via [subSet] — never repeats within one call.
  ///
  /// ```dart
  /// Rand.sentence();   // 'Lorem ipsum dolor sit amet.'
  /// Rand.sentence(2);  // 'Lorem ipsum dolor sit amet. Nunc sed velit dignissim.'
  /// ```
  ///
  /// Throws [ArgumentError] when [count] is less than 1, [RangeError] when it
  /// exceeds the 856-sentence corpus.
  ///
  /// See also: [paragraph] — repeats allowed, joined by `" "`.
  static String sentence([int? count]) => _i.sentence(count);

  /// Random paragraph of [count] sentences (default 5..10), joined by `" "`.
  ///
  /// Throws [ArgumentError] when [count] is negative.
  static String paragraph([int? count]) => _i.paragraph(count);

  /// Random article of [count] paragraphs (default 3..7), joined by `"\n\n"`.
  ///
  /// Throws [ArgumentError] when [count] is negative.
  static String article([int? count]) => _i.article(count);

  /// Random URL slug — [wordCount] unique lorem words joined by [separator].
  ///
  /// Words never repeat within one slug (drawn via [subSet]).
  ///
  /// ```dart
  /// Rand.slug();                     // 'lorem-ipsum-dolor'
  /// Rand.slug(wordCount: 5);          // 'amet-consectetur-adipiscing-elit-sed'
  /// Rand.slug(separator: '_');        // 'lorem_ipsum_dolor'
  /// ```
  ///
  /// Throws [ArgumentError] when [wordCount] is less than 1.
  ///
  /// See also: [words].
  static String slug({int wordCount = 3, String separator = '-'}) =>
      _i.slug(wordCount: wordCount, separator: separator);

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
  // Networking
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random email address.
  ///
  /// Synthesises `firstName + 1..99 + '@' + domain`. When [domain] is
  /// `null`, picks from a built-in list of test/example TLDs (RFC 2606
  /// safe — no real-world collisions).
  ///
  /// ```dart
  /// Rand.email();                       // 'olivia42@example.com'
  /// Rand.email(domain: 'mycompany.io'); // 'james7@mycompany.io'
  /// ```
  ///
  /// See also: [firstName].
  static String email({String? domain}) => _i.email(domain: domain);

  /// Random IPv4 address as a dotted-quad string.
  ///
  /// Each octet uniform in `[0, 255]`. Output is not filtered for
  /// reserved ranges (0.0.0.0/8, 127.0.0.0/8, etc.); compose your own
  /// filter if you need only routable addresses.
  ///
  /// ```dart
  /// Rand.ipv4();  // '203.0.113.42'
  /// ```
  ///
  /// See also: [ipv6].
  static String ipv4() => _i.ipv4();

  /// Random IPv6 address — 8 hex groups joined by `:`.
  ///
  /// Returned in full form (no `::` collapse) so length is stable for
  /// fixtures.
  ///
  /// ```dart
  /// Rand.ipv6();  // '2001:0db8:85a3:0000:0000:8a2e:0370:7334'
  /// ```
  ///
  /// See also: [ipv4].
  static String ipv6() => _i.ipv6();

  /// Random MAC address — 6 hex bytes joined by [separator].
  ///
  /// Common separators: `':'` (Unix-style, default), `'-'` (Windows-style).
  ///
  /// ```dart
  /// Rand.mac();                  // '3a:5f:9c:8e:2d:71'
  /// Rand.mac(separator: '-');    // '3a-5f-9c-8e-2d-71'
  /// ```
  static String mac({String separator = ':'}) => _i.mac(separator: separator);

  /// Random lowercase hex string of [length] characters.
  ///
  /// General-purpose hex: covers git SHAs (`length: 40`), ETags, content
  /// hashes, opaque test IDs. Uses the non-secure RNG — reproducible
  /// under [Rand.seed].
  ///
  /// ```dart
  /// Rand.hex();             // 'a3f2c91e'
  /// Rand.hex(length: 40);   // git-SHA-shaped
  /// ```
  ///
  /// Throws [ArgumentError] when [length] is less than 1.
  ///
  /// See also: [nonce] for crypto-secure base62 tokens.
  static String hex({int length = 8}) => _i.hex(length: length);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // IDs
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Random UUID version 4 (RFC 9562), lowercase hex with dashes.
  ///
  /// {@template rand.seedable_ids}
  /// Drawn from the non-cryptographic RNG, so reproducible under [seed],
  /// [withSeed] and [RandGen] — meant for test IDs. For production IDs use
  /// `package:uuid`.
  /// {@endtemplate}
  ///
  /// ```dart
  /// Rand.uuidV4();  // '1b9d6bcd-bbfd-4b2d-9b5d-ab8dfbbd4bed'
  /// ```
  ///
  /// See also: [uuidV7], [ulid].
  static String uuidV4() => _i.uuidV4();

  /// Random UUID version 7 (RFC 9562): a 48-bit Unix-millisecond timestamp
  /// from [time] (default `DateTime.now()`) followed by random bits.
  ///
  /// {@macro rand.seedable_ids}
  ///
  /// IDs sort by time across milliseconds but are not monotonic within one.
  ///
  /// ```dart
  /// Rand.uuidV7();
  /// Rand.uuidV7(time: DateTime.utc(2026, 10, 3, 12, 34, 56, 789));
  /// // '01a101c2-a895-7…' — time prefix, then random bits
  /// ```
  ///
  /// Throws [ArgumentError] when [time] is before 1970 or past the 48-bit
  /// millisecond range (year 10889).
  ///
  /// See also: [uuidV4], [ulid].
  static String uuidV7({DateTime? time}) => _i.uuidV7(time: time);

  /// Random ULID: 10 Crockford base32 characters of 48-bit Unix-millisecond
  /// timestamp from [time] (default `DateTime.now()`), then 16 random ones.
  ///
  /// {@macro rand.seedable_ids}
  ///
  /// IDs sort by time across milliseconds but are not monotonic within one.
  ///
  /// ```dart
  /// Rand.ulid();  // '01M40W5A4N…' — 26 chars
  /// ```
  ///
  /// Throws [ArgumentError] when [time] is before 1970 or past the 48-bit
  /// millisecond range (year 10889).
  ///
  /// See also: [uuidV4], [uuidV7].
  static String ulid({DateTime? time}) => _i.ulid(time: time);

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Sampling
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Select [count] elements from [from] **with replacement**.
  ///
  /// Optionally weighted via [weights].
  ///
  /// If [weights] is `null` all items have equal probability. Otherwise
  /// `weights[i]` is the relative weight for `from[i]`; `weights.length`
  /// must be `>= from.length`, and weights beyond `from.length` are ignored.
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
  /// Returns an empty list when [from] is empty or [count] is 0.
  ///
  /// Throws [ArgumentError] when [count] is negative, when
  /// `weights.length < from.length`, when a used weight is negative, or when
  /// the used weights sum to 0 or more than `2^32`.
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
  }) {
    return _i.sample(from: from, count: count, weights: weights);
  }
}
