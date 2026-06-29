import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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

class GeminiService {
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  GeminiService({String modelName = 'gemini-2.5-flash'}) {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in env.txt');
    }

    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(_mikuSystemPrompt),
      requestOptions: const RequestOptions(apiVersion: 'v1beta'),
    );

    _startNewSession();
  }

  void _startNewSession({String? userName}) {
    final history = <Content>[];
    _chatSession = _model.startChat(history: history);
  }

  /// Сбрасывает историю диалога (вызывать при очистке чата).
  void resetChat() {
    _startNewSession();
  }

  Future<String> sendMessage(String prompt) async {
    try {
      _chatSession ??= _model.startChat();
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      return response.text ?? 'Нет ответа от Miku.';
    } catch (e) {
      return 'Ошибка связи с Miku: $e';
    }
  }
}
