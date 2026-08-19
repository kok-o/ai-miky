import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/logo_01.dart';
import '../theme/theme_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _nameController = TextEditingController(text: appState.displayName);
    _bioController  = TextEditingController(text: appState.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _changeAvatarColor(BuildContext context, AppState appState) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = [
      const Color(0xFF7C8CFF),
      const Color(0xFFFF7C7C),
      const Color(0xFF7CFF8C),
      const Color(0xFFFFD17C),
      const Color(0xFFC77CFF),
      const Color(0xFF7CFFF6),
      const Color(0xFF212121),
      const Color(0xFFF5F5F5),
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? ThemeConstants.kDark1 : ThemeConstants.kLight1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.changeAvatarColor,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((color) {
                  final isSelected = appState.avatarColor.toARGB32() == color.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      appState.setAvatarColor(color);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? ThemeConstants.kAccentBlue
                              : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(
                                color: ThemeConstants.kAccentBlue.withValues(alpha: 0.4),
                                blurRadius: 8,
                              )]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final l10n     = AppLocalizations.of(context)!;

    final textColor   = isDark ? ThemeConstants.kTextPrimary   : ThemeConstants.kTextPrimaryLight;
    final mutedColor  = isDark ? ThemeConstants.kTextSecondary : ThemeConstants.kTextSecondaryLight;
    final borderColor = isDark ? ThemeConstants.kDarkBorder    : ThemeConstants.kLightBorder;
    final surfaceBg   = isDark ? ThemeConstants.kDark1         : ThemeConstants.kLight1;

    return Scaffold(
      // Minimal flat AppBar — spacious header
      appBar: AppBar(
        toolbarHeight: 68,
        title: Logo01(size: 36, text: l10n.profile, heroTag: null),
        centerTitle: true,
      ),
      body: Container(
        color: isDark ? ThemeConstants.kDark0 : ThemeConstants.kLight0,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Avatar ─────────────────────────────────────────────────────
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () => _changeAvatarColor(context, appState),
                      child: Hero(
                        tag: 'profile_avatar_hero',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: borderColor,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: appState.avatarColor,
                            backgroundImage: appState.profilePhotoUrl != null
                                ? NetworkImage(appState.profilePhotoUrl!)
                                : null,
                            child: appState.profilePhotoUrl == null
                                ? const Icon(Icons.person_rounded, size: 44, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                    ),
                    // Palette button — always visible with explicit bg
                    GestureDetector(
                      onTap: () => _changeAvatarColor(context, appState),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark ? ThemeConstants.kDark2 : ThemeConstants.kLight0,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 1.5),
                        ),
                        child: Icon(
                          Icons.palette_rounded,
                          size: 16,
                          color: isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms),

              const SizedBox(height: 28),

              // ── Name ────────────────────────────────────────────────────────
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  prefixIcon: const Icon(Icons.badge_rounded),
                ),
                onSubmitted: (v) => appState.setDisplayName(v.trim()),
              ).animate(delay: 60.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              // ── Bio ─────────────────────────────────────────────────────────
              TextField(
                controller: _bioController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.aboutMe,
                  prefixIcon: const Icon(Icons.info_rounded),
                ),
                onSubmitted: (v) => appState.setBio(v.trim()),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              // ── Save button ─────────────────────────────────────────────────
              FilledButton.icon(
                onPressed: () async {
                  await appState.setDisplayName(_nameController.text.trim());
                  await appState.setBio(_bioController.text.trim());
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.profileSaved)),
                  );
                },
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.saveProfile),
              ).animate(delay: 140.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 32),

              // ── Stats ───────────────────────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                    title: l10n.messages,
                    value: appState.isLoggedIn ? appState.messageCount.toString() : '0',
                    isDark: isDark,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    surfaceBg: surfaceBg,
                    borderColor: borderColor,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    title: l10n.consecutiveDays,
                    value: appState.isLoggedIn ? appState.consecutiveDays.toString() : '0',
                    isDark: isDark,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    surfaceBg: surfaceBg,
                    borderColor: borderColor,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    title: l10n.model,
                    value: appState.selectedModel.split('-').last,
                    isDark: isDark,
                    textColor: textColor,
                    mutedColor: mutedColor,
                    surfaceBg: surfaceBg,
                    borderColor: borderColor,
                  ),
                ],
              ).animate(delay: 180.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // ── Theme toggle ─────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: surfaceBg,
                  borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: SwitchListTile(
                  title: Text(l10n.appTheme, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                  secondary: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: mutedColor,
                  ),
                  value: appState.themeMode == ThemeMode.dark,
                  onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                ),
              ).animate(delay: 220.ms).fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceBg,
    required this.borderColor,
  });

  final String title;
  final String value;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceBg;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, color: mutedColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
