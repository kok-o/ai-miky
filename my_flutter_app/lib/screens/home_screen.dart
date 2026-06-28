import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_bar_custom.dart';
import '../widgets/ai_cursor.dart';
import '../widgets/logo_01.dart';
import '../widgets/blurred_circle.dart';
import '../state/app_state.dart';
import 'auth_screen.dart';
import '../theme/theme_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onStartChat});
  final VoidCallback onStartChat;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n     = AppLocalizations.of(context)!;
    final scheme   = Theme.of(context).colorScheme;
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    final greeting = appState.isLoggedIn
        ? 'Привет, ${appState.displayName.isNotEmpty ? appState.displayName : (appState.email?.split('@').first ?? 'User')}!'
        : l10n.loginOrRegister;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          if (isDark)
            const DarkBackground()
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.12),
                    scheme.surface,
                  ],
                ),
              ),
            ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  expandedHeight: 110,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Logo01(size: 36, heroTag: null),
                    centerTitle: true,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Greeting pill ──────────────────────────────────────────
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: ThemeConstants.kDurationMed,
                          builder: (context, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, -12 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: isDark
                                    ? ThemeConstants.kBrandCyan.withValues(alpha: 0.25)
                                    : scheme.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.waving_hand_rounded, size: 20),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    greeting,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : scheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                    const SizedBox(height: 24),

                    // ── AI cursor orb ──────────────────────────────────────────
                    const AiCursor(size: 160),

                    const SizedBox(height: 24),

                    // ── Headline + subtitle ────────────────────────────────────
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: ThemeConstants.kDurationMed,
                      curve: Curves.easeOutCubic,
                      builder: (context, v, child) => Opacity(
                        opacity: v,
                        child: Transform.scale(
                          scale: 0.96 + 0.04 * v,
                          child: child,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            l10n.helloMiku,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.2,
                              height: 1.1,
                              color: isDark ? Colors.white : scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.personalAssistant,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : scheme.onSurface.withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 52),

                    // ── CTA button ─────────────────────────────────────────────
                    Hero(
                      tag: 'chat_button_hero',
                      child: FilledButton.icon(
                        onPressed: onStartChat,
                        icon: const Icon(Icons.chat_bubble_rounded, size: 20),
                        label: Text(l10n.startChat),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(220, 58),
                          textStyle: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                        const SizedBox(height: 16),

                        if (!appState.isLoggedIn)
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const AuthScreen()),
                            ),
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: Text(l10n.loginOrRegister),
                          ),
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
