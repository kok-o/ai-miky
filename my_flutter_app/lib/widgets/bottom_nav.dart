import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme_constants.dart';
import '../l10n/app_localizations.dart';
import 'logo_01.dart';

/// Vercel-style bottom navigation bar.
///
/// Design decisions:
/// - Custom Row instead of Material NavigationBar for precise control
/// - Frosted glass background (BackdropFilter blur)
/// - Label ONLY for active tab (user preference: Vercel-style compromise)
/// - Animated label fade-in when tab becomes active
/// - No pill indicator background — accent color on icon/label only
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;

    final bgColor = isDark
        ? ThemeConstants.kDark0.withValues(alpha: 0.92)
        : ThemeConstants.kLight0.withValues(alpha: 0.92);
    final borderColor = isDark
        ? ThemeConstants.kDarkBorder
        : ThemeConstants.kLightBorder;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: ThemeConstants.kBlurSigma,
          sigmaY: ThemeConstants.kBlurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              top: BorderSide(color: borderColor, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _NavItem(
                    index: 0,
                    currentIndex: currentIndex,
                    label: l10n.home,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    useLogo: true,
                    isDark: isDark,
                    onTap: onTap,
                  ),
                  _NavItem(
                    index: 1,
                    currentIndex: currentIndex,
                    label: l10n.chat,
                    icon: Icons.chat_bubble_outline_rounded,
                    selectedIcon: Icons.chat_bubble_rounded,
                    isDark: isDark,
                    onTap: onTap,
                  ),
                  _NavItem(
                    index: 2,
                    currentIndex: currentIndex,
                    label: l10n.profile,
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    isDark: isDark,
                    onTap: onTap,
                  ),
                  _NavItem(
                    index: 3,
                    currentIndex: currentIndex,
                    label: l10n.settings,
                    icon: Icons.tune_outlined,
                    selectedIcon: Icons.tune_rounded,
                    isDark: isDark,
                    onTap: onTap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isDark,
    required this.onTap,
    this.useLogo = false,
  });

  final int index;
  final int currentIndex;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isDark;
  final ValueChanged<int> onTap;
  final bool useLogo;

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    final activeColor   = ThemeConstants.kAccentBlue;
    final inactiveColor = isDark ? ThemeConstants.kTextTertiary : const Color(0xFFAAAAAA);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          duration: ThemeConstants.kDurationFast,
          curve: Curves.easeOutCubic,
          scale: isSelected ? 1.0 : 0.96,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icon ──────────────────────────────────────────────────────
              AnimatedSwitcher(
                duration: ThemeConstants.kDurationFast,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: useLogo
                    ? Logo01(
                        key: ValueKey('logo_$isSelected'),
                        size: 22,
                        showText: false,
                        color: isSelected ? activeColor : inactiveColor,
                      )
                    : Icon(
                        key: ValueKey('icon_${index}_$isSelected'),
                        isSelected ? selectedIcon : icon,
                        color: isSelected ? activeColor : inactiveColor,
                        size: 22,
                      ),
              ),

              // ── Label — only for active tab ───────────────────────────────
              AnimatedSize(
                duration: ThemeConstants.kDurationMed,
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: activeColor,
                            letterSpacing: 0.2,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: ThemeConstants.kDurationFast),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
