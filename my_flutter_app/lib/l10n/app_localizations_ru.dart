// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Miku';

  @override
  String get authTitle => 'Авторизация';

  @override
  String get email => 'Почта';

  @override
  String get password => 'Пароль';

  @override
  String get login => 'Войти';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get noAccount => 'Нет аккаунта? Регистрация';

  @override
  String get hasAccount => 'Уже есть аккаунт? Войти';

  @override
  String get enterEmailPassword => 'Введите почту и пароль';

  @override
  String get profile => 'Профиль';

  @override
  String get name => 'Имя';

  @override
  String get aboutMe => 'О себе';

  @override
  String get saveProfile => 'Сохранить профиль';

  @override
  String get profileSaved => 'Профиль сохранён';

  @override
  String get messages => 'Сообщений';

  @override
  String get consecutiveDays => 'Дней подряд';

  @override
  String get model => 'Модель';

  @override
  String get loginOrRegister => 'Войти или зарегистрироваться';

  @override
  String get appTheme => 'Тема приложения';

  @override
  String get dark => 'Тёмная';

  @override
  String get light => 'Светлая';

  @override
  String get aiModel => 'Модель ИИ';

  @override
  String get logout => 'Выйти';

  @override
  String get loggedOut => 'Вы вышли из аккаунта';

  @override
  String get settings => 'Настройки';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get selectModel => 'Выберите модель';

  @override
  String get about => 'О приложении';

  @override
  String get aboutText => 'AI Assistant MVP for coursework using Flutter + OpenAI';

  @override
  String get chatTitle => 'AI Ассистент';

  @override
  String get clearChat => 'Очистить чат';

  @override
  String get pleaseLogin => 'Пожалуйста, войдите в систему';

  @override
  String get error => 'Ошибка';

  @override
  String get errorAuth => 'Ошибка авторизации';

  @override
  String get helloMiku => 'Привет, я Miku!';

  @override
  String get personalAssistant => 'Твой персональный AI‑ассистент.';

  @override
  String get startChat => 'Начать общение';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get loginToChangePhoto => 'Войдите в систему для изменения фото';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get deletePhoto => 'Удалить фото';

  @override
  String get uploadingPhoto => 'Загрузка фото...';

  @override
  String get photoUpdated => 'Фото профиля обновлено';

  @override
  String get photoUploadError => 'Ошибка загрузки фото';

  @override
  String get deletePhotoConfirm => 'Удалить фото?';

  @override
  String get deletePhotoConfirmText => 'Вы уверены, что хотите удалить фото профиля?';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get photoDeleted => 'Фото удалено';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get russian => 'Русский';

  @override
  String get kazakh => 'Қазақша';

  @override
  String get english => 'English';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get weakPassword => 'Слишком простой пароль.';

  @override
  String get emailInUse => 'Этот Email уже используется.';

  @override
  String registrationError(Object message) {
    return 'Ошибка регистрации: $message';
  }

  @override
  String get userNotFound => 'Пользователь не найден.';

  @override
  String get wrongPassword => 'Неверный пароль.';

  @override
  String get invalidEmail => 'Некорректный Email.';

  @override
  String loginError(Object message) {
    return 'Ошибка входа: $message';
  }

  @override
  String generalError(Object error) {
    return 'Ошибка: $error';
  }
}
