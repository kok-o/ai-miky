import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../widgets/app_bar_custom.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

    return Scaffold(
      appBar: AppBarCustom(title: l10n.settings),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text(l10n.darkTheme),
            value: isDark,
            onChanged: (v) => appState.setThemeMode(v ? ThemeMode.dark : ThemeMode.light),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(_getLanguageName(appState.locale, l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageSelector(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.model, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: appState.selectedModel,
            items: const [
              DropdownMenuItem(value: 'gpt-3.5-turbo', child: Text('gpt-3.5-turbo')),
              DropdownMenuItem(value: 'gpt-4o-mini', child: Text('gpt-4o-mini')),
              DropdownMenuItem(value: 'gpt-4o', child: Text('gpt-4o')),
            ],
            onChanged: (v) {
              if (v != null) appState.setSelectedModel(v);
            },
          ),
          const SizedBox(height: 24),
          ListTile(
            title: Text(l10n.about),
            subtitle: Text(l10n.aboutText),
          )
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
}





