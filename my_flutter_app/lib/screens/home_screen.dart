import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/app_bar_custom.dart';
import '../widgets/ai_cursor.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onStartChat});

  final VoidCallback onStartChat;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBarCustom(title: l10n.appTitle),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AiCursor(size: 120),
              const SizedBox(height: 20),
              Text(l10n.helloMiku, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
              const SizedBox(height: 10),
              Text(
                l10n.personalAssistant,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: onStartChat,
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(l10n.startChat),
              ),
              const SizedBox(height: 12),
              if (!appState.isLoggedIn)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: Text(l10n.loginOrRegister),
                ),
            ],
          ),
        ),
      ),
    );
  }
}




