import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  final apiKey = 'YOUR_API_KEY_HERE';
  print('Testing Gemini API key...');
  
  try {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
    
    final content = [Content.text('Hello! Say exactly "ok" if you receive this.')];
    final response = await model.generateContent(content);
    
    print('Response: ${response.text}');
  } catch (e) {
    print('Error: $e');
  }
}
