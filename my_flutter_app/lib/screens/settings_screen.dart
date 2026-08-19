import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/logo_01.dart';
import '../theme/theme_constants.dart';
import 'admin_reports_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _ollamaUrlController;

  @override
  void initState() {
    super.initState();
    _ollamaUrlController = TextEditingController(
      text: context.read<AppState>().ollamaBaseUrl,
    );
  }

  void _saveOllamaUrl() {
    final url = _ollamaUrlController.text.trim();
    final finalUrl = url.isEmpty ? 'http://localhost:11434' : url;
    context.read<AppState>().setOllamaBaseUrl(finalUrl);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.ollamaUrlSaved)),
      );
    }
  }

  @override
  void dispose() {
    _ollamaUrlController.dispose();
    super.dispose();
  }

  Future<void> _showLanguageSelector(BuildContext context) async {
    final appState = context.read<AppState>();
    final l10n = AppLocalizations.of(context)!;
    
    final selectedLanguage = await showModalBottomSheet<Locale>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.selectLanguage)),
            RadioListTile<Locale>(
              title: Text(l10n.russian),
              value: const Locale('ru'),
              groupValue: appState.locale,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<Locale>(
              title: Text(l10n.kazakh),
              value: const Locale('kk'),
              groupValue: appState.locale,
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<Locale>(
              title: Text(l10n.english),
              value: const Locale('en'),
              groupValue: appState.locale,
              onChanged: (v) => Navigator.pop(context, v),
            ),
          ],
        ),
      ),
    );

    if (selectedLanguage != null) {
      await appState.setLocale(selectedLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState    = context.watch<AppState>();
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final l10n        = AppLocalizations.of(context)!;
    final textColor   = isDark ? ThemeConstants.kTextPrimary   : ThemeConstants.kTextPrimaryLight;
    final mutedColor  = isDark ? ThemeConstants.kTextSecondary : ThemeConstants.kTextSecondaryLight;
    final borderColor = isDark ? ThemeConstants.kDarkBorder    : ThemeConstants.kLightBorder;
    final surfaceBg   = isDark ? ThemeConstants.kDark1         : ThemeConstants.kLight1;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Logo01(size: 36, text: l10n.settings, heroTag: null),
        centerTitle: true,
      ),
      body: Container(
        color: isDark ? ThemeConstants.kDark0 : ThemeConstants.kLight0,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight > 36 ? constraints.maxHeight - 36 : 0,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Appearance ──────────────────────────────────────────────────
                    _SectionLabel(l10n.appearanceSection, mutedColor),
                    const SizedBox(height: 8),
                    _SettingsTile(
                      surfaceBg: surfaceBg,
                      borderColor: borderColor,
                      child: SwitchListTile(
                        title: Text(l10n.darkTheme, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                        secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: mutedColor),
                        value: isDark,
                        onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                      ),
                    ).animate().fadeIn(duration: 300.ms),

                    const SizedBox(height: 8),
                    _SettingsTile(
                      surfaceBg: surfaceBg,
                      borderColor: borderColor,
                      child: ListTile(
                        leading: Icon(Icons.language_rounded, color: mutedColor),
                        title: Text(l10n.language, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                        subtitle: Text(_getLanguageName(appState.locale, l10n), style: TextStyle(color: mutedColor, fontSize: 13)),
                        trailing: Icon(Icons.chevron_right_rounded, color: mutedColor, size: 18),
                        onTap: () => _showLanguageSelector(context),
                      ),
                    ).animate(delay: 40.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 8),
                    _SettingsTile(
                      surfaceBg: surfaceBg,
                      borderColor: borderColor,
                      child: SwitchListTile(
                        title: Text(l10n.voiceResponsesTitle, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                        subtitle: Text(l10n.voiceResponsesSubtitle, style: TextStyle(color: mutedColor, fontSize: 13)),
                        secondary: Icon(Icons.record_voice_over_rounded, color: mutedColor),
                        value: appState.voiceEnabled,
                        onChanged: (v) => appState.setVoiceEnabled(v),
                      ),
                    ).animate(delay: 80.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 24),

                    // ── Model ────────────────────────────────────────────────────────
                    _SectionLabel(l10n.modelSection, mutedColor),
                    const SizedBox(height: 8),
                    _SettingsTile(
                      surfaceBg: surfaceBg,
                      borderColor: borderColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: appState.selectedModel,
                          dropdownColor: surfaceBg,
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: const InputDecoration(border: InputBorder.none),
                          items: [
                            DropdownMenuItem(value: 'gemini-3.1-flash-lite', child: Text('Gemini 3.1 Flash Lite (500 req/day)')),
                            DropdownMenuItem(value: 'gemini-3.5-flash-lite', child: Text('Gemini 3.5 Flash Lite (500 req/day)')),
                            DropdownMenuItem(value: 'gemini-3.7-flash',      child: Text('Gemini 3.7 Flash')),
                            DropdownMenuItem(value: 'gemini-2.5-flash',      child: Text('Gemini 2.5 Flash')),
                            DropdownMenuItem(value: '', enabled: false, child: Divider()),
                            DropdownMenuItem(value: 'ollama:llama3',    child: Text('Ollama: Llama 3')),
                            DropdownMenuItem(value: 'ollama:mistral',   child: Text('Ollama: Mistral')),
                            DropdownMenuItem(value: 'ollama:qwen3:8b',  child: Text('Ollama: Qwen 3 8B')),
                            DropdownMenuItem(value: 'ollama:phi3',      child: Text('Ollama: Phi 3')),
                          ],
                          onChanged: (v) {
                            if (v != null && v.isNotEmpty) appState.setSelectedModel(v);
                          },
                        ),
                      ),
                    ).animate(delay: 120.ms).fadeIn(duration: 300.ms),

                    if (appState.isOllamaModel) ...[
                      const SizedBox(height: 12),
                      Text(l10n.ollamaBaseUrl, style: TextStyle(fontWeight: FontWeight.w600, color: mutedColor, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _ollamaUrlController,
                        decoration: const InputDecoration(
                          hintText: 'http://localhost:11434',
                          helperText: 'Emulator: http://10.0.2.2:11434',
                        ),
                        onSubmitted: (_) => _saveOllamaUrl(),
                        onEditingComplete: _saveOllamaUrl,
                        keyboardType: TextInputType.url,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Account ──────────────────────────────────────────────────────
                    if (appState.isLoggedIn) ...[
                      _SectionLabel(l10n.accountSection, mutedColor),
                      const SizedBox(height: 8),
                      _SettingsAction(
                        icon: Icons.lock_reset_rounded,
                        title: l10n.changePassword,
                        isDark: isDark,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        surfaceBg: surfaceBg,
                        borderColor: borderColor,
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      const SizedBox(height: 8),
                      _SettingsAction(
                        icon: Icons.bug_report_rounded,
                        title: l10n.reportBug,
                        isDark: isDark,
                        textColor: textColor,
                        mutedColor: mutedColor,
                        surfaceBg: surfaceBg,
                        borderColor: borderColor,
                        onTap: () => _showBugReportDialog(context),
                      ),
                      if (appState.isAdmin) ...[
                        const SizedBox(height: 8),
                        _SettingsAction(
                          icon: Icons.admin_panel_settings_rounded,
                          title: l10n.adminPanel,
                          isDark: isDark,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          surfaceBg: surfaceBg,
                          borderColor: borderColor,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: surfaceBg,
                          borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.35), width: 1),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                          title: Text(l10n.logout, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFEF4444), size: 18),
                          onTap: () async {
                            await appState.logout();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.loggedOut)),
                              );
                            }
                          },
                        ),
                      ),
                    ],

                    const Spacer(),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Miku AI v1.0.0',
                        style: TextStyle(color: mutedColor, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageName(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'ru':
        return l10n.russian;
      case 'kk':
        return l10n.kazakh;
      case 'en':
        return l10n.english;
      default:
        return l10n.russian;
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(hintText: l10n.currentPassword),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(hintText: l10n.newPassword),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final error = await appState.changePassword(
                oldPasswordController.text,
                newPasswordController.text,
              );
              if (context.mounted) {
                if (error == null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.passwordChanged)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final reportController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final appState = context.read<AppState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reportBug),
        content: TextField(
          controller: reportController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.describeProblem,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reportController.text.trim().isEmpty) return;
              await appState.submitErrorReport(reportController.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.reportSent)),
                );
              }
            },
            child: Text(l10n.send),
          ),
        ],
      ),
    );
  }
}

/// Section label above a settings group
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

/// Container tile with border tokens
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.child, required this.surfaceBg, required this.borderColor});
  final Widget child;
  final Color surfaceBg;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }
}

class _SettingsAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;
  final Color textColor;
  final Color mutedColor;
  final Color surfaceBg;
  final Color borderColor;

  const _SettingsAction({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.surfaceBg,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
        border: Border.all(color: borderColor, width: 1),
      ),
      margin: const EdgeInsets.only(bottom: 0),
      child: ListTile(
        leading: Icon(icon, color: mutedColor, size: 20),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right_rounded, color: mutedColor, size: 18),
        onTap: onTap,
      ),
    );
  }
}





