// Design tokens — Figma "Money-Management-App" Variables (Primitives + Color/Light).
// Figma এর সাথে মিলিয়ে রাখুন: কোনো রং বদলালে আগে Figma তে বদলান, তারপর এখানে।
import 'package:flutter/material.dart';

class C {
  C._();
  // semantic (Light)
  static const bg = Color(0xFFF5F6FA);
  static const onboardBg = Color(0xFFF2F2F7); // Figma: backgrounds/secondary
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFEEF1F5);
  static const outline = Color(0xFFD5DAE1);
  static const text = Color(0xFF0B1533);
  static const textSecondary = Color(0xFF4A5565);
  static const textTertiary = Color(0xFF5B667A);
  static const primary = Color(0xFF2B59FF);
  static const primaryStrong = Color(0xFF1D45E0); // primary/600
  static const primaryContainer = Color(0xFFE0E9FF);
  static const primary50 = Color(0xFFEEF3FF);
  static const primary200 = Color(0xFFC3D4FF);
  static const primary300 = Color(0xFF94B2FF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const income = Color(0xFF15803D);
  static const expense = Color(0xFFB91C1C);
  static const warningText = Color(0xFFB45309);
  static const warningFill = Color(0xFFF59E0B); // amber/500
  static const hero = Color(0xFF1C2644);
  static const onHero = Color(0xFFFFFFFF);
  // primitives used directly
  static const ink50 = Color(0xFFF5F6FA);
  static const ink100 = Color(0xFFEAEDF4);
  static const ink200 = Color(0xFFDDE2EC);
  static const ink300 = Color(0xFFC2C9D8);
  static const ink400 = Color(0xFF97A1B5);
  static const ink500 = Color(0xFF6B7690);
  static const ink600 = Color(0xFF5B667A);
  static const ink700 = Color(0xFF3B455C);
  static const green100 = Color(0xFFDCFCE7);
  static const green700 = Color(0xFF15803D);
  static const red100 = Color(0xFFFEE2E2);
  static const red300 = Color(0xFFFCA5A5);
  static const red400 = Color(0xFFF87171);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber200 = Color(0xFFFDE68A);
  static const amber700 = Color(0xFFB45309);
  static const amber800 = Color(0xFF92400E);
  static const mint300 = Color(0xFF6EE7B7);
  static const mint500 = Color(0xFF10B981);
  // white overlays (on hero card)
  static const white06 = Color(0x0FFFFFFF);
  static const white08 = Color(0x14FFFFFF);
  static const white16 = Color(0x29FFFFFF);
  static const white80 = Color(0xCCFFFFFF);
  static const white85 = Color(0xD9FFFFFF);
}

class R {
  R._();
  static const double sm = 12, md = 16, lg = 20, xl = 24, full = 999;
}

class Sp {
  Sp._();
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 20, xxl = 24;
}

class Shadows {
  Shadows._();
  static const card = [
    BoxShadow(color: Color(0x120B1533), offset: Offset(0, 2), blurRadius: 12),
  ];
  static const floating = [
    BoxShadow(color: Color(0x240B1533), offset: Offset(0, 10), blurRadius: 28),
    BoxShadow(color: Color(0x0F0B1533), offset: Offset(0, 2), blurRadius: 6),
  ];
  static const action = [
    BoxShadow(color: Color(0x4D2B59FF), offset: Offset(0, 6), blurRadius: 14),
  ];
}
