import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
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
      duration: const Duration(milliseconds: 1000),
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
    final Border? border;
    
    if (widget.isError) {
      bg        = scheme.errorContainer;
      textColor = scheme.onErrorContainer;
      border    = null;
    } else if (widget.isUser) {
      bg        = isDark ? Colors.white : Colors.black;
      textColor = isDark ? Colors.black : Colors.white;
      border    = null;
    } else {
      bg        = Colors.transparent;
      textColor = isDark ? Colors.white : Colors.black;
      border    = Border.all(
        color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.12),
        width: 1,
      );
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
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg,
                    border: border,
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(12),
                      topRight:    const Radius.circular(12),
                      bottomLeft:  Radius.circular(widget.isUser ? 12 : 4),
                      bottomRight: Radius.circular(widget.isUser ? 4 : 12),
                    ),
                    // Minimalist Vercel shadow only for streaming state
                    boxShadow: widget.isStreaming 
                        ? [
                            BoxShadow(
                              color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05 + (_pulseCtrl.value * 0.05)),
                              blurRadius: 8 + (_pulseCtrl.value * 4),
                              spreadRadius: _pulseCtrl.value * 2,
                            )
                          ]
                        : [],
                  ),
                  child: child,
                );
              },
              child: widget.isUser || widget.isError
                  ? Text(
                    widget.text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: textColor,
                      height: 1.5,
                      fontWeight:
                          widget.isUser ? FontWeight.w500 : FontWeight.normal,
                    ),
                  )
                : MarkdownBody(
                    data: widget.text,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.inter(
                        fontSize: 15,
                        color: textColor,
                        height: 1.5,
                      ),
                      strong: GoogleFonts.inter(
                        fontSize: 15,
                        color: textColor,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                      listBullet: GoogleFonts.inter(
                        fontSize: 15,
                        color: textColor,
                        height: 1.5,
                      ),
                      code: GoogleFonts.firaCode(
                        fontSize: 13,
                        backgroundColor: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      codeblockPadding: const EdgeInsets.all(12),
                      codeblockDecoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
