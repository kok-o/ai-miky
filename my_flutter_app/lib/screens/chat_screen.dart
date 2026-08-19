import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../services/gemini_service.dart';
import '../services/gemini_audio_service.dart';
import '../services/ollama_service.dart';
import '../services/firestore_service.dart';
import '../services/voice_service.dart';
import '../models/message.dart';
import '../state/app_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/logo_01.dart';
import '../widgets/blurred_circle.dart';
import '../theme/theme_constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();
  final VoiceService _voiceService = VoiceService();

  // Persistent Gemini service — keeps ChatSession alive between messages
  late final GeminiService _geminiService;
  
  GeminiAudioService? _audioService;
  final List<int> _audioChunkBuffer = [];
  String _streamingText = '';
  bool _isStreaming = false;

  bool _isTyping = false;
  bool _showScrollButton = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  int _prevMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _voiceService.initStt();
    _voiceService.initTts();
    // Initialize persistent GeminiService with the current model
    final appState = context.read<AppState>();
    _geminiService = GeminiService(
      modelName: appState.selectedModel,
      languageCode: appState.locale.languageCode,
    );
    _initAudioServiceIfNeeded();
  }

  Future<void> _initAudioServiceIfNeeded() async {
    final appState = context.read<AppState>();
    if (appState.selectedModel == 'gemini-2.5-flash' && appState.voiceEnabled) {
      if (_audioService == null) {
        _audioService = GeminiAudioService(languageCode: appState.locale.languageCode);
        _audioService!.onAudioChunk = (bytes) {
          _audioChunkBuffer.addAll(bytes);
        };
        _audioService!.onTextChunk = (text) {
          if (mounted) {
            setState(() {
              _streamingText += text;
            });
            _scrollToBottom();
          }
        };
        _audioService!.onTurnComplete = () async {
          final appState = context.read<AppState>();
          final user = appState.currentUser;
          if (user != null) {
            String placeholder = '🎤 (Voice response)';
            if (appState.locale.languageCode == 'ru') placeholder = '🎤 (Голосовой ответ)';
            if (appState.locale.languageCode == 'kk') placeholder = '🎤 (Дауыстық жауап)';
            final textToSave = _streamingText.isNotEmpty ? cleanAiResponse(_streamingText) : placeholder;
            final aiMessage = Message(text: textToSave, isUser: false);
            await _firestoreService.saveMessage(user.uid, aiMessage);
          }
          if (mounted) {
            setState(() {
              _isStreaming = false;
              _isTyping = false;
            });
            _inputFocus.requestFocus();
          }
          if (_audioChunkBuffer.isNotEmpty) {
            final bytes = Uint8List.fromList(_audioChunkBuffer);
            _audioChunkBuffer.clear();
            if (mounted) setState(() => _isSpeaking = true);
            await _voiceService.playPcmBytes(bytes);
            if (mounted) setState(() => _isSpeaking = false);
          }
          _streamingText = '';
        };
        _audioService!.onError = (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Audio Error: $error')));
            setState(() {
              _isStreaming = false;
              _isTyping = false;
            });
          }
        };
        await _audioService!.connect();
      } else if (!_audioService!.isConnected) {
        await _audioService!.connect();
      }
    }
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showScrollButton) {
      setState(() => _showScrollButton = true);
    } else if (_scrollController.offset <= 200 && _showScrollButton) {
      setState(() => _showScrollButton = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    final appState = context.read<AppState>();
    final user = appState.currentUser;
    if (user == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.pleaseLogin)),
      );
      return;
    }

    // Sync language code, model name & user context in case it changed
    _geminiService.languageCode = appState.locale.languageCode;
    _geminiService.modelName = appState.cleanModelName;
    _geminiService.userName = appState.displayName.isNotEmpty
        ? appState.displayName
        : (user.email?.split('@').first ?? '');
    _geminiService.userBio = appState.bio;

    _controller.clear();
    setState(() => _isTyping = true);
    _scrollToBottom();

    // Save User Message
    final message = Message(text: userMessage, isUser: true);
    await _firestoreService.saveMessage(user.uid, message);

    final voiceEnabled = appState.voiceEnabled;

    // Get AI Response
    String responseText;
    Uint8List? audioBytes;

    try {
      if (appState.isOllamaModel) {
        final ollamaService = OllamaService(baseUrl: appState.ollamaBaseUrl);
        responseText = await ollamaService.sendMessage(userMessage, model: appState.cleanModelName);
      } else {
        responseText = await _geminiService.sendMessage(userMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    if (responseText.contains('Connection refused') ||
        responseText.contains('Error communicating with Ollama') ||
        responseText.startsWith('Ollama Error')) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ollamaConnectionError),
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    final cleanText = cleanAiResponse(responseText);

    // If Voice is ON: wait for speech synthesis synchronization before starting playback & typewriter
    if (voiceEnabled && cleanText.isNotEmpty && !cleanText.startsWith('Ошибка')) {
      if (!appState.isOllamaModel) {
        audioBytes = await _geminiService.synthesizeSpeech(cleanText);
      }

      final words = cleanText.split(' ');
      Duration wordDelay = const Duration(milliseconds: 55);
      if (audioBytes != null && words.isNotEmpty) {
        final audioMs = (audioBytes.length / 48).round();
        final delayMs = ((audioMs * 0.85) / words.length).clamp(30.0, 90.0).round();
        wordDelay = Duration(milliseconds: delayMs);
      }

      await _streamTypewriter(
        cleanText,
        wordDelay: wordDelay,
        audioBytes: audioBytes,
        localeCode: audioBytes == null ? appState.locale.languageCode : null,
      );
    } else {
      // Voice is OFF: instant fast typewriter effect (18ms per word)
      await _streamTypewriter(
        cleanText,
        wordDelay: const Duration(milliseconds: 18),
      );
    }
  }

  /// Эффект плавной печати текста с синхронизацией с голосом
  Future<void> _streamTypewriter(
    String fullText, {
    required Duration wordDelay,
    Uint8List? audioBytes,
    String? localeCode,
  }) async {
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _isStreaming = true;
      _streamingText = '';
    });
    _scrollToBottom();

    // Если есть аудио, начинаем воспроизведение синхронно с началом печати
    if (audioBytes != null) {
      setState(() => _isSpeaking = true);
      _voiceService.playPcmBytes(audioBytes).then((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    } else if (localeCode != null) {
      setState(() => _isSpeaking = true);
      _voiceService.speak(fullText, languageCode: localeCode).then((_) {
        if (mounted) setState(() => _isSpeaking = false);
      });
    }

    final words = fullText.split(' ');
    for (int i = 0; i < words.length; i++) {
      if (!mounted || !_isStreaming) break;
      final part = (i == 0) ? words[i] : ' ${words[i]}';
      setState(() {
        _streamingText += part;
      });
      _scrollToBottom();
      await Future.delayed(wordDelay);
    }

    if (!mounted) return;

    // Сохраняем финальное сообщение в Firestore после окончания печати
    final user = context.read<AppState>().currentUser;
    if (user != null) {
      final aiMessage = Message(text: fullText, isUser: false);
      await _firestoreService.saveMessage(user.uid, aiMessage);
    }

    if (mounted) {
      setState(() {
        _isStreaming = false;
        _streamingText = '';
      });
    }
  }

  void _clearChat() async {
    final user = context.read<AppState>().currentUser;
    if (user != null) {
      await _firestoreService.clearChat(user.uid);
    }
    // Reset Miku's memory when the user clears the chat
    _geminiService.resetChat();
  }

  void _handleSuggestion(String prompt, {bool autoSend = false}) {
    _controller.text = prompt;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    if (autoSend) {
      _sendMessage();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _inputFocus.canRequestFocus) {
          _inputFocus.requestFocus();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
         return Center(child: Text(l10n.errorAuth));
    }

    final pendingPrompt = appState.consumePendingPrompt();
    if (pendingPrompt != null && pendingPrompt.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleSuggestion('$pendingPrompt ', autoSend: false);
        }
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      // Minimal Vercel-style app bar with spacious header
      appBar: AppBar(
        toolbarHeight: 68,
        title: Logo01(size: 36, text: l10n.chatTitle, heroTag: null),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(Icons.delete_sweep_rounded, size: 22),
            tooltip: l10n.clearChat,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [],
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            if (isDark) const DarkBackground(),
            Column(
              children: [
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _firestoreService.getMessages(user.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                       return Center(child: Text('${l10n.error}: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: isDark ? ThemeConstants.kBrandCyan : null,
                          strokeWidth: 2.5,
                        ),
                      );
                    }
                    final messages = snapshot.data!;
                    if (messages.isEmpty) {
                      return _EmptyState(
                        onSelectSuggestion: (prompt, {autoSend = false}) =>
                            _handleSuggestion(prompt, autoSend: autoSend),
                      );
                    }

                    if (messages.length > _prevMessageCount) {
                      _prevMessageCount = messages.length;
                      _scrollToBottom();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                          top: 8, bottom: 16, left: 4, right: 4),
                      itemCount: messages.length + (_isStreaming ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return MessageBubble(
                              text: _streamingText.isNotEmpty ? _streamingText : '▋',
                              isUser: false,
                              isStreaming: true,
                              isError: false);
                        }
                        final msg = messages[index];
                        final isError = msg.text.contains('❌') ||
                            msg.text.contains('⚠️');
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: ThemeConstants.kDurationMed,
                          curve: Curves.easeOutCubic,
                          builder: (context, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 16 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: MessageBubble(
                              text: msg.text,
                              isUser: msg.isUser,
                              isError: isError),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_isTyping) _TypingIndicator(),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? ThemeConstants.kDark0.withValues(alpha: 0.92)
                      : ThemeConstants.kLight0.withValues(alpha: 0.95),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? ThemeConstants.kDarkBorder
                          : ThemeConstants.kLightBorder,
                    ),
                  ),
                ),
                child: _InputBar(
                controller: _controller,
                focusNode: _inputFocus,
                onSend: _sendMessage,
                onVoice: _startVoiceInput,
                enabled: !_isTyping,
                isListening: _isListening,
                isSpeaking: _isSpeaking,
                onStopSpeaking: () async {
                  await _voiceService.stop();
                  setState(() => _isSpeaking = false);
                },
              ),
              ),
            ],
          ),
          if (_showScrollButton)
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                backgroundColor: ThemeConstants.kAccentBlue,
                foregroundColor: Colors.white,
                child: const Icon(Icons.arrow_downward_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    _voiceService.stop();
    super.dispose();
  }

  void _startVoiceInput() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
      return;
    }

    // Stop TTS if speaking
    if (_isSpeaking) {
      await _voiceService.stop();
      setState(() => _isSpeaking = false);
    }

    final locale = context.read<AppState>().locale.languageCode;
    setState(() => _isListening = true);

    final started = await _voiceService.startListening(
      onResult: (text) {
        if (text.isNotEmpty) {
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: text.length),
          );
        }
      },
      onDone: () {
        setState(() => _isListening = false);
        if (_controller.text.trim().isNotEmpty) {
          _sendMessage();
        }
      },
      languageCode: locale,
    );

    if (!started) {
      setState(() => _isListening = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Микрофон недоступен. Проверьте разрешения.')),
        );
      }
    }
  }


}

