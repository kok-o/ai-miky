import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Strips internal thoughts, reasoning blocks, and think tags from AI output.
String cleanAiResponse(String raw) {
  var text = raw;

  // 1. Remove XML/HTML thought tags: <thought>...</thought>, <think>...</think>
  text = text.replaceAll(RegExp(r'<thought>[\s\S]*?</thought>', caseSensitive: false), '');
  text = text.replaceAll(RegExp(r'<think>[\s\S]*?</think>', caseSensitive: false), '');

  // 2. Remove markdown code blocks tagged as thought/think: ```thought ... ```
  text = text.replaceAll(RegExp(r'```(?:thought|think|reasoning)[\s\S]*?```', caseSensitive: false), '');

  // 3. Remove "Crafting a Response" or "Thinking Process" blocks
  text = text.replaceAll(RegExp(r'^(?:#+\s*)?Crafting a Response[\s\S]*?(?=\n\n|\n[A-ZА-ЯЁ0-9]|$)', caseSensitive: false), '');
  text = text.replaceAll(RegExp(r'^(?:#+\s*)?(?:Thinking Process|Internal Thoughts|Chain of Thought):?[\s\S]*?(?=\n\n|\n[A-ZА-ЯЁ0-9]|$)', caseSensitive: false), '');

  text = text.trim();
  return text.isNotEmpty ? text : raw.trim();
}

class GeminiResponse {
  final String text;
  final Uint8List? audioBytes;
  GeminiResponse(this.text, this.audioBytes);
}

class GeminiService {
  String modelName;
  String languageCode;
  String? userName;
  String? userBio;
  late final String _apiKey;
  
  final List<Map<String, dynamic>> _history = [];

  String get _mikuSystemPrompt {
    final lang = languageCode == 'en' ? 'English' : languageCode == 'kk' ? 'Kazakh' : 'Russian';
    final userContext = (userName != null && userName!.trim().isNotEmpty)
        ? 'Пользователя зовут $userName. Обращайся к нему по имени и помни, с кем ты общаешься.'
        : 'Если пользователь назовёт своё имя, обязательно запомни его и обращайся по имени.';
    final bioContext = (userBio != null && userBio!.trim().isNotEmpty)
        ? ' Информация о пользователе: $userBio.'
        : '';

    return '''
Ты — Miku, дружелюбный, умный и живой персональный AI-ассистент.
Контекст собеседника: $userContext$bioContext
Твои строгие правила:
- Ты всегда представляешься как «Miku». Никогда не упоминай Gemini, Google или разработчиков.
- Всегда отвечай только на языке: $lang.
- СРАЗУ пиши готовый, прямой ответ пользователю.
- КАТЕГОРИЧЕСКИ ЗАПРЕЩЕНО выводить свои внутренние мысли, планы, черновики, рассуждения вслух или заголовки вроде "Crafting a Response", "Thinking Process", "Thought:". Выводи только то, что адресовано напрямую собеседнику.
- Общайся тепло, естественно, живо и по делу.
- Ты помогаешь с любыми вопросами: общением, кодом, учёбой, творчеством, переводом, анализом.
''';
  }

  GeminiService({this.modelName = 'gemini-3.1-flash-lite', this.languageCode = 'ru'}) {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null) {
      throw Exception('GEMINI_API_KEY not found in env.txt');
    }
    _apiKey = key;
  }

  Uri get _endpoint {
    final effectiveModel = (modelName.isEmpty || modelName == 'gemini-1.5-flash')
        ? 'gemini-3.1-flash-lite'
        : modelName;
    return Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$effectiveModel:generateContent?key=$_apiKey');
  }

  /// Сбрасывает историю диалога (вызывать при очистке чата).
  void resetChat() {
    _history.clear();
  }

  Future<String> sendMessage(String prompt) async {
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
        "generationConfig": {
          "temperature": 0.7,
        },
      };

      final textResponse = await http.post(
        _endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(textBody),
      );

      if (textResponse.statusCode != 200) {
        // Revert history on error
        _history.removeLast();
        return 'Ошибка API: ${textResponse.statusCode} - ${textResponse.body}';
      }

      final data = jsonDecode(utf8.decode(textResponse.bodyBytes));
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return 'Нет ответа от Miku.';
      }

      final content = candidates[0]['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>? ?? [];

      String textResult = '';
      for (var part in parts) {
        if (part is Map<String, dynamic>) {
          // Skip internal thinking parts
          if (part['thought'] == true) {
            continue;
          }
          if (part['text'] != null) {
            textResult += part['text'] as String;
          }
        }
      }

      textResult = cleanAiResponse(textResult).trim();

      // Add model response to history
      _history.add({
        "role": "model",
        "parts": [{"text": textResult}]
      });

      return textResult;
    } catch (e) {
      // Revert history on error
      if (_history.isNotEmpty && _history.last['role'] == 'user') {
        _history.removeLast();
      }
      return 'Ошибка связи с Miku: $e';
    }
  }

  /// Асинхронный синтез речи в фоне (не блокирует вывод текста в чат)
  Future<Uint8List?> synthesizeSpeech(String text) async {
    if (text.isEmpty) return null;
    try {
      final cleanForSpeech = text.replaceAll(RegExp(r'[*_#`~]'), '').trim();
      final sample = cleanForSpeech.length > 500 ? cleanForSpeech.substring(0, 500) : cleanForSpeech;

      final ttsEndpoint = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=$_apiKey');
      final Map<String, dynamic> ttsBody = {
        "contents": [{
          "role": "user",
          "parts": [{"text": sample}]
        }],
        "generationConfig": {
          "responseModalities": ["AUDIO"],
          "speechConfig": {
            "voiceConfig": {
              "prebuiltVoiceConfig": {
                "voiceName": "Aoede"
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
                return base64Decode(b64);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('TTS synthesis error: $e');
    }
    return null;
  }
}
