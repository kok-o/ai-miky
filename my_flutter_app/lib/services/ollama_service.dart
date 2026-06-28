import 'dart:convert';
import 'package:http/http.dart' as http;

class OllamaService {
  final String baseUrl;

  OllamaService({this.baseUrl = 'http://localhost:11434'});

  Future<String> sendMessage(String prompt, {required String model}) async {
    final url = Uri.parse('$baseUrl/api/generate');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['response'] ?? 'No response from Ollama.';
      } else {
        return 'Ollama Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      return 'Error communicating with Ollama: $e';
    }
  }
}
