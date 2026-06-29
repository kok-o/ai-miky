import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    _geminiService = GeminiService(modelName: appState.selectedModel);
    _initAudioServiceIfNeeded();
  }

  void _initAudioServiceIfNeeded() {
    final appState = context.read<AppState>();
    if (appState.selectedModel == 'gemini-2.5-flash' && appState.voiceEnabled) {
      if (_audioService == null) {
        _audioService = GeminiAudioService();
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
          final user = context.read<AppState>().currentUser;
          if (user != null && _streamingText.isNotEmpty) {
            final aiMessage = Message(text: _streamingText, isUser: false);
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
        _audioService!.connect();
      } else if (!_audioService!.isConnected) {
        _audioService!.connect();
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

  void _sendMessage() async {
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

    _controller.clear();
    setState(() => _isTyping = true);
    _scrollToBottom();

    // Save User Message
    final message = Message(text: userMessage, isUser: true);
    await _firestoreService.saveMessage(user.uid, message);

    final voiceEnabled = appState.voiceEnabled;
    
    // Check if we should use Native Audio Dialog (WebSockets)
    if (appState.selectedModel == 'gemini-2.5-flash' && voiceEnabled) {
      _initAudioServiceIfNeeded();
      if (_audioService != null) {
        setState(() {
          _isStreaming = true;
          _streamingText = '';
        });
        _audioChunkBuffer.clear();
        _audioService!.sendText(userMessage);
        return; // The rest is handled by onTurnComplete
      }
    }

    // Get AI Response for REST fallback
    String responseText;
    Uint8List? audioResponse;

    try {
      if (appState.isOllamaModel) {
        final ollamaService = OllamaService(baseUrl: appState.ollamaBaseUrl);
        responseText = await ollamaService.sendMessage(userMessage, model: appState.cleanModelName);
      } else {
        // Use persistent GeminiService (keeps Miku's memory of the conversation)
        final res = await _geminiService.sendMessage(userMessage, requestAudio: voiceEnabled);
        responseText = res.text;
        audioResponse = res.audioBytes;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTyping = false);
      _inputFocus.requestFocus();
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
      _inputFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.ollamaConnectionError),
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    // Save AI Message
    final aiMessage = Message(text: responseText, isUser: false);
    await _firestoreService.saveMessage(user.uid, aiMessage);

    setState(() => _isTyping = false);
    _inputFocus.requestFocus();

    // Auto-voice if voice enabled
    if (voiceEnabled) {
      final localeCode = context.read<AppState>().locale.languageCode;
      
      if (audioResponse != null) {
        // ✨ Use Gemini Native Audio (human-quality voice returned from REST)
        setState(() => _isSpeaking = true);
        await _voiceService.playPcmBytes(audioResponse);
        if (mounted) setState(() => _isSpeaking = false);
      } else {
        // Fallback: flutter_tts (for Ollama or if Gemini failed to generate audio)
        setState(() => _isSpeaking = true);
        await _voiceService.speak(responseText, languageCode: localeCode);
        if (mounted) setState(() => _isSpeaking = false);
      }
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    if (user == null) {
         return Center(child: Text(l10n.errorAuth));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar.large(
            expandedHeight: 110,
            backgroundColor: isDark ? ThemeConstants.kBrandDark : scheme.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Logo01(size: 38, text: l10n.chatTitle, heroTag: null),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            ThemeConstants.kBrandCyan.withValues(alpha: 0.08),
                            ThemeConstants.kBrandDark,
                          ]
                        : [
                            scheme.primaryContainer.withValues(alpha: 0.4),
                            scheme.surface,
                          ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _clearChat,
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: l10n.clearChat,
              ),
            ],
          ),
        ],
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
                    if (messages.isEmpty) return const _EmptyState();

                    if (messages.length > _prevMessageCount) {
                      _prevMessageCount = messages.length;
                      _scrollToBottom();
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                          top: 96, bottom: 16, left: 4, right: 4),
                      itemCount: messages.length + (_isStreaming ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return MessageBubble(
                              text: _streamingText,
                              isUser: false,
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : scheme.surface.withValues(alpha: 0.9),
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05),
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
                backgroundColor: ThemeConstants.kBrandCyan,
                foregroundColor: ThemeConstants.kBrandDark,
                child: const Icon(Icons.arrow_downward_rounded),
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

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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

class _InputBarState extends State<_InputBar> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _isFocused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;
    final focusBorderColor =
        isDark ? ThemeConstants.kBrandCyan : scheme.primary;
    return AnimatedContainer(
      duration: ThemeConstants.kDurationMed,
      curve: ThemeConstants.kCurveStandard,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isDark
            ? (_isFocused
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.04))
            : (_isFocused ? Colors.white : scheme.surfaceContainerHighest.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: _isFocused
              ? focusBorderColor.withValues(alpha: 0.8)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black12),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: focusBorderColor.withValues(alpha: isDark ? 0.18 : 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              style: TextStyle(
                color: isDark ? Colors.white : scheme.onSurface,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                filled: false,
                hintText: l10n.askSomething,
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : scheme.onSurface.withValues(alpha: 0.4),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              maxLines: null,
              enabled: widget.enabled,
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
            AnimatedScale(
              scale: widget.enabled ? (widget.isListening ? 1.15 : 1.0) : 0.85,
              duration: ThemeConstants.kDurationFast,
              child: IconButton.filled(
                onPressed: widget.enabled ? widget.onVoice : null,
                icon: Icon(widget.isListening ? Icons.mic_rounded : Icons.mic_none_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: widget.isListening 
                      ? Colors.redAccent 
                      : (isDark ? Colors.white.withValues(alpha: 0.1) : scheme.surfaceContainerHighest),
                  foregroundColor: widget.isListening 
                      ? Colors.white 
                      : (isDark ? Colors.white70 : scheme.onSurfaceVariant),
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
                backgroundColor: isDark
                    ? ThemeConstants.kBrandCyan
                    : scheme.primary,
                foregroundColor: isDark ? ThemeConstants.kBrandDark : scheme.onPrimary,
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
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final l10n   = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Logo01(size: 80, showText: false, heroTag: null),
          const SizedBox(height: 28),
          Text(
            l10n.askSomething,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : scheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.helloMiku,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.45)
                  : scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
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
      builder: (context, child) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? ThemeConstants.kBrandCyan
                  .withValues(alpha: 0.25 + (0.75 * _controller.value))
              : Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.3 + (0.7 * _controller.value)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
