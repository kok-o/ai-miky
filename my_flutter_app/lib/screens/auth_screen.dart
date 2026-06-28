import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/logo_01.dart';
import '../widgets/blurred_circle.dart';
import '../theme/theme_constants.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin         = true;
  bool _loading         = false;
  bool _obscurePassword = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: ThemeConstants.kDurationSlow);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final app  = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final pwd   = _passwordController.text;
    if (email.isEmpty || pwd.isEmpty) {
      _showSnack(l10n.enterEmailPassword);
      return;
    }
    if (!mounted) return;
    setState(() => _loading = true);
    final err = _isLogin
        ? await app.login(email: email, password: pwd, l10n: l10n)
        : await app.register(email: email, password: pwd, l10n: l10n);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) _showSnack(err);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _showLanguageSelector(BuildContext ctx) async {
    final appState = ctx.read<AppState>();
    final l10n     = AppLocalizations.of(ctx)!;
    final sel = await showModalBottomSheet<Locale>(
      context: ctx,
      backgroundColor: const Color(0xFF111120),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(l10n.selectLanguage,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white)),
              const SizedBox(height: 8),
              _langTile(context, l10n.russian,  const Locale('ru'), appState.locale),
              _langTile(context, l10n.kazakh,   const Locale('kk'), appState.locale),
              _langTile(context, l10n.english,  const Locale('en'), appState.locale),
            ],
          ),
        ),
      ),
    );
    if (sel != null) await appState.setLocale(sel);
  }

  Widget _langTile(BuildContext ctx, String label, Locale value, Locale current) {
    final isSelected = current.languageCode == value.languageCode;
    return ListTile(
      title: Text(label,
          style: TextStyle(
              color: isSelected ? ThemeConstants.kBrandCyan : Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal)),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: ThemeConstants.kBrandCyan)
          : null,
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ─────────────────────────────────────────────────────
          if (isDark) const DarkBackground()
          else Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primaryContainer.withValues(alpha: 0.3),
                  scheme.surface,
                  scheme.secondaryContainer.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Logo ─────────────────────────────────────────────
                        const Logo01(
                          size: 88,
                          heroTag: 'auth_logo_hero',
                          showMikuSubtitle: true,
                        ),
                        const SizedBox(height: 20),

                        // ── Title ─────────────────────────────────────────────
                        AnimatedSwitcher(
                          duration: ThemeConstants.kDurationFast,
                          child: Text(
                            _isLogin ? l10n.welcomeBack : l10n.createAccount,
                            key: ValueKey(_isLogin),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: isDark ? Colors.white : scheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isDark
                              ? 'Войдите, чтобы продолжить'
                              : 'Добро пожаловать в Miku AI',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.45)
                                : scheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Card ─────────────────────────────────────────────
                        _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: l10n.email,
                                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: l10n.password,
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded),
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              AnimatedSwitcher(
                                duration: ThemeConstants.kDurationFast,
                                child: _loading
                                    ? const Center(
                                        child: SizedBox(
                                          height: 44,
                                          width: 44,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: ThemeConstants.kBrandCyan,
                                          ),
                                        ),
                                      )
                                    : FilledButton(
                                        key: const ValueKey('btn'),
                                        onPressed: _submit,
                                        child:
                                            Text(_isLogin ? l10n.login : l10n.register),
                                      ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Toggle login/register ─────────────────────────────
                        TextButton(
                          onPressed: () => setState(() => _isLogin = !_isLogin),
                          child: Text(_isLogin ? l10n.noAccount : l10n.hasAccount),
                        ),

                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.language_rounded),
                          tooltip: l10n.selectLanguage,
                          color: isDark ? Colors.white38 : null,
                          onPressed: () => _showLanguageSelector(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable glassmorphism card ─────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
