import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

/// Blurred glowing circle for ambient background decoration.
class BlurredCircle extends StatelessWidget {
  final Color color;
  final double size;

  const BlurredCircle({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: size * 0.28, sigmaY: size * 0.28),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

/// Glowing accent orb — adds a visible neon glow effect.
class GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double blurRadius;

  const GlowOrb({
    super.key,
    required this.color,
    required this.size,
    this.blurRadius = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: blurRadius,
            spreadRadius: size * 0.2,
          ),
        ],
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

/// Full dark background — flat, no glowing orbs (Vercel-style clean dark).
class DarkBackground extends StatelessWidget {
  const DarkBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeConstants.kDark0,
    );
  }
}
