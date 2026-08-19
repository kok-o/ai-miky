import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../widgets/ai_cursor.dart';
import '../widgets/logo_01.dart';
import '../state/app_state.dart';
import 'auth_screen.dart';
import '../theme/theme_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onStartChat,
    this.onOpenProfile,
  });

  final void Function([String? prompt]) onStartChat;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n     = AppLocalizations.of(context)!;
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    final userName = appState.isLoggedIn
        ? (appState.displayName.isNotEmpty
            ? appState.displayName
            : appState.email?.split('@').first ?? 'User')
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ────────────────────────────────────────────────────
          _HomeBackground(isDark: isDark),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header bar
                SliverToBoxAdapter(
                  child: _TopBar(
                    isDark: isDark,
                    userName: userName,
                    onOpenProfile: onOpenProfile,
                    onLogin: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    ),
                  ),
                ),

                // Main hero section
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 2),

                        // Orb
                        AiCursor(size: 140)
                          .animate()
                          .fadeIn(delay: 80.ms, duration: 500.ms)
                          .scale(
                            begin: const Offset(0.85, 0.85),
                            end: const Offset(1, 1),
                            delay: 80.ms,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),

                        const SizedBox(height: 36),

                        // Headline
                        _HeadlineBlock(l10n: l10n, isDark: isDark)
                          .animate()
                          .fadeIn(delay: 160.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 160.ms, duration: 400.ms, curve: Curves.easeOut),

                        const Spacer(flex: 1),

                        // Capability chips
                        _CapabilityChips(
                          isDark: isDark,
                          l10n: l10n,
                          onSelectCapability: (prompt) => onStartChat(prompt),
                        )
                          .animate()
                          .fadeIn(delay: 240.ms, duration: 400.ms)
                          .slideY(begin: 0.08, end: 0, delay: 240.ms, duration: 400.ms),

                        const SizedBox(height: 32),

                        // CTA Button
                        _CtaButton(l10n: l10n, onTap: onStartChat)
                          .animate()
                          .fadeIn(delay: 320.ms, duration: 350.ms)
                          .slideY(begin: 0.08, end: 0, delay: 320.ms, duration: 350.ms),

                        // Secondary login button
                        if (!appState.isLoggedIn)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AuthScreen()),
                              ),
                              icon: const Icon(Icons.login_rounded, size: 16),
                              label: Text(l10n.loginOrRegister),
                            ),
                          )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 300.ms),

                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _HomeBackground extends StatelessWidget {
  const _HomeBackground({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: isDark ? ThemeConstants.kDark0 : ThemeConstants.kLight0,
        ),
        // Ambient blue glow — top center (subtle, not rainbow)
        Positioned(
          top: -80,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ThemeConstants.kAccentBlue.withValues(alpha: isDark ? 0.07 : 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isDark,
    required this.userName,
    required this.onLogin,
    this.onOpenProfile,
  });

  final bool isDark;
  final String? userName;
  final VoidCallback onLogin;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Logo01(
            size: 34,
            text: 'Miku',
            color: isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight,
          ),
          const Spacer(),
          if (userName != null)
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: onOpenProfile,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? ThemeConstants.kDark1 : ThemeConstants.kLight1,
                    borderRadius: BorderRadius.circular(ThemeConstants.kRadiusPill),
                    border: Border.all(
                      color: isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Online indicator dot
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF22C55E), // green-500
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        userName!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _HeadlineBlock extends StatelessWidget {
  const _HeadlineBlock({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight;
    final mutedColor = isDark ? ThemeConstants.kTextSecondary : ThemeConstants.kTextSecondaryLight;

    return Column(
      children: [
        Text(
          l10n.helloMiku,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            height: 1.05,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.personalAssistant,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: mutedColor,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

/// Quick capability chips — shows what Miku can do (clickable with prompts)
class _CapabilityChips extends StatelessWidget {
  const _CapabilityChips({
    required this.isDark,
    required this.l10n,
    required this.onSelectCapability,
  });

  final bool isDark;
  final AppLocalizations l10n;
  final void Function(String prompt) onSelectCapability;

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder;
    final textColor = isDark ? ThemeConstants.kTextSecondary : ThemeConstants.kTextSecondaryLight;
    final bgColor = isDark ? ThemeConstants.kDark2 : ThemeConstants.kLight1;

    final items = [
      (Icons.psychology_rounded,   l10n.analysis,    l10n.promptAnalysis),
      (Icons.code_rounded,         l10n.code,        l10n.promptCode),
      (Icons.translate_rounded,    l10n.translation, l10n.promptTranslation),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: items.asMap().entries.map((entry) {
        final i = entry.key;
        final (icon, label, prompt) = entry.value;
        return GestureDetector(
          onTap: () => onSelectCapability(prompt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(ThemeConstants.kRadiusPill),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: textColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: (240 + i * 50).ms)
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOut);
      }).toList(),
    );
  }
}

class _CtaButton extends StatefulWidget {
  const _CtaButton({required this.l10n, required this.onTap});
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: Hero(
        tag: 'chat_button_hero',
        child: AnimatedScale(
          duration: ThemeConstants.kDurationFast,
          curve: Curves.easeOutCubic,
          scale: _hovered ? 1.02 : 1.0,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: widget.onTap,
              icon: const Icon(Icons.chat_bubble_rounded, size: 18),
              label: Text(widget.l10n.startChat),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
