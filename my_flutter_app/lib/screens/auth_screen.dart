import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/logo_01.dart';
import '../theme/theme_constants.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _nameController     = TextEditingController();
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
    _nameController.dispose();
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
    final name  = _nameController.text.trim();

    if (email.isEmpty || pwd.isEmpty) {
      _showSnack(l10n.enterEmailPassword);
      return;
    }
    if (!mounted) return;
    setState(() => _loading = true);
    final err = _isLogin
        ? await app.login(email: email, password: pwd, l10n: l10n)
        : await app.register(email: email, password: pwd, name: name, l10n: l10n);
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
    final isDark   = Theme.of(ctx).brightness == Brightness.dark;
    final sel = await showModalBottomSheet<Locale>(
      context: ctx,
      backgroundColor: isDark ? ThemeConstants.kDark1 : ThemeConstants.kLight1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(l10n.selectLanguage,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight)),
              const SizedBox(height: 8),
              _langTile(context, l10n.russian,  const Locale('ru'), appState.locale, isDark),
              _langTile(context, l10n.kazakh,   const Locale('kk'), appState.locale, isDark),
              _langTile(context, l10n.english,  const Locale('en'), appState.locale, isDark),
            ],
          ),
        ),
      ),
    );
    if (sel != null) await appState.setLocale(sel);
  }

  Widget _langTile(BuildContext ctx, String label, Locale value, Locale current, bool isDark) {
    final isSelected = current.languageCode == value.languageCode;
    return ListTile(
      title: Text(label,
          style: TextStyle(
              color: isSelected ? ThemeConstants.kAccentBlue : (isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: ThemeConstants.kAccentBlue)
          : null,
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background ─────────────────────────────────────────────────────
          Container(
            color: isDark ? ThemeConstants.kDark0 : ThemeConstants.kLight0,
          ),
          // Subtle ambient glow
          Positioned(
            top: -120,
            left: 0, right: 0,
            child: Center(
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ThemeConstants.kAccentBlue.withValues(alpha: isDark ? 0.06 : 0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
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
                              color: isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Войдите, чтобы продолжить'
                              : 'Добро пожаловать в Miku AI',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? ThemeConstants.kTextSecondary : ThemeConstants.kTextSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // ── Card ─────────────────────────────────────────────
                        _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!_isLogin) ...[
                                TextField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: InputDecoration(
                                    hintText: l10n.name,
                                    prefixIcon: const Icon(Icons.person_outline_rounded),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
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
                                            strokeWidth: 2,
                                            color: ThemeConstants.kAccentBlue,
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
                          icon: const Icon(Icons.language_rounded, size: 20),
                          tooltip: l10n.selectLanguage,
                          color: isDark ? ThemeConstants.kTextTertiary : ThemeConstants.kTextSecondaryLight,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? ThemeConstants.kDark1 : ThemeConstants.kLight1,
        borderRadius: BorderRadius.circular(ThemeConstants.kRadiusLg),
        border: Border.all(
          color: isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
