import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/ai_service.dart';
import '../services/firestore_service.dart';
import '../models/message.dart';
import '../state/app_state.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isTyping = false;

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

    // Get AI Response
    final selectedModel = appState.selectedModel;
    final response = await _aiService.sendMessage(userMessage, model: selectedModel);

    // Save AI Message
    final aiMessage = Message(text: response, isUser: false);
    await _firestoreService.saveMessage(user.uid, aiMessage);

    setState(() => _isTyping = false);
    _scrollToBottom();
    _inputFocus.requestFocus();
  }

  void _clearChat() async {
    final user = context.read<AppState>().currentUser;
    if (user != null) {
      await _firestoreService.clearChat(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
         return Center(child: Text(l10n.errorAuth));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chatTitle),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _clearChat,
            icon: const Icon(Icons.clear_all),
            tooltip: l10n.clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _firestoreService.getMessages(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                   final l10n = AppLocalizations.of(context)!;
                   return Center(child: Text('${l10n.error}: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                
                // Auto-scroll on new messages if close to bottom (simplified)
                if (messages.isNotEmpty) {
                    // _scrollToBottom(); // Be careful with loops
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isError = msg.text.contains('❌') || 
                                   msg.text.contains('⚠️') || 
                                   msg.text.contains('🚫') || 
                                   msg.text.contains('🔧') ||
                                   msg.text.contains('🌐') ||
                                   msg.text.contains('🔌') ||
                                   msg.text.contains('📝');
                    
                    return MessageBubble(text: msg.text, isUser: msg.isUser, isError: isError);
                  },
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: _InputBar(
              controller: _controller,
              focusNode: _inputFocus,
              onSend: _sendMessage,
              enabled: !_isTyping,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
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

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                if (enabled)
                  const SingleActivator(LogicalKeyboardKey.enter): onSend,
                const SingleActivator(LogicalKeyboardKey.enter, shift: true): () {},
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: '...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) {},
                enabled: enabled,
              ),
            ),
          ),
          IconButton(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send_rounded),
            color: scheme.primary,
          ),
        ],
      ),
    );
  }
}
