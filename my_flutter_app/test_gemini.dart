import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final envFile = File('env.txt');
  final envContent = await envFile.readAsString();
  final apiKey = envContent.split('=').last.trim();
  
  for (var model in ['gemini-3.1-flash-lite', 'gemini-3.5-flash-lite', 'gemini-3.1-flash-lite-preview']) {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');
    final body = {
      "contents": [{
        "role": "user",
        "parts": [{"text": "Привет! Назови свою модель и поздоровайся."}]
      }]
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body)
      );

      print('Model: $model -> Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final parts = data['candidates'][0]['content']['parts'];
        print('Response: ${parts[0]['text']}');
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception for $model: $e');
    }
  }
}
