import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_constants.dart';

/// Miku AI — Vercel-inspired theme system.
///
/// Design decisions:
/// - Geist Mono NOT available via google_fonts, using JetBrains Mono instead
/// - Inter for UI body paired with JetBrains Mono for technical accents (T1 fix)
/// - Accent: Vercel Blue #0070F3 (user preference)
/// - Surface hierarchy: dark0 → dark1 → dark2 (C1/C2 fix)
class AppTheme {
  // ── Shared helpers ────────────────────────────────────────────────────────
  static RoundedRectangleBorder _rounded(double r) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  static TextTheme _buildTextTheme(TextTheme base) {
    // ponytail: google_fonts already installed (rung 5)
    return GoogleFonts.interTextTheme(base).copyWith(
      // Mono accents for display/technical elements
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  static InputDecorationTheme _inputTheme(bool isDark) {
    final borderColor = isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder;
    final focusBorderColor = ThemeConstants.kAccentBlue;
    final hintColor = isDark
        ? const Color(0xFF555555)
        : const Color(0xFF999999);

    return InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
        borderSide: BorderSide(color: focusBorderColor, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: hintColor,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: TextStyle(
        color: hintColor,
        fontWeight: FontWeight.w400,
      ),
      // Focus ring matches brand (impeccable premium marker #4)
      focusColor: ThemeConstants.kAccentBlueDim,
    );
  }

  // ── DARK theme (primary experience) ──────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary:            ThemeConstants.kAccentBlue,
      onPrimary:          Colors.white,
      secondary:          ThemeConstants.kTextSecondary,
      onSecondary:        Colors.white,
      surface:            ThemeConstants.kDark1,
      onSurface:          ThemeConstants.kTextPrimary,
      surfaceContainerHighest: ThemeConstants.kDark2,
      outline:            ThemeConstants.kDarkBorder,
      // For non-primary filled buttons (white)
      tertiary:           ThemeConstants.kTextPrimary,
      onTertiary:         ThemeConstants.kDark0,
    ),
    scaffoldBackgroundColor: ThemeConstants.kDark0,
    textTheme: _buildTextTheme(ThemeData.dark().textTheme),
    typography: Typography.material2021(),

    // AppBar — frosted glass, transparent
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.kDark0.withValues(alpha: 0.80),
      foregroundColor: ThemeConstants.kTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ThemeConstants.kTextPrimary,
        letterSpacing: -0.4,
      ),
    ),

    // Cards — flat, subtle border
    cardTheme: CardThemeData(
      elevation: 0,
      shape: _rounded(ThemeConstants.kRadiusMd),
      color: ThemeConstants.kDark1,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),

    // Primary filled button — Vercel Blue
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ThemeConstants.kAccentBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ThemeConstants.kDark2,
        disabledForegroundColor: ThemeConstants.kTextSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: _rounded(ThemeConstants.kRadiusMd),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: -0.2,
        ),
        elevation: 0,
      ),
    ),

    // Outlined button — ghost style
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ThemeConstants.kTextPrimary,
        side: const BorderSide(color: ThemeConstants.kDarkBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: _rounded(ThemeConstants.kRadiusMd),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.kTextSecondary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: ThemeConstants.kTextSecondary,
      ),
    ),

    // Inputs
    inputDecorationTheme: _inputTheme(true),

    // Navigation bar — styled separately in BottomNav widget
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ThemeConstants.kDark0,
      indicatorColor: ThemeConstants.kAccentBlueDim,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: ThemeConstants.kAccentBlue, size: 22);
        }
        return const IconThemeData(color: ThemeConstants.kTextSecondary, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            color: ThemeConstants.kAccentBlue,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          );
        }
        return GoogleFonts.inter(
          color: ThemeConstants.kTextSecondary,
          fontSize: 11,
        );
      }),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ThemeConstants.kDark2,
      contentTextStyle: GoogleFonts.inter(
        color: ThemeConstants.kTextPrimary,
        fontSize: 14,
      ),
      shape: _rounded(ThemeConstants.kRadiusMd),
      elevation: 8,
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: ThemeConstants.kDarkBorder,
      space: 1,
      thickness: 1,
    ),

    // ListTile
    listTileTheme: ListTileThemeData(
      shape: _rounded(ThemeConstants.kRadiusMd),
      tileColor: Colors.transparent,
      textColor: ThemeConstants.kTextPrimary,
      iconColor: ThemeConstants.kTextSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),

    // Switch — accent blue when on
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? Colors.white
              : ThemeConstants.kTextTertiary),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? ThemeConstants.kAccentBlue
              : ThemeConstants.kDark2),
      trackOutlineColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
    ),

    // FAB
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.kAccentBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: _rounded(ThemeConstants.kRadiusMd),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: ThemeConstants.kDark1,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shape: _rounded(ThemeConstants.kRadiusLg),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ThemeConstants.kTextPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: ThemeConstants.kTextSecondary,
      ),
    ),

    // Bottom sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ThemeConstants.kDark1,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: ThemeConstants.kTextTertiary,
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: ThemeConstants.kDark2,
      disabledColor: ThemeConstants.kDark1,
      selectedColor: ThemeConstants.kAccentBlueDim,
      side: const BorderSide(color: ThemeConstants.kDarkBorder, width: 1),
      shape: _rounded(ThemeConstants.kRadiusSm),
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ThemeConstants.kTextPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // Page transitions — snappy (Vercel feel)
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ── LIGHT theme ───────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary:   ThemeConstants.kAccentBlue,
      onPrimary: Colors.white,
      secondary: ThemeConstants.kTextSecondaryLight,
      surface:   ThemeConstants.kLight0,
      onSurface: ThemeConstants.kTextPrimaryLight,
      outline:   ThemeConstants.kLightBorder,
    ),
    scaffoldBackgroundColor: ThemeConstants.kLight0,
    textTheme: _buildTextTheme(ThemeData.light().textTheme),
    typography: Typography.material2021(),

    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.kLight0.withValues(alpha: 0.85),
      foregroundColor: ThemeConstants.kTextPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ThemeConstants.kTextPrimaryLight,
        letterSpacing: -0.4,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: _rounded(ThemeConstants.kRadiusMd),
      color: ThemeConstants.kLight1,
      shadowColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ThemeConstants.kAccentBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: _rounded(ThemeConstants.kRadiusMd),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -0.2),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ThemeConstants.kTextPrimaryLight,
        side: const BorderSide(color: ThemeConstants.kLightBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: _rounded(ThemeConstants.kRadiusMd),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.kTextSecondaryLight,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),

    inputDecorationTheme: _inputTheme(false),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ThemeConstants.kTextPrimaryLight,
      contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      shape: _rounded(ThemeConstants.kRadiusMd),
      elevation: 8,
    ),

    dividerTheme: const DividerThemeData(
      color: ThemeConstants.kLightBorder,
      space: 1,
      thickness: 1,
    ),

    listTileTheme: ListTileThemeData(
      shape: _rounded(ThemeConstants.kRadiusMd),
      tileColor: Colors.transparent,
      textColor: ThemeConstants.kTextPrimaryLight,
      iconColor: ThemeConstants.kTextSecondaryLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : Colors.white70),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? ThemeConstants.kAccentBlue
              : ThemeConstants.kLightBorder),
      trackOutlineColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.kAccentBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: _rounded(ThemeConstants.kRadiusMd),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: ThemeConstants.kLight1,
      surfaceTintColor: Colors.transparent,
      elevation: 16,
      shape: _rounded(ThemeConstants.kRadiusLg),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ThemeConstants.kTextPrimaryLight,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ThemeConstants.kLight1,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: ThemeConstants.kLight0,
      side: const BorderSide(color: ThemeConstants.kLightBorder, width: 1),
      shape: _rounded(ThemeConstants.kRadiusSm),
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: ThemeConstants.kTextPrimaryLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ThemeConstants.kLight0,
      indicatorColor: ThemeConstants.kAccentBlueDim,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: ThemeConstants.kAccentBlue, size: 22);
        }
        return const IconThemeData(color: ThemeConstants.kTextSecondaryLight, size: 22);
      }),
      elevation: 0,
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
