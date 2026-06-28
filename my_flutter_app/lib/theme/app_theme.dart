import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_constants.dart';

class AppTheme {
  // ── shared helpers ──────────────────────────────────────────────────────────
  static RoundedRectangleBorder _rounded(double r) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  static InputDecorationTheme _inputTheme(Color fill, Color primary, bool isDark) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08), 
            width: 1
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
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
      primary:            ThemeConstants.kBrandCyan,
      onPrimary:          ThemeConstants.kBrandDark,
      secondary:          ThemeConstants.kAccentColor,
      onSecondary:        Colors.white,
      surface:            ThemeConstants.kBrandSurface,
      onSurface:          Colors.white,
      surfaceContainerHighest: const Color(0xFF1E1E2E),
      outline:            Colors.white12,
    ),
    scaffoldBackgroundColor: ThemeConstants.kBrandDark,
    typography: Typography.material2021(),

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: ThemeConstants.kBrandDark.withValues(alpha: 0.85),
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
    ),

    // Cards — glassmorphism feel
    cardTheme: CardThemeData(
      elevation: 0,
      shape: _rounded(20),
      color: Colors.white.withValues(alpha: 0.05),
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
    ),

    // Buttons
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ThemeConstants.kBrandCyan,
        foregroundColor: ThemeConstants.kBrandDark,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: _rounded(16),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3),
        elevation: 0,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ThemeConstants.kBrandCyan,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),

    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Colors.white70,
      ),
    ),

    // Inputs
    inputDecorationTheme: _inputTheme(
      Colors.white.withValues(alpha: 0.06),
      ThemeConstants.kBrandCyan,
      true, // isDark
    ),

    // Navigation bar
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ThemeConstants.kBrandDark,
      indicatorColor: ThemeConstants.kBrandCyan.withValues(alpha: 0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: ThemeConstants.kBrandCyan, size: 24);
        }
        return IconThemeData(color: Colors.white.withValues(alpha: 0.5), size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: ThemeConstants.kBrandCyan,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return TextStyle(
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
      backgroundColor: const Color(0xFF1E1E2E),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: _rounded(14),
      elevation: 12,
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.08),
      space: 1,
    ),

    // ListTile
    listTileTheme: ListTileThemeData(
      shape: _rounded(12),
      tileColor: Colors.transparent,
      textColor: Colors.white,
      iconColor: ThemeConstants.kBrandCyan,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? ThemeConstants.kBrandCyan : Colors.white54),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? ThemeConstants.kBrandCyan.withValues(alpha: 0.3)
              : Colors.white12),
    ),

    // FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ThemeConstants.kBrandCyan,
      foregroundColor: ThemeConstants.kBrandDark,
      elevation: 4,
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
    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeConstants.kPrimaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary:   const Color(0xFF0068D6),
      secondary: const Color(0xFF7B61FF),
      surface:   const Color(0xFFF6F7FC),
      outline:   Colors.black12,
    ),
    scaffoldBackgroundColor: const Color(0xFFF0F2F8),
    typography: Typography.material2021(),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: _rounded(20),
      color: Colors.white,
      shadowColor: Colors.black12,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: _rounded(16),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    inputDecorationTheme: _inputTheme(
      Colors.black.withValues(alpha: 0.04),
      const Color(0xFF0068D6),
      false, // isDark
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: _rounded(14),
      elevation: 8,
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
