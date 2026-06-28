# Miku AI Assistant

Miku AI Assistant is a Flutter-based multi-platform AI assistant that integrates with OpenAI, Gemini, and Ollama (Local LLM) models.

## Features

- **Multi-Model Support:** Chat with Google's Gemini, or switch to local models via Ollama.
- **Cross-Platform:** Built with Flutter, supporting Android, iOS, Web, and Desktop.
- **Localization:** Supports English, Russian, and Kazakh languages natively.
- **Firebase Backend:** Uses Firebase Authentication for users and Firestore for persistent chat history.
- **Theming:** Full light/dark mode support with beautiful UI, glassmorphism, and dynamic palettes.
- **Profile Customization:** Users can upload profile photos, change avatars, and track their usage stats.

## Getting Started

1. **Clone the repository.**
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Set up Firebase:**
   Configure your Firebase project and replace `google-services.json` and `GoogleService-Info.plist` with your own. Ensure Firestore and Authentication are enabled.
4. **Environment Variables:**
   Create a `.env` file at the root with your API keys:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```
5. **Run the App:**
   ```bash
   flutter run
   ```

## Using Ollama (Local AI)

To use local models, ensure Ollama is installed and running on your machine:
```bash
ollama serve
ollama run llama3
```
In the app's settings, specify the Ollama Base URL:
- Local development: `http://localhost:11434`
- Android Emulator: `http://10.0.2.2:11434`

## Technologies Used

- **Flutter / Dart**
- **Firebase** (Auth, Firestore, Storage)
- **Provider** (State Management)
- **Shared Preferences** (Local Storage)
- **Google Generative AI** SDK
