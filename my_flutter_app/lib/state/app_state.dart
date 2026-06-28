import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _modelKey = 'selected_model';
  static const String _nameKey = 'profile_display_name';
  static const String _bioKey = 'profile_bio';
  static const String _avatarColorKey = 'profile_avatar_color';
  static const String _languageKey = 'app_language';
  static const String _ollamaUrlKey = 'ollama_base_url';
  static const String _voiceEnabledKey = 'voice_enabled';

  ThemeMode _themeMode = ThemeMode.light;
  String _selectedModel = 'gemini-2.5-flash';
  String _displayName = '';
  String _bio = '';
  int _avatarColorValue = 0xFF7C8CFF;
  int _messageCount = 0;
  int _consecutiveDays = 0;
  String? _profilePhotoUrl;
  Locale _locale = const Locale('ru');
  String _ollamaBaseUrl = 'http://localhost:11434';
  String _role = 'user';
  bool _voiceEnabled = true;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  
  // Stream subscriptions
  StreamSubscription? _messageCountSub;
  StreamSubscription? _consecutiveDaysSub;
  StreamSubscription? _profilePhotoUrlSub;
  
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get email => _auth.currentUser?.email;

  ThemeMode get themeMode => _themeMode;
  String get selectedModel => _selectedModel;
  String get displayName => _displayName;
  String get bio => _bio;
  Color get avatarColor => Color(_avatarColorValue);
  int get messageCount => _messageCount;
  int get consecutiveDays => _consecutiveDays;
  String? get profilePhotoUrl => _profilePhotoUrl;
  Locale get locale => _locale;
  String get ollamaBaseUrl => _ollamaBaseUrl;
  String get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get voiceEnabled => _voiceEnabled;

  bool get isOllamaModel => _selectedModel.startsWith('ollama:');
  String get cleanModelName => isOllamaModel ? _selectedModel.replaceFirst('ollama:', '') : _selectedModel;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    final model = prefs.getString(_modelKey);
    final name = prefs.getString(_nameKey);
    final bio = prefs.getString(_bioKey);
    final color = prefs.getInt(_avatarColorKey);
    final languageCode = prefs.getString(_languageKey);
    final ollamaUrl = prefs.getString(_ollamaUrlKey);
    final voiceEnabled = prefs.getBool(_voiceEnabledKey);

    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    if (model != null && model.isNotEmpty) {
      // Validate model exists in current allowed list
      const allowedModels = ['gemini-2.5-flash', 'ollama:llama3', 'ollama:mistral', 'ollama:qwen3:8b', 'ollama:phi3'];
      if (allowedModels.contains(model)) {
        _selectedModel = model;
      } else {
        _selectedModel = 'gemini-2.5-flash'; // Fallback
      }
    }
    if (name != null) {
      _displayName = name;
    }
    if (bio != null) {
      _bio = bio;
    }
    if (color != null) {
      _avatarColorValue = color;
    }
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }
    if (ollamaUrl != null && ollamaUrl.isNotEmpty) {
      _ollamaBaseUrl = ollamaUrl;
    }
    if (voiceEnabled != null) {
      _voiceEnabled = voiceEnabled;
    }

    
    // Listen to auth changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _initializeUserStats(user.uid);
      } else {
        _messageCount = 0;
        _consecutiveDays = 0;
        _profilePhotoUrl = null;
        _cancelSubscriptions();
      }
      notifyListeners();
    });
    
    // Initialize stats if already logged in
    final user = _auth.currentUser;
    if (user != null) {
      _initializeUserStats(user.uid);
    }
    
    notifyListeners();
  }

  Future<void> _initializeUserStats(String userId) async {
    // Update consecutive days on login
    _consecutiveDays = await _firestoreService.updateConsecutiveDays(userId);

    // Load user profile
    final profileData = await _firestoreService.getUserProfile(userId);
    if (profileData != null) {
      if (profileData.containsKey('displayName')) {
        _displayName = profileData['displayName'] as String;
        // Also update local prefs to keep them in sync/cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_nameKey, _displayName);
      }
      if (profileData.containsKey('bio')) {
        _bio = profileData['bio'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_bioKey, _bio);
      }
      if (profileData.containsKey('profilePhotoUrl')) {
        _profilePhotoUrl = profileData['profilePhotoUrl'] as String;
      }
      if (profileData.containsKey('role')) {
        _role = profileData['role'] as String;
      }
    } else {
       // Only load from prefs if not found in Firestore (or offline/first load fallback)
       // But strictly speaking, if we follow the pattern, we already loaded prefs in load()
       // so we just override if Firestore has data.
    }
    
    // Load profile photo (redundant if covered above, but kept for specific getter)
    // _profilePhotoUrl = await _firestoreService.getProfilePhotoUrl(userId); 
    
    // Load message count
    _messageCount = await _firestoreService.getUserMessageCount(userId);
    
    _messageCountSub?.cancel();
    _consecutiveDaysSub?.cancel();
    _profilePhotoUrlSub?.cancel();

    // Listen to message count changes
    _messageCountSub = _firestoreService.getUserMessageCountStream(userId).listen((count) {
      _messageCount = count;
      notifyListeners();
    });
    
    // Listen to consecutive days changes
    _consecutiveDaysSub = _firestoreService.getConsecutiveDaysStream(userId).listen((days) {
      _consecutiveDays = days;
      notifyListeners();
    });
    
    // Listen to profile photo changes
    _profilePhotoUrlSub = _firestoreService.getProfilePhotoUrlStream(userId).listen((url) {
      _profilePhotoUrl = url;
      notifyListeners();
    });
    
    notifyListeners();
  }

  void _cancelSubscriptions() {
    _messageCountSub?.cancel();
    _messageCountSub = null;
    _consecutiveDaysSub?.cancel();
    _consecutiveDaysSub = null;
    _profilePhotoUrlSub?.cancel();
    _profilePhotoUrlSub = null;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setSelectedModel(String model) async {
    _selectedModel = model;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modelKey, model);
  }

  Future<void> setOllamaBaseUrl(String url) async {
    _ollamaBaseUrl = url;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ollamaUrlKey, url);
  }

  Future<void> setDisplayName(String name) async {
    _displayName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    
    if (isLoggedIn) {
      await _firestoreService.updateUserProfile(currentUser!.uid, _displayName, _bio);
    }
  }

  Future<void> setBio(String value) async {
    _bio = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bioKey, value);
    
    if (isLoggedIn) {
      await _firestoreService.updateUserProfile(currentUser!.uid, _displayName, _bio);
    }
  }

  Future<void> setAvatarColor(Color color) async {
    _avatarColorValue = color.value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_avatarColorKey, _avatarColorValue);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }

  Future<void> setVoiceEnabled(bool value) async {
    _voiceEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceEnabledKey, value);
  }

  Future<String?> register({
    required String email,
    required String password,
    dynamic l10n,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _initializeUserStats(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (l10n != null) {
        if (e.code == 'weak-password') {
          return l10n.weakPassword;
        } else if (e.code == 'email-already-in-use') {
          return l10n.emailInUse;
        }
        return l10n.registrationError(e.message ?? '') as String;
      }
      // Fallback to English if l10n not provided
      if (e.code == 'weak-password') {
        return 'Password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'This Email is already in use.';
      }
      return 'Registration error: ${e.message}';
    } catch (e) {
      if (l10n != null) {
        return l10n.generalError(e.toString()) as String;
      }
      return 'Error: $e';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
    dynamic l10n,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (credential.user != null) {
        await _initializeUserStats(credential.user!.uid);
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (l10n != null) {
        if (e.code == 'user-not-found') {
          return l10n.userNotFound;
        } else if (e.code == 'wrong-password') {
          return l10n.wrongPassword;
        } else if (e.code == 'invalid-email') {
          return l10n.invalidEmail;
        }
        return l10n.loginError(e.message ?? '') as String;
      }
      // Fallback to English if l10n not provided
      if (e.code == 'user-not-found') {
        return 'User not found.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid Email.';
      }
      return 'Sign in error: ${e.message}';
    } catch (e) {
      if (l10n != null) {
        return l10n.generalError(e.toString()) as String;
      }
      return 'Error: $e';
    }
  }

  Future<void> setProfilePhoto(String? photoUrl) async {
    _profilePhotoUrl = photoUrl;
    notifyListeners();
    final user = currentUser;
    if (user != null) {
      await _firestoreService.saveProfilePhotoUrl(user.uid, photoUrl ?? '');
      if (photoUrl == null) {
        // Also delete from storage
        await _storageService.deleteProfilePhoto(user.uid);
      }
    }
  }

  Future<String?> uploadProfilePhoto(Uint8List imageBytes) async {
    final user = currentUser;
    if (user == null) return null;
    
    try {
      final photoUrl = await _storageService.uploadProfilePhoto(user.uid, imageBytes);
      if (photoUrl != null) {
        await setProfilePhoto(photoUrl);
      }
      return photoUrl;
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      return null;
    }
  }

  Future<void> logout() async {
    _cancelSubscriptions();
    await _auth.signOut();
  }

  Future<String?> changePassword(String oldPassword, String newPassword, {dynamic l10n}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return l10n?.generalError('Not logged in') ?? 'Пользователь не авторизован';

    try {
      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      
      // Update password
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') return l10n?.wrongPassword ?? 'Неверный текущий пароль';
      return e.message ?? l10n?.generalError(e.code) ?? 'Ошибка смены пароля';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> submitErrorReport(String description) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestoreService.sendErrorReport(user.uid, user.email ?? 'no-email', description);
  }
}




