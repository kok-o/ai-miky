# Miku AI

Персональный AI-ассистент на Flutter с поддержкой облачных моделей Google Gemini и локальных моделей через Ollama.

## Возможности

- **Поддержка моделей**: работа с Google Gemini (`gemini-3.1-flash-lite`, `gemini-3.5-flash-lite`) и локальными моделями через Ollama (`llama3`, `mistral`, `qwen`, `phi3`).
- **Голосовые ответы**: озвучивание ответов через Gemini Native Audio TTS с синхронной печатью текста во время речи.
- **Быстрый режим чата**: моментальный вывод текста эффектом печати при отключённом звуке.
- **Мультиязычность**: интерфейс и системный промпт на русском, казахском и английском языках.
- **Синхронизация данных**: авторизация через Firebase Auth, сохранение истории чата и настроек (тема, голос, язык, модель) в Cloud Firestore и локальном кэше.
- **Удобство на ПК**: отправка сообщений по нажатию Enter (Shift + Enter для новой строки).
- **Минималистичный интерфейс**: тёмная и светлая темы, быстрые карточки запросов и статистика активности.

## Стек технологий

- **Фреймворк**: Flutter / Dart
- **Бэкенд**: Firebase (Auth, Firestore, Storage)
- **API моделей**: Google Gemini API (v1beta), Ollama REST API
- **Озвучка**: Gemini TTS, flutter_tts
- **Локальное хранилище**: SharedPreferences
- **Шрифты и анимации**: Inter, JetBrains Mono, flutter_animate

## Настройка и запуск

### 1. Клонирование и зависимости
```bash
git clone https://github.com/kok-o/ai-miky.git
cd my_flutter_app
flutter pub get
```

### 2. Конфигурация API ключа
Создайте файл `env.txt` в папке `my_flutter_app/`:
```ini
GEMINI_API_KEY=ваш_ключ_от_google_ai_studio
```

### 3. Запуск
```bash
# Запуск в браузере
flutter run -d chrome

# Запуск на Windows
flutter run -d windows

# Запуск на Android / iOS
flutter run
```

## Работа с локальными моделями (Ollama)

1. Установите и запустите Ollama:
```bash
ollama serve
ollama pull llama3
```

2. В настройках приложения укажите адрес:
- Для ПК и браузера: `http://localhost:11434`
- Для Android эмулятора: `http://10.0.2.2:11434`
