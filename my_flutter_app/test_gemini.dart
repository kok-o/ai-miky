import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final envFile = File('env.txt');
  final envContent = await envFile.readAsString();
  final apiKey = envContent.split('=').last.trim();
  
  final model = 'gemini-2.5-flash-preview-native-audio-dialog';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey');
  
  final body = {
    "contents": [{
      "role": "user",
      "parts": [{"text": "Hello, say one word."}]
    }],
    "generationConfig": {
      "responseModalities": ["TEXT", "AUDIO"],
      "speechConfig": {
        "voiceConfig": {
          "prebuiltVoiceConfig": {
            "voiceName": "Aoede"
          }
        }
      }
    }
  };

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body)
  );

  print('Status: ${response.statusCode}');
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final parts = data['candidates'][0]['content']['parts'];
    for (var p in parts) {
      if (p['text'] != null) {
        print('TEXT: ${p['text']}');
      } else {
        print('HAS AUDIO PART');
      }
    }
  } else {
    print('ERROR: ${response.body}');
  }
}
