import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:math' as math;
import '../theme/theme_constants.dart';

class MessageBubble extends StatefulWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.isError = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.isError) _shakeCtrl.forward();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
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
          child: Container(
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
                      : Colors.black.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
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
