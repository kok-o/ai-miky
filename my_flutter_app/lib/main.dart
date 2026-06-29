import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'theme/theme_constants.dart';
import 'widgets/bottom_nav.dart';
import 'firebase_options.dart'; // Ensure this assumes generated options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: "env.txt");
  } catch (e) {
    debugPrint("DotEnv load warning: $e");
  }
  
  try {
     if (kIsWeb) {
       await Firebase.initializeApp(
         options: DefaultFirebaseOptions.currentPlatform,
       );
     } else {
       await Firebase.initializeApp();
     }
  } catch (e) {
     debugPrint("Firebase Init Error: $e");
  }

  try {
    final appState = AppState();
    await appState.load();
    runApp(ChangeNotifierProvider.value(value: appState, child: const AiAssistantApp()));
  } catch (e, stack) {
    debugPrint("App Init Error: $e\n$stack");
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Init Error: $e', style: TextStyle(color: Colors.red))))));
  }
}

class AiAssistantApp extends StatelessWidget {
  const AiAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Miku',
      themeMode: appState.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: appState.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
        Locale('kk'),
        Locale('en'),
      ],
      home: appState.isLoggedIn ? const _RootNav() : const AuthScreen(),
    );
  }
}

class _RootNav extends StatefulWidget {
  const _RootNav();

  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  int _index = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        key: const ValueKey('home'),
        onStartChat: () => setState(() => _index = 1),
      ),
      const ChatScreen(key: ValueKey('chat')),
      const ProfileScreen(key: ValueKey('profile')),
      const SettingsScreen(key: ValueKey('settings')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: ThemeConstants.kDurationMed,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _pages[_index],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
