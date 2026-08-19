import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../theme/theme_constants.dart';

/// Vercel/Linear-inspired message bubbles.
///
/// Design decisions:
/// - User messages: pill-shaped, filled with brand color, right-aligned
/// - AI messages: NO bubble — flat text with left border accent (like Linear/Notion)
/// - Code blocks: JetBrains Mono (T1 fix — mono for technical content)
/// - Error state: red left border, not red background (avoids C9 generic red)
/// - Streaming state: subtle animated left border pulse on AI messages
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
  late AnimationController _streamCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _streamCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isError)    _shakeCtrl.forward();
    if (widget.isStreaming) _streamCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && !oldWidget.isStreaming) {
      _streamCtrl.repeat(reverse: true);
    } else if (!widget.isStreaming && oldWidget.isStreaming) {
      _streamCtrl.stop();
      _streamCtrl.reset();
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _streamCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shakeCtrl,
      builder: (context, child) {
        // Shake for errors
        final dx = math.sin(_shakeCtrl.value * math.pi * 5) * 4 * (1 - _shakeCtrl.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.isUser
          ? _UserBubble(text: widget.text, isDark: isDark)
          : _AiBubble(
              text: widget.text,
              isError: widget.isError,
              isStreaming: widget.isStreaming,
              streamCtrl: _streamCtrl,
              isDark: isDark,
            ),
    );
  }
}

/// User message — pill-shaped, right-aligned, filled
class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text, required this.isDark});
  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg        = isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight;
    final textColor = isDark ? ThemeConstants.kDark0 : Colors.white;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(18),
              topRight:    Radius.circular(18),
              bottomLeft:  Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: textColor,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.05, end: 0, duration: 200.ms, curve: Curves.easeOut);
  }
}

/// AI message — flat, left-aligned, with left border accent
class _AiBubble extends StatelessWidget {
  const _AiBubble({
    required this.text,
    required this.isError,
    required this.isStreaming,
    required this.streamCtrl,
    required this.isDark,
  });

  final String text;
  final bool isError;
  final bool isStreaming;
  final AnimationController streamCtrl;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? ThemeConstants.kTextPrimary : ThemeConstants.kTextPrimaryLight;
    final mutedColor = isDark ? ThemeConstants.kTextSecondary : ThemeConstants.kTextSecondaryLight;

    // Border color for left accent
    final Color borderColor;
    if (isError) {
      borderColor = const Color(0xFFEF4444); // red — semantic error (C9: accessible variant)
    } else if (isStreaming) {
      borderColor = ThemeConstants.kAccentBlue;
    } else {
      borderColor = isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.90,
        ),
        child: AnimatedBuilder(
          animation: streamCtrl,
          builder: (context, child) {
            // Streaming: blue border pulses in opacity
            final borderOpacity = isStreaming
                ? 0.4 + streamCtrl.value * 0.6
                : 1.0;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
              padding: const EdgeInsets.only(left: 14, top: 10, bottom: 10, right: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: borderColor.withValues(alpha: borderOpacity),
                    width: isStreaming ? 2.0 : 1.5,
                  ),
                ),
              ),
              child: child,
            );
          },
          child: isError
              ? Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFFEF4444),
                    height: 1.55,
                  ),
                )
              : MarkdownBody(
                  data: text,
                  selectable: true,
                  styleSheet: _buildMarkdownStyle(textColor, mutedColor, isDark),
                ),
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideX(begin: -0.03, end: 0, duration: 220.ms, curve: Curves.easeOut);
  }

  MarkdownStyleSheet _buildMarkdownStyle(Color textColor, Color mutedColor, bool isDark) {
    // Code block background
    final codeBlockBg = isDark ? ThemeConstants.kDark1 : ThemeConstants.kLight0;
    final codeBorder  = isDark ? ThemeConstants.kDarkBorder : ThemeConstants.kLightBorder;

    return MarkdownStyleSheet(
      p: GoogleFonts.inter(
        fontSize: 15,
        color: textColor,
        height: 1.6,
      ),
      strong: GoogleFonts.inter(
        fontSize: 15,
        color: textColor,
        height: 1.6,
        fontWeight: FontWeight.w600,
      ),
      em: GoogleFonts.inter(
        fontSize: 15,
        color: mutedColor,
        fontStyle: FontStyle.italic,
        height: 1.6,
      ),
      listBullet: GoogleFonts.inter(
        fontSize: 15,
        color: mutedColor,
        height: 1.6,
      ),
      h1: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.3,
      ),
      h2: GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      h3: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      // Inline code — JetBrains Mono (T1 fix: mono for technical)
      code: GoogleFonts.jetBrainsMono(
        fontSize: 13,
        backgroundColor: codeBlockBg,
        color: isDark ? const Color(0xFFE0E0E0) : const Color(0xFF333333),
      ),
      // Code block
      codeblockPadding: const EdgeInsets.all(14),
      codeblockDecoration: BoxDecoration(
        color: codeBlockBg,
        borderRadius: BorderRadius.circular(ThemeConstants.kRadiusMd),
        border: Border.all(color: codeBorder, width: 1),
      ),
      // Blockquote
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: ThemeConstants.kAccentBlue.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
    );
  }
}
