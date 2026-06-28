import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/logo_01.dart';
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
    final appState = context.watch<AppState>();
    final isDark = appState.themeMode == ThemeMode.dark;
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Logo01(size: 38, text: l10n.settings, heroTag: null),
              centerTitle: true,
              background: Container(
                color: scheme.secondaryContainer.withValues(alpha: 0.3),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  child: SwitchListTile(
                    title: Text(l10n.darkTheme),
                    secondary: const Icon(Icons.dark_mode_rounded),
                    value: isDark,
                    onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(l10n.language),
                    subtitle: Text(_getLanguageName(appState.locale, l10n)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showLanguageSelector(context),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile(
                    title: const Text('Голосовые ответы ИИ'),
                    subtitle: const Text('ИИ зачитывает ответы вслух'),
                    secondary: const Icon(Icons.record_voice_over_rounded),
                    value: appState.voiceEnabled,
                    onChanged: (v) => appState.setVoiceEnabled(v),
                  ),
                ),
                const SizedBox(height: 24),
                Text(l10n.model, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: appState.selectedModel,
                      decoration: const InputDecoration(border: InputBorder.none),
                      items: const [
                        DropdownMenuItem(value: 'gemini-2.5-flash', child: Text('Gemini 2.5 Flash Native Audio Dialog')),
                        DropdownMenuItem(value: '', enabled: false, child: Divider()),
                        DropdownMenuItem(value: 'ollama:llama3', child: Text('Ollama: Llama 3')),
                        DropdownMenuItem(value: 'ollama:mistral', child: Text('Ollama: Mistral')),
                        DropdownMenuItem(value: 'ollama:qwen3:8b', child: Text('Ollama: Qwen 3 8B')),
                        DropdownMenuItem(value: 'ollama:phi3', child: Text('Ollama: Phi 3')),
                      ],
                      onChanged: (v) {
                        if (v != null && v.isNotEmpty) appState.setSelectedModel(v);
                      },
                    ),
                  ),
                ),
                if (appState.isOllamaModel) ...[
                  const SizedBox(height: 16),
                  Text(l10n.ollamaBaseUrl, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ollamaUrlController,
                    decoration: InputDecoration(
                      hintText: 'http://localhost:11434',
                      helperText: 'Emulator: http://10.0.2.2:11434',
                    ),
                    onSubmitted: (_) => _saveOllamaUrl(),
                    onEditingComplete: _saveOllamaUrl,
                    keyboardType: TextInputType.url,
                  ),
                ],
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                if (appState.isLoggedIn) ...[
                  _SettingsAction(
                    icon: Icons.lock_reset_rounded,
                    title: l10n.changePassword,
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _SettingsAction(
                    icon: Icons.bug_report_rounded,
                    title: l10n.reportBug,
                    onTap: () => _showBugReportDialog(context),
                  ),
                  if (appState.isAdmin)
                    _SettingsAction(
                      icon: Icons.admin_panel_settings_rounded,
                      title: l10n.adminPanel,
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminReportsScreen())),
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _SettingsAction(
                    icon: Icons.logout_rounded,
                    title: l10n.logout,
                    color: Colors.red,
                    onTap: () async {
                      await appState.logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.loggedOut)));
                      }
                    },
                  ),
                ],
                const SizedBox(height: 48),
                const Center(
                  child: Text(
                    'Miku AI v1.0.0',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
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

class _SettingsAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsAction({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}





