import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/theme_constants.dart';

/// Miku AI avatar orb — Vercel-style monochrome.
///
/// Design decisions:
/// - Removed rainbow RadialGradient (C4 violation — AI-generated tell)
/// - Removed continuous rotation (was jarring, generic feel)
/// - Kept breathing pulse (subtle, premium feel)
/// - Added 3 orbiting micro-dots (differentiating detail, monochrome)
/// - Vercel Blue glow on hover only
class AiCursor extends StatefulWidget {
  const AiCursor({super.key, this.size = 96, this.isThinking = false});

  final double size;

  /// When true, shows a subtle pulsing animation indicating AI is thinking
  final bool isThinking;

  @override
  State<AiCursor> createState() => _AiCursorState();
}

class _AiCursorState extends State<AiCursor> with TickerProviderStateMixin {
  late AnimationController _breathCtrl;
  late AnimationController _orbitCtrl;
  late Animation<double> _breath;

  bool _hovered = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    // Breathing — slow, organic feel
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _breath = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut),
    );

    // Orbit dots — slow counter-clockwise rotation
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown:   (_) => setState(() => _pressed = true),
        onTapUp:     (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: ThemeConstants.kDurationFast,
          curve: Curves.easeOutCubic,
          scale: _pressed ? 0.94 : (_hovered ? 1.05 : 1.0),
          child: AnimatedBuilder(
            animation: Listenable.merge([_breath, _orbitCtrl]),
            builder: (context, _) => _buildOrb(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildOrb(bool isDark) {
    final s = widget.size;
    final glowRadius = _hovered ? s * 0.55 : s * 0.38;
    final glowOpacity = _hovered ? 0.18 : 0.08;

    // Core orb colors — monochrome with subtle gradient
    final coreLight = isDark ? const Color(0xFFF0F0F0) : const Color(0xFF1A1A1A);
    final coreMid   = isDark ? const Color(0xFF888888) : const Color(0xFF666666);

    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Ambient glow ─────────────────────────────────────────────────
          AnimatedContainer(
            duration: ThemeConstants.kDurationMed,
            width: glowRadius * 2,
            height: glowRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ThemeConstants.kAccentBlue.withValues(alpha: glowOpacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // ── Orbiting dots ────────────────────────────────────────────────
          ..._buildOrbitDots(s, isDark),

          // ── Core orb (breathing) ─────────────────────────────────────────
          Transform.scale(
            scale: _breath.value,
            child: Container(
              width: s * 0.52,
              height: s * 0.52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.25, -0.25),
                  colors: [
                    coreLight,
                    coreMid,
                    isDark ? const Color(0xFF333333) : const Color(0xFF444444),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                boxShadow: [
                  // Main shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                  // Hover accent glow
                  if (_hovered)
                    BoxShadow(
                      color: ThemeConstants.kAccentBlue.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Specular highlight — top-left
                  Positioned(
                    top: s * 0.52 * 0.18,
                    left: s * 0.52 * 0.18,
                    child: Container(
                      width: s * 0.52 * 0.22,
                      height: s * 0.52 * 0.14,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white.withValues(
                          alpha: isDark ? 0.55 : 0.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Thinking indicator (if active) ───────────────────────────────
          if (widget.isThinking)
            _ThinkingRing(size: s)
                .animate(onPlay: (c) => c.repeat())
                .rotate(duration: 2.seconds, curve: Curves.linear),
        ],
      ),
    );
  }

  List<Widget> _buildOrbitDots(double s, bool isDark) {
    // 3 dots at 0°, 120°, 240° offset, orbiting at different speeds
    const dotAngles = [0.0, 2.094, 4.189]; // 0, 120, 240 degrees in radians
    final orbitRadius = s * 0.42;
    final dotColor = isDark
        ? const Color(0xFF444444)
        : const Color(0xFFBBBBBB);

    return dotAngles.asMap().entries.map((entry) {
      final i = entry.key;
      final baseAngle = entry.value;
      // Each dot rotates at slightly different speed for organic feel
      final angle = baseAngle + (_orbitCtrl.value * 2 * math.pi * (1.0 - i * 0.08));
      final dotX = math.cos(angle) * orbitRadius;
      final dotY = math.sin(angle) * orbitRadius;
      // Dots further away appear smaller (depth illusion)
      final dotOpacity = (math.sin(angle) + 1) / 2 * 0.5 + 0.2;
      final dotSize = (math.sin(angle) + 1) / 2 * 3 + 3.0;

      return Positioned(
        left: s / 2 + dotX - dotSize / 2,
        top:  s / 2 + dotY - dotSize / 2,
        child: Opacity(
          opacity: dotOpacity.clamp(0.15, 0.65),
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Subtle rotating ring shown when AI is thinking
class _ThinkingRing extends StatelessWidget {
  const _ThinkingRing({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.75,
      height: size * 0.75,
      child: CustomPaint(painter: _DashedRingPainter()),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeConstants.kAccentBlue.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    const dashAngle = 0.35; // radians per dash
    const gapAngle  = 0.25;

    double angle = 0;
    while (angle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        dashAngle,
        false,
        paint,
      );
      angle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
