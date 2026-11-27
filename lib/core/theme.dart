import 'package:flutter/material.dart';
import 'tokens.dart';

/// Figma text styles (Baloo Da 2). ব্যবহার: Ty.s(15, FontWeight.w600)
class Ty {
  Ty._();
  static TextStyle s(double size, FontWeight w, {Color color = C.text}) => TextStyle(
        fontFamily: 'BalooDa2',
        fontSize: size,
        fontWeight: w,
        height: 1.45,
        color: color,
        fontVariations: [FontVariation('wght', w.value.toDouble())],
      );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: C.primary).copyWith(
    primary: C.primary,
    onPrimary: C.onPrimary,
    surface: C.surface,
    onSurface: C.text,
    error: C.expense,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'BalooDa2',
    scaffoldBackgroundColor: C.bg,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.hero,
      contentTextStyle: Ty.s(14, FontWeight.w500, color: C.onHero),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.md)),
    ),
  );
}
