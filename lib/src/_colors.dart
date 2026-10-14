part of '../rand.dart';

List<CssColors> _colorsWhere(bool Function(CssColors) test) {
  return CssColors.values.where(test).toList(growable: false);
}

final List<CssColors> _darkColors = _colorsWhere((c) => c.isDark);
final List<CssColors> _lightColors = _colorsWhere((c) => !c.isDark);

mixin _Colors on _Collections {
  /// See [Rand.color].
  CssColors color() => element(CssColors.values);

  /// See [Rand.colorDark].
  CssColors colorDark() => element(_darkColors);

  /// See [Rand.colorLight].
  CssColors colorLight() => element(_lightColors);
}
