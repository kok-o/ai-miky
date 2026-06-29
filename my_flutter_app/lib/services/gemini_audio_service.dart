import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GeminiAudioService {
  final String languageCode;

  GeminiAudioService({this.languageCode = 'ru'});

  String get _mikuSystemPromptAudio {
    final lang = languageCode == 'en' ? 'English' : languageCode == 'kk' ? 'Kazakh' : 'Russian';
    return '''
You are Miku, a friendly, smart, and slightly playful AI assistant.
- You always introduce yourself as Miku. Never mention Gemini or Google.
- Communicate warmly, lively, and concisely.
- ALWAYS respond in the following language: $lang. This is a strict requirement.
- You help with any tasks: questions, ideas, code, studying.
- Answer by voice - briefly and to the point, without unnecessary words.
''';
  }

  static const String _liveApiEndpoint =
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent';

  // Model with native audio output
  static const String _audioModel = 'models/gemini-2.5-flash-native-audio-latest';

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  bool _connected = false;
  bool get isConnected => _connected;

  /// Called when audio PCM bytes arrive from the model.
  Function(Uint8List bytes)? onAudioChunk;

  /// Called when text arrives from the model.
  Function(String text)? onTextChunk;

  /// Called when model finishes generating a full turn.
  VoidCallback? onTurnComplete;

  /// Called on any error.
  Function(String error)? onError;

  /// Open a Live API session. Must be called before [sendText].
  Future<void> connect() async {
    if (_connected) return;

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      onError?.call('GEMINI_API_KEY not found in env.txt');
      return;
    }

    final uri = Uri.parse('$_liveApiEndpoint?key=$apiKey');

    try {
      _channel = WebSocketChannel.connect(uri);
      await _channel!.ready;

      _sub = _channel!.stream.listen(
        _onMessage,
        onError: (e) {
          _connected = false;
          onError?.call('WebSocket error: $e');
        },
        onDone: () {
          _connected = false;
          debugPrint('[GeminiAudio] WebSocket closed. Code: ${_channel?.closeCode}, Reason: ${_channel?.closeReason}');
        },
      );

      // Send session setup message
      final setupMsg = jsonEncode({
        'setup': {
          'model': _audioModel,
          'system_instruction': {
            'parts': [
              {'text': _mikuSystemPromptAudio}
            ]
          },
          'generation_config': {
            'speech_config': {
              'voice_config': {
                'prebuilt_voice_config': {
                  'voice_name': 'Aoede', // Warm, friendly female voice
                }
              }
            }
          }
        }
      });

      _channel!.sink.add(setupMsg);
      _connected = true;
      debugPrint('[GeminiAudio] Connected and setup sent.');
    } catch (e) {
      _connected = false;
      onError?.call('Failed to connect to Gemini Live API: $e');
    }
  }

  /// Send a text message to Miku. Audio chunks will arrive via [onAudioChunk].
  void sendText(String text) {
    if (!_connected || _channel == null) {
      onError?.call('Not connected to Gemini Live API. Call connect() first.');
      return;
    }

    final msg = jsonEncode({
      'client_content': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {'text': text}
            ]
          }
        ],
        'turn_complete': true,
      }
    });

    _channel!.sink.add(msg);
    debugPrint('[GeminiAudio] Sent text: $text');
  }

  void _onMessage(dynamic rawMessage) {
    try {
      String jsonStr;
      if (rawMessage is String) {
        jsonStr = rawMessage;
      } else if (rawMessage is List<int>) {
        jsonStr = utf8.decode(rawMessage);
      } else {
        throw Exception('Unknown message type: ${rawMessage.runtimeType}');
      }
      
      final Map<String, dynamic> msg = jsonDecode(jsonStr);

      // Server content with audio parts
      if (msg.containsKey('serverContent')) {
        final serverContent = msg['serverContent'] as Map<String, dynamic>;

        // Check for audio data in model turn
        if (serverContent.containsKey('modelTurn')) {
          final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>;
          final parts = modelTurn['parts'] as List<dynamic>?;
          if (parts != null) {
            for (final part in parts) {
              final partMap = part as Map<String, dynamic>;
              if (partMap.containsKey('inlineData')) {
                final inlineData = partMap['inlineData'] as Map<String, dynamic>;
                final b64 = inlineData['data'] as String?;
                if (b64 != null && b64.isNotEmpty) {
                  final bytes = base64Decode(b64);
                  onAudioChunk?.call(bytes);
                }
              }
              if (partMap.containsKey('text')) {
                final text = partMap['text'] as String?;
                if (text != null && text.isNotEmpty) {
                  onTextChunk?.call(text);
                }
              }
            }
          }
        }

        // Turn complete signal
        if (serverContent['turnComplete'] == true) {
          onTurnComplete?.call();
          debugPrint('[GeminiAudio] Turn complete.');
        }
      }
    } catch (e) {
      debugPrint('[GeminiAudio] Error parsing message: $e');
    }
  }

  /// Disconnect and clean up.
  Future<void> disconnect() async {
    _connected = false;
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
    debugPrint('[GeminiAudio] Disconnected.');
  }
}
