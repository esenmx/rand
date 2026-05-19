part of '../rand.dart';

/// Utilities on [CssColors].
extension CssColorsX on CssColors {
  /// Whether this color is dark enough to want a light foreground.
  ///
  /// Computed from the [argb] value via the YIQ luminance formula
  /// `(R*299 + G*587 + B*114) / 1000 < 128`. Cheap and deterministic;
  /// not a substitute for a full WCAG contrast check.
  bool get isDark {
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return (r * 299 + g * 587 + b * 114) ~/ 1000 < 128;
  }
}

mixin _Colors on _Collections {
  CssColors color() => element(CssColors.values);

  CssColors colorDark() {
    return element(CssColors.values.where((c) => c.isDark));
  }

  CssColors colorLight() {
    return element(CssColors.values.where((c) => !c.isDark));
  }
}
