import 'package:flutter/material.dart';

class ThemeConstants {
  // Durations
  static const kDurationFast = Duration(milliseconds: 180);
  static const kDurationMed  = Duration(milliseconds: 350);
  static const kDurationSlow = Duration(milliseconds: 700);

  // Curves
  static const kCurveStandard   = Curves.easeInOutCubic;
  static const kCurveEmphasized = Curves.elasticOut;

  // Brand — "01" logo palette: electric cyan + near-black
  static const kBrandCyan   = Color(0xFF00E5FF); // electric cyan (logo stroke)
  static const kBrandDark   = Color(0xFF0D0D12); // near-black background
  static const kBrandSurface= Color(0xFF16161F); // slightly lighter surface
  static const kPrimaryColor= Color(0xFF00E5FF); // same as cyan for Material seed
  static const kAccentColor = Color(0xFF7B61FF); // soft violet accent

  static const kGlassOpacity = 0.12;
  static const kBlurSigma    = 12.0;

  // Gradient for backgrounds
  static const List<Color> kBgGradient = [
    Color(0xFF0D0D12),
    Color(0xFF111120),
    Color(0xFF0A1628),
  ];
}
