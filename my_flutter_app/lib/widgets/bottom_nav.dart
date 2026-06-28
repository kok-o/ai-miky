import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';
import '../l10n/app_localizations.dart';
import 'logo_01.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme  = Theme.of(context).colorScheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final l10n    = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A14) : scheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTap,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: ThemeConstants.kBrandCyan.withValues(alpha: isDark ? 0.12 : 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: ThemeConstants.kDurationMed,
        destinations: [
          _dest(
            index: 0,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: l10n.home,
            useLogo: true,
            currentIndex: currentIndex,
          ),
          _dest(
            index: 1,
            icon: Icons.chat_bubble_outline_rounded,
            selectedIcon: Icons.chat_bubble_rounded,
            label: l10n.chat,
            currentIndex: currentIndex,
          ),
          _dest(
            index: 2,
            icon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            label: l10n.profile,
            currentIndex: currentIndex,
          ),
          _dest(
            index: 3,
            icon: Icons.tune_outlined,
            selectedIcon: Icons.tune_rounded,
            label: l10n.settings,
            currentIndex: currentIndex,
          ),
        ],
      ),
    );
  }

  NavigationDestination _dest({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int currentIndex,
    bool useLogo = false,
  }) {
    final isSelected = currentIndex == index;

    return NavigationDestination(
      icon: AnimatedScale(
        duration: ThemeConstants.kDurationFast,
        scale: isSelected ? 1.15 : 1.0,
        child: useLogo
            ? Logo01(
                size: 26,
                showText: false,
                color: isSelected ? ThemeConstants.kBrandCyan : Colors.white38,
              )
            : Icon(isSelected ? selectedIcon : icon),
      ),
      selectedIcon: useLogo 
          ? Logo01(
              size: 28,
              showText: false,
              color: ThemeConstants.kBrandCyan,
            )
          : Icon(selectedIcon, color: ThemeConstants.kBrandCyan),
      label: label,
    );
  }
}
