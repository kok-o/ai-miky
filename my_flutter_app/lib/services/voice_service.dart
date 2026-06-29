import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

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
    await _tts.setPitch(1.1); // Slightly raised for a warmer Miku voice

    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((_) => _isSpeaking = false);
  }

  // ── Native Audio (Gemini Live API PCM bytes) ──────────────────────────────

  /// Plays raw PCM16 audio bytes received from Gemini Native Audio Dialog.
  /// Gemini Live API returns PCM 16-bit, 24000 Hz, mono.
  Future<void> playPcmBytes(Uint8List pcmBytes) async {
    if (_isSpeaking) {
      await stop();
    }
    _isSpeaking = true;

    try {
      // audioplayers can play bytes directly as BytesSource
      await _audioPlayer.play(BytesSource(pcmBytes));
      _audioPlayer.onPlayerComplete.listen((_) {
        _isSpeaking = false;
      });
    } catch (e) {
      _isSpeaking = false;
      debugPrint('[VoiceService] Error playing PCM bytes: $e');
    }
  }

  /// Stops any currently playing audio (both TTS and native audio).
  Future<void> stop() async {
    await _tts.stop();
    await _audioPlayer.stop();
    _isSpeaking = false;
  }

  // ── TTS Fallback (speak) ──────────────────────────────────────────────────

  /// Fallback TTS: used when Gemini Native Audio is not available (e.g. web).
  Future<void> speak(String text, {String languageCode = 'ru'}) async {
    if (_isSpeaking) {
      await stop();
    }
    await _tts.setLanguage(_ttsLocale(languageCode));
    await _tts.speak(text);
    _isSpeaking = true;
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