class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onVoice,
    required this.enabled,
    required this.isListening,
    required this.isSpeaking,
    required this.onStopSpeaking,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final bool enabled;
  final bool isListening;
  final bool isSpeaking;
  final VoidCallback onStopSpeaking;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late AnimationController _micPulseCtrl;

  @override
  void initState() {
    super.initState();
    _micPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isListening) _micPulseCtrl.repeat(reverse: true);
    
    widget.focusNode.addListener(() {
      setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(_InputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _micPulseCtrl.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _micPulseCtrl.stop();
      _micPulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _micPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;
    const focusBorderColor = ThemeConstants.kAccentBlue;
    return AnimatedContainer(
      duration: ThemeConstants.kDurationMed,
      curve: ThemeConstants.kCurveStandard,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? ThemeConstants.kDark1 : ThemeConstants.kLight1,
        borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
        border: Border.all(
          color: _isFocused
              ? focusBorderColor.withValues(alpha: 0.8)
              : (isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: focusBorderColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    !HardwareKeyboard.instance.isShiftPressed) {
                  if (widget.enabled &&
                      !widget.isListening &&
                      widget.controller.text.trim().isNotEmpty) {
                    widget.onSend();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  if (widget.enabled &&
                      !widget.isListening &&
                      widget.controller.text.trim().isNotEmpty) {
                    widget.onSend();
                  }
                },
                style: TextStyle(
                  color: isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  filled: false,
                  hintText: l10n.askSomething,
                  hintStyle: TextStyle(
                    color: isDark ? ThemeConstants.kTextTertiary : const Color(0xFFAAAAAA),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                maxLines: null,
              ),
            ),
          ),
          if (widget.isSpeaking)
            AnimatedScale(
              scale: 1.0,
              duration: ThemeConstants.kDurationFast,
              child: IconButton.filled(
                onPressed: widget.onStopSpeaking,
                icon: const Icon(Icons.stop_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ),
          if (!widget.isSpeaking)
            AnimatedBuilder(
              animation: _micPulseCtrl,
              builder: (context, child) {
                final scale = widget.enabled ? (widget.isListening ? 1.05 + (_micPulseCtrl.value * 0.15) : 1.0) : 0.85;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: widget.isListening ? [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.3 + (_micPulseCtrl.value * 0.4)),
                          blurRadius: 10 + (_micPulseCtrl.value * 15),
                          spreadRadius: _micPulseCtrl.value * 4,
                        )
                      ] : [],
                    ),
                    child: child,
                  ),
                );
              },
              child: IconButton.filled(
                onPressed: widget.enabled ? widget.onVoice : null,
                icon: Icon(widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: widget.isListening
                      ? const Color(0xFFEF4444)
                      : (isDark ? ThemeConstants.kDark2 : ThemeConstants.kLight0),
                  foregroundColor: widget.isListening
                      ? Colors.white
                      : (isDark ? ThemeConstants.kTextSecondary : ThemeConstants.kTextSecondaryLight),
                  padding: const EdgeInsets.all(10),
                ),
              ),
            ),
          const SizedBox(width: 4),
          AnimatedScale(
            scale: widget.enabled && !widget.isListening ? 1.0 : 0.85,
            duration: ThemeConstants.kDurationFast,
            child: IconButton.filled(
              onPressed: (widget.enabled && !widget.isListening) ? widget.onSend : null,
              icon: const Icon(Icons.send_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: ThemeConstants.kAccentBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark ? ThemeConstants.kDark2 : ThemeConstants.kLight0,
                padding: const EdgeInsets.all(10),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final void Function(String prompt, {bool autoSend}) onSelectSuggestion;
  const _EmptyState({required this.onSelectSuggestion});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;
    final textColor   = isDark ? ThemeConstants.kTextPrimary   : ThemeConstants.kTextPrimaryLight;
    final mutedColor  = isDark ? ThemeConstants.kTextSecondary : ThemeConstants.kTextSecondaryLight;
    final borderColor = isDark ? ThemeConstants.kDarkBorder    : ThemeConstants.kLightBorder;
    final chipBg      = isDark ? ThemeConstants.kDark1         : ThemeConstants.kLight1;

    final suggestions = [
      (Icons.lightbulb_outline_rounded, l10n.suggestionQuantum,   l10n.suggestionQuantum,   true),
      (Icons.code_rounded,              l10n.suggestionDart,      l10n.promptCode,          false),
      (Icons.translate_rounded,         l10n.suggestionTranslate, l10n.promptTranslation,   false),
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Logo01(size: 48, showText: false, heroTag: null)
                .animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),

            const SizedBox(height: 20),

            // Headline
            Text(
              l10n.askSomething,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ).animate(delay: 60.ms).fadeIn(duration: 350.ms).slideY(begin: 0.06, end: 0, duration: 350.ms),

            const SizedBox(height: 8),

            Text(
              l10n.helloMiku,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: mutedColor,
                height: 1.5,
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

            const SizedBox(height: 28),

            // Suggestion chips — CTA for empty state
            ...suggestions.asMap().entries.map((entry) {
              final i = entry.key;
              final (icon, label, prompt, autoSend) = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onSelectSuggestion(prompt, autoSend: autoSend),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(icon, size: 16, color: mutedColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              color: mutedColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: mutedColor.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate(delay: (160 + i * 60).ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.06, end: 0, duration: 300.ms, curve: Curves.easeOut);
            }),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(3, (index) => _Dot(index: index)),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int index;
  const _Dot({required this.index});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _controller.reverse();
        if (status == AnimationStatus.dismissed) _controller.forward();
      });
    Future.delayed(Duration(milliseconds: widget.index * 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -3 * _controller.value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: ThemeConstants.kAccentBlue.withValues(
              alpha: 0.3 + (0.7 * _controller.value),
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
