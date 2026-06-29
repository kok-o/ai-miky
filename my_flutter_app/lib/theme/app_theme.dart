import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_constants.dart';

class AppTheme {
  // ── shared helpers ──────────────────────────────────────────────────────────
  static RoundedRectangleBorder _rounded(double r) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  static InputDecorationTheme _inputTheme(Color fill, Color primary, bool isDark) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.12),
            width: 1
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: isDark ? Colors.white : Colors.black, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5)
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.4)
        ),
      );

  // ── DARK theme (primary experience) ─────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeConstants.kPrimaryColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary:            Colors.white,
      onPrimary:          Colors.black,
      secondary:          ThemeConstants.kAccentColor,
      onSecondary:        Colors.white,
      surface:            ThemeConstants.kBrandSurface,
      onSurface:          Colors.white,
      surfaceContainerHighest: const Color(0xFF111111),
      outline:            Colors.white12,
    ),
    scaffoldBackgroundColor: ThemeConstants.kBrandDark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    typography: Typography.material2021(),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.kBrandDark.withValues(alpha: 0.85),
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    ),

    // Cards
    cardTheme: CardThemeData(
      elevation: 0,
      shape: _rounded(12),
      color: ThemeConstants.kBrandSurface,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),

    // Buttons
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: _rounded(8),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -0.3),
        elevation: 0,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white70,
      ),
    ),

    // Inputs
    inputDecorationTheme: _inputTheme(
      Colors.transparent,
      Colors.white,
      true, // isDark
    ),

    // Navigation bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ThemeConstants.kBrandDark,
      indicatorColor: Colors.white.withValues(alpha: 0.1),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return IconThemeData(color: Colors.white.withValues(alpha: 0.5), size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 12,
        );
      }),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),

    // Snackbar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF111111),
      contentTextStyle: GoogleFonts.inter(color: Colors.white),
      shape: _rounded(8),
      elevation: 4,
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.12),
      space: 1,
    ),

    // ListTile
    listTileTheme: ListTileThemeData(
      shape: _rounded(8),
      tileColor: Colors.transparent,
      textColor: Colors.white,
      iconColor: Colors.white,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.black : Colors.white54),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : Colors.white12),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) => Colors.transparent),
    ),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),

    // Page transitions
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );

  // ── LIGHT theme ─────────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      brightness: Brightness.light,
    ).copyWith(
      primary:   Colors.black,
      onPrimary: Colors.white,
      secondary: const Color(0xFF666666),
      surface:   const Color(0xFFFAFAFA),
      outline:   Colors.black12,
    ),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    typography: Typography.material2021(),
    
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      foregroundColor: Colors.black,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: _rounded(12),
      color: const Color(0xFFFAFAFA),
      shadowColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: _rounded(8),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -0.3),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: _inputTheme(
      Colors.transparent,
      Colors.black,
      false, // isDark
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: _rounded(8),
      elevation: 4,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.black.withValues(alpha: 0.12),
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      shape: _rounded(8),
      tileColor: Colors.transparent,
      textColor: Colors.black,
      iconColor: Colors.black,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : Colors.black54),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.black : Colors.black12),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) => Colors.transparent),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
