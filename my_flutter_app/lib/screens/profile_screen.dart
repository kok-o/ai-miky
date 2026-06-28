import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    _bioController = TextEditingController(text: appState.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _changeAvatarColor(BuildContext context, AppState appState) async {
    final colors = [
      const Color(0xFF7C8CFF), // Indigo
      const Color(0xFFFF7C7C), // Coral
      const Color(0xFF7CFF8C), // Mint
      const Color(0xFFFFD17C), // Gold
      const Color(0xFFC77CFF), // Lavender
      const Color(0xFF7CFFF6), // Sky
      const Color(0xFF212121), // Charcoal
      const Color(0xFFF5F5F5), // Shell
    ];

    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.changeAvatarColor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      appState.setAvatarColor(color);
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: color,
                      radius: 20,
                      child: appState.avatarColor.value == color.value
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final scheme   = Theme.of(context).colorScheme;
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final l10n     = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 180,
            backgroundColor: isDark ? ThemeConstants.kBrandDark : scheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Logo01(size: 38, text: l10n.profile, heroTag: null),
              centerTitle: true,
              titlePadding: const EdgeInsets.only(bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            ThemeConstants.kBrandCyan.withValues(alpha: 0.08),
                            ThemeConstants.kBrandDark,
                          ]
                        : [
                            scheme.primaryContainer.withValues(alpha: 0.4),
                            scheme.surface,
                          ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () => _changeAvatarColor(context, appState),
                        child: Hero(
                          tag: 'profile_avatar_hero',
                          child: Container(
                            width: 116,
                            height: 116,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark
                                    ? ThemeConstants.kBrandCyan.withValues(alpha: 0.5)
                                    : scheme.primary.withValues(alpha: 0.3),
                                width: 2.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 56,
                              backgroundColor: appState.avatarColor,
                              backgroundImage: appState.profilePhotoUrl != null
                                  ? NetworkImage(appState.profilePhotoUrl!)
                                  : null,
                              child: appState.profilePhotoUrl == null
                                  ? const Icon(Icons.person_rounded,
                                      size: 52, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () => _changeAvatarColor(context, appState),
                        icon: const Icon(Icons.palette_rounded, size: 18),
                        tooltip: l10n.changeColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    prefixIcon: const Icon(Icons.badge_rounded),
                  ),
                  onSubmitted: (v) => appState.setDisplayName(v.trim()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: l10n.aboutMe,
                    prefixIcon: const Icon(Icons.info_rounded),
                  ),
                  onSubmitted: (v) => appState.setBio(v.trim()),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    await appState.setDisplayName(_nameController.text.trim());
                    await appState.setBio(_bioController.text.trim());
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: Text(l10n.saveProfile),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _StatCard(title: l10n.messages, value: appState.isLoggedIn ? appState.messageCount.toString() : '0'),
                    const SizedBox(width: 12),
                    _StatCard(title: l10n.consecutiveDays, value: appState.isLoggedIn ? appState.consecutiveDays.toString() : '0'),
                    const SizedBox(width: 12),
                    _StatCard(title: l10n.model, value: appState.selectedModel.split('-').last),
                  ],
                ),
                const SizedBox(height: 40),
                Card(
                  child: SwitchListTile(
                    title: Text(l10n.appTheme),
                    value: appState.themeMode == ThemeMode.dark,
                    onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}




