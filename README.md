# Miku AI

A cross-platform personal AI assistant built with Flutter, supporting Google Gemini cloud models and local offline models via Ollama.

## Features

- **Model Support**: Works with Google Gemini (`gemini-3.1-flash-lite`, `gemini-3.5-flash-lite`) and local LLMs via Ollama (`llama3`, `mistral`, `qwen`, `phi3`).
- **Voice Responses**: Neural text-to-speech with Gemini Native Audio TTS, synchronized with live word-by-word text streaming.
- **Fast Chat Mode**: Instant typewriter response rendering when voice output is turned off.
- **Multilingual**: Complete interface and system prompts in English, Russian, and Kazakh.
- **Cloud & Local Sync**: Firebase Auth, Firestore history and user settings persistence (theme, voice, language, active model) alongside local caching.
- **Desktop Friendly**: Send messages with Enter (Shift + Enter for new lines).
- **Clean UI**: Minimalist light and dark themes, quick prompt chips, and activity stats.

## Tech Stack

- **Framework**: Flutter / Dart
- **Backend**: Firebase (Auth, Firestore, Storage)
- **AI APIs**: Google Gemini API (v1beta), Ollama REST API
- **Audio & Speech**: Gemini TTS, flutter_tts
- **Local Storage**: SharedPreferences
- **Fonts & Animations**: Inter, JetBrains Mono, flutter_animate

## Getting Started

### 1. Clone the repository and install dependencies
```bash
git clone https://github.com/kok-o/ai-miky.git
cd my_flutter_app
flutter pub get
```

### 2. Configure API Key
Create an `env.txt` file inside the `my_flutter_app/` directory:
```ini
GEMINI_API_KEY=your_gemini_api_key_here
```

### 3. Run the App
```bash
# Web (Chrome)
flutter run -d chrome

# Desktop (Windows)
flutter run -d windows

# Mobile (Android / iOS)
flutter run
```

## Running Local Models (Ollama)

1. Install and start Ollama:
```bash
ollama serve
ollama pull llama3
```

2. In the app settings, set the Ollama Base URL:
- Desktop & Web: `http://localhost:11434`
- Android Emulator: `http://10.0.2.2:11434`
