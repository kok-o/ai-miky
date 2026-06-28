// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => 'Miku';

  @override
  String get authTitle => 'Авторизация';

  @override
  String get email => 'Электрондық пошта';

  @override
  String get password => 'Құпия сөз';

  @override
  String get login => 'Кіру';

  @override
  String get register => 'Тіркелу';

  @override
  String get noAccount => 'Аккаунт жоқ па? Тіркелу';

  @override
  String get hasAccount => 'Аккаунт бар ма? Кіру';

  @override
  String get enterEmailPassword => 'Электрондық пошта мен құпия сөзді енгізіңіз';

  @override
  String get profile => 'Профиль';

  @override
  String get name => 'Аты';

  @override
  String get aboutMe => 'Өзім туралы';

  @override
  String get saveProfile => 'Профильді сақтау';

  @override
  String get profileSaved => 'Профиль сақталды';

  @override
  String get messages => 'Хабарламалар';

  @override
  String get consecutiveDays => 'Үздіксіз күндер';

  @override
  String get model => 'Модель';

  @override
  String get loginOrRegister => 'Кіру немесе тіркелу';

  @override
  String get appTheme => 'Қолданба тақырыбы';

  @override
  String get dark => 'Қараңғы';

  @override
  String get light => 'Жарық';

  @override
  String get aiModel => 'AI Моделі';

  @override
  String get logout => 'Шығу';

  @override
  String get loggedOut => 'Сіз жүйеден шықтыңыз';

  @override
  String get settings => 'Баптаулар';

  @override
  String get darkTheme => 'Қараңғы тақырып';

  @override
  String get selectModel => 'Модельді таңдаңыз';

  @override
  String get about => 'Қолданба туралы';

  @override
  String get aboutText => 'Flutter + OpenAI пайдаланатын курстық жұмыс үшін AI Assistant MVP';

  @override
  String get chatTitle => 'AI Көмекшісі';

  @override
  String get clearChat => 'Чатты тазалау';

  @override
  String get pleaseLogin => 'Жүйеге кіріңіз';

  @override
  String get error => 'Қате';

  @override
  String get errorAuth => 'Авторизация қатесі';

  @override
  String get helloMiku => 'Сәлем, мен Miku!';

  @override
  String get personalAssistant => 'Сіздің жеке AI көмекшіңіз.';

  @override
  String get startChat => 'Сұхбат бастау';

  @override
  String get changeAvatarColor => 'Аватар түсін өзгерту';

  @override
  String get changeColor => 'Түсті өзгерту';

  @override
  String get changePhoto => 'Фотоны өзгерту';

  @override
  String get loginToChangePhoto => 'Фотоны өзгерту үшін жүйеге кіріңіз';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get deletePhoto => 'Фотоны жою';

  @override
  String get uploadingPhoto => 'Фото жүктелуде...';

  @override
  String get photoUpdated => 'Профиль фотосы жаңартылды';

  @override
  String get photoUploadError => 'Фото жүктеу қатесі';

  @override
  String get deletePhotoConfirm => 'Фотоны жою керек пе?';

  @override
  String get deletePhotoConfirmText => 'Профиль фотосын жоюға сенімдісіз бе?';

  @override
  String get cancel => 'Болдырмау';

  @override
  String get delete => 'Жою';

  @override
  String get photoDeleted => 'Фото жойылды';

  @override
  String get language => 'Тіл';

  @override
  String get selectLanguage => 'Тілді таңдаңыз';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get english => 'English';

  @override
  String get showPassword => 'Құпия сөзді көрсету';

  @override
  String get hidePassword => 'Құпия сөзді жасыру';

  @override
  String get weakPassword => 'Тым қарапайым құпия сөз.';

  @override
  String get emailInUse => 'Бұл Email қолданыста.';

  @override
  String registrationError(Object message) {
    return 'Тіркеу қатесі: $message';
  }

  @override
  String get userNotFound => 'Пайдаланушы табылмады.';

  @override
  String get wrongPassword => 'Қате құпия сөз.';

  @override
  String get invalidEmail => 'Дұрыс емес Email.';

  @override
  String loginError(Object message) {
    return 'Кіру қатесі: $message';
  }

  @override
  String get ollamaConnectionError => 'Ollama қол жетімсіз. Ollama іске қосыңыз (ollama serve) немесе Android эмуляторы үшін Баптауларда http://10.0.2.2:11434 көрсетіңіз. Немесе Gemini моделін таңдаңыз.';

  @override
  String get ollamaUrlSaved => 'Ollama URL сақталды';

  @override
  String generalError(Object error) {
    return 'Қате: $error';
  }

  @override
  String get welcomeBack => 'Қайта оралуыңызбен!';

  @override
  String get createAccount => 'Аккаунт жасаңыз';

  @override
  String get askSomething => 'Бірдеңе сұраңыз...';

  @override
  String get ollamaBaseUrl => 'Ollama Base URL';

  @override
  String get changePassword => 'Құпиясөзді өзгерту';

  @override
  String get reportBug => 'Қате туралы хабарлау';

  @override
  String get adminPanel => 'Әкімші тақтасы';

  @override
  String get currentPassword => 'Ағымдағы құпиясөз';

  @override
  String get newPassword => 'Жаңа құпиясөз';

  @override
  String get save => 'Сақтау';

  @override
  String get passwordChanged => 'Құпиясөз сәтті өзгертілді';

  @override
  String get describeProblem => 'Мәселені сипаттаңыз...';

  @override
  String get send => 'Жіберу';

  @override
  String get reportSent => 'Есеп жіберілді';

  @override
  String get noReports => 'Әзірге есептер жоқ';

  @override
  String get anonymous => 'Анонимді';

  @override
  String get unknown => 'Белгісіз';

  @override
  String get description => 'Сипаттамасы:';

  @override
  String get noDescription => 'Сипаттама жоқ';

  @override
  String get fixed => 'Түзетілді';

  @override
  String get newStatus => 'Жаңа';

  @override
  String get home => 'Басты бет';

  @override
  String get chat => 'Чат';

  @override
  String get wrongCurrentPassword => 'Ағымдағы құпиясөз қате';
}
