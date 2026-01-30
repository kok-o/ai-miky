import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AiCursor extends StatefulWidget {
  const AiCursor({super.key, this.size = 96});

  final double size;

  @override
  State<AiCursor> createState() => _AiCursorState();
}

class _AiCursorState extends State<AiCursor> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breath;
  bool _hovered = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _breath = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: _pressed ? 0.95 : (_hovered ? 1.04 : 1.0),
          child: AnimatedBuilder(
            animation: _breath,
            builder: (context, child) {
              return Transform.scale(
                scale: _breath.value,
                child: _buildOrb(colorScheme),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrb(ColorScheme scheme) {
    final double size = widget.size;
    final Gradient gradient = RadialGradient(
      colors: [
        scheme.primary.withOpacity(0.9),
        scheme.secondaryContainer.withOpacity(0.7),
        scheme.surfaceVariant.withOpacity(0.3),
      ],
      stops: const [0.2, 0.6, 1.0],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(_hovered ? 0.55 : 0.35),
            blurRadius: _hovered ? 30 : 18,
            spreadRadius: _hovered ? 4 : 2,
          ),
        ],
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Eye-like pulsing pupil
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _pressed ? size * 0.26 : size * 0.22,
              height: _pressed ? size * 0.26 : size * 0.22,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            // Glint
            Positioned(
              top: size * 0.25,
              left: size * 0.28,
              child: Container(
                width: size * 0.12,
                height: size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



