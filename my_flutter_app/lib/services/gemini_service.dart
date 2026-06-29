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

      final Map<String, dynamic> body = {
        "systemInstruction": {
          "parts": [{"text": _mikuSystemPrompt}]
        },
        "contents": _history,
        "generationConfig": {
          if (requestAudio) "responseModalities": ["TEXT", "AUDIO"],
          if (requestAudio) "speechConfig": {
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Aoede" // Beautiful voice
              }
            }
          }
        }
      };

      final response = await http.post(
        _endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        // Revert history on error
        _history.removeLast();
        return GeminiResponse('Ошибка API: ${response.statusCode} - ${response.body}', null);
      }

      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return GeminiResponse('Нет ответа от Miku.', null);
      }

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>? ?? [];

      String textResponse = '';
      Uint8List? audioResponse;

      for (var part in parts) {
        if (part['text'] != null) {
          textResponse += part['text'];
        }
        if (part['inlineData'] != null) {
          final inlineData = part['inlineData'];
          if (inlineData['mimeType'] != null && inlineData['mimeType'].toString().startsWith('audio')) {
            final b64 = inlineData['data'] as String;
            audioResponse = base64Decode(b64);
          }
        }
      }

      // Add model response to history
      _history.add({
        "role": "model",
        "parts": [{"text": textResponse}]
      });

      return GeminiResponse(textResponse.trim(), audioResponse);
    } catch (e) {
      // Revert history on error
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      return GeminiResponse('Ошибка связи с Miku: $e', null);
    }
  }
}
