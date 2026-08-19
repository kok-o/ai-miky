import 'package:flutter/material.dart';

/// Vercel-inspired design tokens for Miku AI.
///
/// Key decisions:
/// - NO pure #000 or #fff (impeccable C1/C2)
/// - Tinted near-black surfaces with subtle warm undertone
/// - Vercel Blue as single accent color (user preference)
/// - JetBrains Mono for technical/numeric accents (like Vercel/Linear)
class ThemeConstants {
  // ── Animation durations (snappy Vercel cadence) ───────────────────────────
  static const kDurationFast  = Duration(milliseconds: 150);
  static const kDurationMed   = Duration(milliseconds: 220);
  static const kDurationSlow  = Duration(milliseconds: 380);

  // ── Curves ────────────────────────────────────────────────────────────────
  static const kCurveStandard   = Curves.easeOutCubic;
  static const kCurveEmphasized = Curves.fastOutSlowIn;

  // ── Dark mode surface hierarchy ───────────────────────────────────────────
  /// Base canvas — tinted near-black (NOT pure 0xFF000000 — impeccable C1)
  static const kDark0 = Color(0xFF0A0A0A);
  /// Elevated card surface
  static const kDark1 = Color(0xFF111111);
  /// Higher elevation (input, modal)
  static const kDark2 = Color(0xFF1A1A1A);
  /// Subtle border on dark
  static const kDarkBorder = Color(0x1AFFFFFF); // white 10%

  // ── Light mode surface hierarchy ──────────────────────────────────────────
  /// Base canvas — warm white (NOT pure #fff — impeccable C2)
  static const kLight0 = Color(0xFFFAFAFA);
  /// Card surface
  static const kLight1 = Color(0xFFFFFFFF);
  /// Subtle border on light
  static const kLightBorder = Color(0x1A000000); // black 10%

  // ── Brand accent — Vercel Blue ─────────────────────────────────────────────
  /// Used ONLY for: CTA buttons, active nav indicator, focus rings
  static const kAccentBlue = Color(0xFF0070F3);
  static const kAccentBlueDim = Color(0x330070F3); // 20% opacity for glow

  // ── Text hierarchy ────────────────────────────────────────────────────────
  static const kTextPrimary   = Color(0xFFFAFAFA);   // Dark mode primary text
  static const kTextSecondary = Color(0xFF888888);   // Muted — neutral gray
  static const kTextTertiary  = Color(0xFF555555);   // Very muted

  static const kTextPrimaryLight   = Color(0xFF0A0A0A);  // Light mode primary
  static const kTextSecondaryLight = Color(0xFF666666);  // Muted

  // ── Legacy aliases (kept for backward compat) ────────────────────────────
  /// @deprecated Use kDark0
  static const kBrandDark    = kDark0;
  /// @deprecated Use kDark1
  static const kBrandSurface = kDark1;
  /// @deprecated Use kAccentBlue
  static const kAccentColor  = kAccentBlue;
  static const kPrimaryColor = kTextPrimary;
  static const kBrandCyan    = kTextPrimary; // no longer cyan, kept for compat

  // ── Glass / blur ──────────────────────────────────────────────────────────
  static const kGlassOpacity = 0.04;
  static const kBlurSigma    = 12.0;

  // ── Border radius ─────────────────────────────────────────────────────────
  static const kRadiusSm = 6.0;
  static const kRadiusMd = 10.0;
  static const kRadiusLg = 16.0;
  static const kRadiusPill = 100.0;

  // ── Typography font family names ──────────────────────────────────────────
  /// JetBrains Mono — for: model names, timestamps, code, numeric data
  static const kMonoFontFamily = 'JetBrains Mono';

  // ── Background gradient (monochrome, subtle) ──────────────────────────────
  static const List<Color> kBgGradient = [kDark0, kDark0];
}
