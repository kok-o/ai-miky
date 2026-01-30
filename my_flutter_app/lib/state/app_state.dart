import 'dart:typed_data';
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

  ThemeMode _themeMode = ThemeMode.light;
  String _selectedModel = 'gpt-3.5-turbo';
  String _displayName = '';
  String _bio = '';
  int _avatarColorValue = 0xFF7C8CFF;
  int _messageCount = 0;
  int _consecutiveDays = 0;
  String? _profilePhotoUrl;
  Locale _locale = const Locale('ru');
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  
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

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    final model = prefs.getString(_modelKey);
    final name = prefs.getString(_nameKey);
    final bio = prefs.getString(_bioKey);
    final color = prefs.getInt(_avatarColorKey);
    final languageCode = prefs.getString(_languageKey);
    
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    if (model != null && model.isNotEmpty) {
      _selectedModel = model;
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
    
    // Listen to auth changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _initializeUserStats(user.uid);
      } else {
        _messageCount = 0;
        _consecutiveDays = 0;
        _profilePhotoUrl = null;
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
    } else {
       // Only load from prefs if not found in Firestore (or offline/first load fallback)
       // But strictly speaking, if we follow the pattern, we already loaded prefs in load()
       // so we just override if Firestore has data.
    }
    
    // Load profile photo (redundant if covered above, but kept for specific getter)
    // _profilePhotoUrl = await _firestoreService.getProfilePhotoUrl(userId); 
    
    // Load message count
    _messageCount = await _firestoreService.getUserMessageCount(userId);
    
    // Listen to message count changes
    _firestoreService.getUserMessageCountStream(userId).listen((count) {
      _messageCount = count;
      notifyListeners();
    });
    
    // Listen to consecutive days changes
    _firestoreService.getConsecutiveDaysStream(userId).listen((days) {
      _consecutiveDays = days;
      notifyListeners();
    });
    
    // Listen to profile photo changes
    _firestoreService.getProfilePhotoUrlStream(userId).listen((url) {
      _profilePhotoUrl = url;
      notifyListeners();
    });
    
    notifyListeners();
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
      print('Error uploading profile photo: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}




