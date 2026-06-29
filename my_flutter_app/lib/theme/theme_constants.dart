import 'package:flutter/material.dart';

class ThemeConstants {
  // Durations - Snappy Vercel style
  static const kDurationFast = Duration(milliseconds: 150);
  static const kDurationMed  = Duration(milliseconds: 250);
  static const kDurationSlow = Duration(milliseconds: 400);

  // Curves
  static const kCurveStandard   = Curves.easeOutCubic;
  static const kCurveEmphasized = Curves.fastOutSlowIn;

  // Brand — Vercel Monochrome
  static const kBrandCyan   = Color(0xFFFFFFFF); // Replaced with white for high contrast
  static const kBrandDark   = Color(0xFF000000); // True black
  static const kBrandSurface= Color(0xFF0A0A0A); // Vercel surface dark
  static const kPrimaryColor= Color(0xFFFFFFFF);
  static const kAccentColor = Color(0xFF666666); // Subtle gray

  static const kGlassOpacity = 0.05;
  static const kBlurSigma    = 8.0;

  // Gradient for backgrounds (flat monochrome now)
  static const List<Color> kBgGradient = [
    Color(0xFF000000),
    Color(0xFF000000),
  ];
}
