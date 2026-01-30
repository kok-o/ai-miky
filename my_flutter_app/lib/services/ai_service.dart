import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static DateTime? _lastRequestTime;
  static const int _minDelayMs = 1000;

  Future<String> sendMessage(String message, {required String model}) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey.contains('YOUR_API_KEY')) {
      return "⚠️ API ключ не настроен. Пожалуйста, добавьте его в .env файл.";
    }

    // Проверяем задержку между запросами
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest.inMilliseconds < _minDelayMs) {
        final delayMs = _minDelayMs - timeSinceLastRequest.inMilliseconds;
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    _lastRequestTime = DateTime.now();

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": model,
      "messages": [
        {"role": "user", "content": message}
      ],
      "max_tokens": 500, // Ограничиваем длину ответа
    });

    try {
      print('Calling OpenAI API with model: $model');
      final response = await http.post(url, headers: headers, body: body);
      print('OpenAI API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else if (response.statusCode == 429) {
        print('Rate limit error: ${response.body}');
        return "⚠️ Превышен лимит запросов. Пожалуйста, подождите немного и попробуйте снова.";
      } else if (response.statusCode == 401) {
        print('Auth error: ${response.body}');
        return "❌ Ошибка авторизации. Проверьте API ключ.";
      } else if (response.statusCode == 403) {
        print('Forbidden error: ${response.body}');
        return "🚫 Доступ запрещен. Проверьте права доступа к API.";
      } else if (response.statusCode == 500) {
        print('Server error: ${response.body}');
        return "🔧 Временная ошибка сервера. Попробуйте позже.";
      } else {
        print('API Error ${response.statusCode}: ${response.body}');
        return "❌ Ошибка ${response.statusCode}: ${response.body}";
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        return "🌐 Ошибка сети. Проверьте подключение к интернету.";
      } else if (e.toString().contains('HttpException')) {
        return "🔌 Ошибка HTTP соединения.";
      } else if (e.toString().contains('FormatException') || 
                 e.toString().contains('Invalid argument')) {
        return "📝 Ошибка формата данных.";
      }
      return "❌ Неожиданная ошибка: $e";
    }
  }
}
