import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

/// Electric "01" logo matching the provided brand image.
/// Stroke style — thick cyan outline on dark bg, diagonal slash through 0.
class Logo01 extends StatelessWidget {
  final double size;
  final bool showText;
  final String? text;
  final String? heroTag;
  final bool showMikuSubtitle;
  final Color? color;

  const Logo01({
    super.key,
    this.size = 40,
    this.showText = true,
    this.text,
    this.heroTag,
    this.showMikuSubtitle = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = color ??
        (isDark ? ThemeConstants.kBrandCyan : Theme.of(context).colorScheme.primary);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.12),
              child: Image.asset(
                'assets/logo.png',
                width: size * 1.15,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
            if (showText && text != null && text!.isNotEmpty) ...[
              SizedBox(width: size * 0.28),
              Text(
                text!,
                style: TextStyle(
                  fontSize: size * 0.52,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ],
        ),
        if (showMikuSubtitle) ...[
          SizedBox(height: size * 0.1),
          Text(
            'MIKU',
            style: TextStyle(
              fontSize: size * 0.2,
              fontWeight: FontWeight.w600,
              color: logoColor.withValues(alpha: 0.8),
              letterSpacing: size * 0.08,
            ),
          ),
        ],
      ],
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: content,
        ),
      );
    }
    return content;
  }
}

