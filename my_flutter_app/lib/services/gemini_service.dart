import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService({String modelName = 'gemini-3.0-flash'}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }
    
    // Explicitly using v1 API which is more stable for production models
    _model = GenerativeModel(
      model: modelName, 
      apiKey: apiKey,
      requestOptions: const RequestOptions(apiVersion: 'v1'),
    );
  }

  Future<String> sendMessage(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response from Gemini.';
    } catch (e) {
      return 'Error communicating with Gemini: $e';
    }
  }
}
