import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:math' as math;
import '../theme/theme_constants.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final bool isError;
  final bool isStreaming;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isError = false,
    this.isStreaming = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isError) _shakeCtrl.forward();
    if (widget.isStreaming) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !oldWidget.isStreaming) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isStreaming && oldWidget.isStreaming) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    // Colors
    final Color bg;
    final Color textColor;
    if (widget.isError) {
      bg        = scheme.errorContainer;
      textColor = scheme.onErrorContainer;
    } else if (widget.isUser) {
      bg        = isDark ? ThemeConstants.kBrandCyan : scheme.primary;
      textColor = isDark ? ThemeConstants.kBrandDark : scheme.onPrimary;
    } else {
      bg        = isDark
          ? Colors.white.withValues(alpha: 0.07)
          : scheme.surfaceContainerHighest;
      textColor = isDark ? Colors.white.withValues(alpha: 0.9) : scheme.onSurface;
    }

    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, child) {
        final dx =
            math.sin(_shakeCtrl.value * math.pi * 5) * 5 * (1 - _shakeCtrl.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Align(
        alignment:
            widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(20),
                      topRight:    const Radius.circular(20),
                      bottomLeft:  Radius.circular(widget.isUser ? 20 : 5),
                      bottomRight: Radius.circular(widget.isUser ? 5 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isUser && isDark
                            ? ThemeConstants.kBrandCyan.withValues(alpha: 0.15)
                            : (widget.isStreaming 
                                ? ThemeConstants.kBrandCyan.withValues(alpha: 0.2 + (_pulseCtrl.value * 0.4))
                                : Colors.black.withValues(alpha: 0.07)),
                        blurRadius: widget.isStreaming ? 12 + (_pulseCtrl.value * 12) : 12,
                        spreadRadius: widget.isStreaming ? (_pulseCtrl.value * 2) : 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: widget.isUser || widget.isError
                  ? Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: textColor,
                      height: 1.45,
                      fontWeight:
                          widget.isUser ? FontWeight.w500 : FontWeight.normal,
                    ),
                  )
                : MarkdownBody(
                    data: widget.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.45,
                      ),
                      strong: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.45,
                        fontWeight: FontWeight.bold,
                      ),
                      listBullet: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.45,
                      ),
                      // Markdown uses default scaling, but we lock the sizes to match the user text
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
