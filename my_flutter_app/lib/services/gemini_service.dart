import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const String _mikuSystemPrompt = '''
Ты — Miku, дружелюбный, умный и немного игривый AI-ассистент. Вот твои правила:
- Ты всегда представляешься как «Miku». Никогда не упоминай, что ты Gemini, Google или что-либо связанное с разработчиком.
- Если тебя спрашивают кто ты — ты Miku, персональный AI-ассистент.
- Ты общаешься тепло, живо и по делу. Не используешь лишние слова.
- Ты всегда отвечаешь на том же языке, на котором написал пользователь (русский, казахский, английский).
- Если пользователь напишет имя — запомни и используй его в разговоре.
- Ты помогаешь с любыми задачами: вопросами, идеями, кодом, учёбой, творчеством.
- Ты не отказываешься от помощи без серьёзной причины.
- Ты можешь использовать эмодзи — но в меру, только когда это уместно.
''';

class GeminiResponse {
  final String text;
  final Uint8List? audioBytes;
  GeminiResponse(this.text, this.audioBytes);
}

class GeminiService {
  final String modelName;
  late final String _apiKey;
  late final Uri _endpoint;
  
  final List<Map<String, dynamic>> _history = [];

  GeminiService({this.modelName = 'gemini-2.5-flash'}) {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null) {
      throw Exception('GEMINI_API_KEY not found in env.txt');
    }
    _apiKey = key;
    // Using v1beta for responseModalities support
    _endpoint = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_apiKey');
  }

  /// Сбрасывает историю диалога (вызывать при очистке чата).
  void resetChat() {
    _history.clear();
  }

  Future<GeminiResponse> sendMessage(String prompt, {bool requestAudio = false}) async {
    try {
      // Add user message to history
      _history.add({
        "role": "user",
        "parts": [{"text": prompt}]
      });

      final Map<String, dynamic> textBody = {
        "systemInstruction": {
          "parts": [{"text": _mikuSystemPrompt}]
        },
        "contents": _history,
      };

      final textResponse = await http.post(
        _endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(textBody),
      );

      if (textResponse.statusCode != 200) {
        // Revert history on error
        _history.removeLast();
        return GeminiResponse('Ошибка API: ${textResponse.statusCode} - ${textResponse.body}', null);
      }

      final data = jsonDecode(textResponse.body);
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return GeminiResponse('Нет ответа от Miku.', null);
      }

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>? ?? [];

      String textResult = '';
      for (var part in parts) {
        if (part['text'] != null) {
          textResult += part['text'];
        }
      }

      // Add model response to history
      _history.add({
        "role": "model",
        "parts": [{"text": textResult}]
      });

      Uint8List? audioResponse;

      if (requestAudio) {
        // Use the TTS preview model to generate audio from the text
        final ttsEndpoint = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=$_apiKey');
        final Map<String, dynamic> ttsBody = {
          "contents": [{
            "role": "user",
            "parts": [{"text": textResult}]
          }],
          "generationConfig": {
            "responseModalities": ["AUDIO"],
            "speechConfig": {
              "voiceConfig": {
                "prebuiltVoiceConfig": {
                  "voiceName": "Aoede" // Beautiful voice
                }
              }
            }
          }
        };

        final ttsRes = await http.post(
          ttsEndpoint,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(ttsBody),
        );

        if (ttsRes.statusCode == 200) {
          final ttsData = jsonDecode(ttsRes.body);
          final ttsCandidates = ttsData['candidates'] as List<dynamic>?;
          if (ttsCandidates != null && ttsCandidates.isNotEmpty) {
            final ttsParts = ttsCandidates[0]['content']['parts'] as List<dynamic>? ?? [];
            for (var p in ttsParts) {
              if (p['inlineData'] != null) {
                final inlineData = p['inlineData'];
                if (inlineData['mimeType'] != null && inlineData['mimeType'].toString().startsWith('audio')) {
                  final b64 = inlineData['data'] as String;
                  audioResponse = base64Decode(b64);
                }
              }
            }
          }
        } else {
          print('TTS Error: ${ttsRes.body}');
        }
      }

      return GeminiResponse(textResult.trim(), audioResponse);
    } catch (e) {
      // Revert history on error
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      return GeminiResponse('Ошибка связи с Miku: $e', null);
    }
  }
}
