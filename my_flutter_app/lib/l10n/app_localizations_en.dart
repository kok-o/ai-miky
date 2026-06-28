// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Miku';

  @override
  String get authTitle => 'Authorization';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Sign In';

  @override
  String get register => 'Sign Up';

  @override
  String get noAccount => 'No account? Sign Up';

  @override
  String get hasAccount => 'Already have an account? Sign In';

  @override
  String get enterEmailPassword => 'Enter email and password';

  @override
  String get profile => 'Profile';

  @override
  String get name => 'Name';

  @override
  String get aboutMe => 'About Me';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get messages => 'Messages';

  @override
  String get consecutiveDays => 'Days in a Row';

  @override
  String get model => 'Model';

  @override
  String get loginOrRegister => 'Sign In or Sign Up';

  @override
  String get appTheme => 'App Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get aiModel => 'AI Model';

  @override
  String get logout => 'Logout';

  @override
  String get loggedOut => 'You have logged out';

  @override
  String get settings => 'Settings';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get selectModel => 'Select Model';

  @override
  String get about => 'About';

  @override
  String get aboutText => 'AI Assistant MVP for coursework using Flutter + OpenAI';

  @override
  String get chatTitle => 'AI Assistant';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get pleaseLogin => 'Please sign in';

  @override
  String get error => 'Error';

  @override
  String get errorAuth => 'Authorization Error';

  @override
  String get helloMiku => 'Hello, I\'m Miku!';

  @override
  String get personalAssistant => 'Your personal AI assistant.';

  @override
  String get startChat => 'Start Chat';

  @override
  String get changeAvatarColor => 'Change Avatar Color';

  @override
  String get changeColor => 'Change Color';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get loginToChangePhoto => 'Sign in to change photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get deletePhoto => 'Delete Photo';

  @override
  String get uploadingPhoto => 'Uploading photo...';

  @override
  String get photoUpdated => 'Profile photo updated';

  @override
  String get photoUploadError => 'Photo upload error';

  @override
  String get deletePhotoConfirm => 'Delete Photo?';

  @override
  String get deletePhotoConfirmText => 'Are you sure you want to delete the profile photo?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get photoDeleted => 'Photo deleted';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get english => 'English';

  @override
  String get showPassword => 'Show Password';

  @override
  String get hidePassword => 'Hide Password';

  @override
  String get weakPassword => 'Password is too weak.';

  @override
  String get emailInUse => 'This Email is already in use.';

  @override
  String registrationError(Object message) {
    return 'Registration error: $message';
  }

  @override
  String get userNotFound => 'User not found.';

  @override
  String get wrongPassword => 'Wrong password.';

  @override
  String get invalidEmail => 'Invalid Email.';

  @override
  String loginError(Object message) {
    return 'Sign in error: $message';
  }

  @override
  String get ollamaConnectionError => 'Ollama is unavailable. Start Ollama (ollama serve) or for Android emulator use http://10.0.2.2:11434 in Settings → Ollama Base URL. Or select a Gemini model.';

  @override
  String get ollamaUrlSaved => 'Ollama URL saved';

  @override
  String generalError(Object error) {
    return 'Error: $error';
  }

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get createAccount => 'Create account';

  @override
  String get askSomething => 'Ask something...';

  @override
  String get ollamaBaseUrl => 'Ollama Base URL';

  @override
  String get changePassword => 'Change Password';

  @override
  String get reportBug => 'Report a Bug';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get save => 'Save';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get describeProblem => 'Describe the problem...';

  @override
  String get send => 'Send';

  @override
  String get reportSent => 'Report sent';

  @override
  String get noReports => 'No reports yet';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get unknown => 'Unknown';

  @override
  String get description => 'Description:';

  @override
  String get noDescription => 'No description';

  @override
  String get fixed => 'Fixed';

  @override
  String get newStatus => 'New';

  @override
  String get home => 'Home';

  @override
  String get chat => 'Chat';

  @override
  String get wrongCurrentPassword => 'Wrong current password';
}
