import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _sttAvailable = false;
  bool _isSpeaking = false;
  bool _isListening = false;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initStt() async {
    _sttAvailable = await _stt.initialize(
      onStatus: (status) {},
      onError: (error) {},
    );
  }

  Future<void> initTts({String languageCode = 'ru'}) async {
    await _tts.setLanguage(_ttsLocale(languageCode));
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);
  }

  // ── TTS (speak) ───────────────────────────────────────────────────────────

  Future<void> speak(String text, {String languageCode = 'ru'}) async {
    if (_isSpeaking) {
      await stop();
    }
    await _tts.setLanguage(_ttsLocale(languageCode));
    await _tts.speak(text);
    _isSpeaking = true;
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> pause() async {
    await _tts.pause();
    _isSpeaking = false;
  }

  // ── STT (listen) ──────────────────────────────────────────────────────────

  /// Starts listening. Calls [onResult] with transcribed text.
  Future<bool> startListening({
    required void Function(String text) onResult,
    required void Function() onDone,
    String languageCode = 'ru',
  }) async {
    if (!_sttAvailable) {
      await initStt();
    }
    if (!_sttAvailable) return false;

    _isListening = true;

    await _stt.listen(
      onResult: (result) {
        if (result.finalResult) {
          _isListening = false;
          onResult(result.recognizedWords);
          onDone();
        } else {
          onResult(result.recognizedWords);
        }
      },
      localeId: _sttLocale(languageCode),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenMode: stt.ListenMode.confirmation,
    );

    return true;
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _stt.stop();
  }

  bool get sttAvailable => _sttAvailable;

  // ── Locale helpers ────────────────────────────────────────────────────────

  String _ttsLocale(String code) {
    switch (code) {
      case 'kk': return 'kk-KZ';
      case 'en': return 'en-US';
      default:   return 'ru-RU';
    }
  }

  String _sttLocale(String code) {
    switch (code) {
      case 'kk': return 'kk_KZ';
      case 'en': return 'en_US';
      default:   return 'ru_RU';
    }
  }
}
