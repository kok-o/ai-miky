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
import 'widgets/bottom_nav.dart';
import 'firebase_options.dart'; // Ensure this assumes generated options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  try {
     if (kIsWeb) {
       await Firebase.initializeApp(
         options: DefaultFirebaseOptions.currentPlatform,
       );
     } else {
       // For Android/iOS, if google-services.json is present, this works without options
       await Firebase.initializeApp();
     }
  } catch (e) {
     print("Firebase Init Error: $e");
     // Attempt fallback
     try {
       await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
     } catch (_) {}
  }

  final appState = AppState();
  await appState.load();
  runApp(ChangeNotifierProvider.value(value: appState, child: const AiAssistantApp()));
}

class AiAssistantApp extends StatelessWidget {
  const AiAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF7C8CFF),
      brightness: Brightness.light,
      visualDensity: VisualDensity.comfortable,
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF7C8CFF),
      brightness: Brightness.dark,
      visualDensity: VisualDensity.comfortable,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Miku',
      themeMode: appState.themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
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

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onStartChat: () => setState(() => _index = 1)),
      const ChatScreen(),
      const ProfileScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
