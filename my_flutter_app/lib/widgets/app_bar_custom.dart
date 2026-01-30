import 'package:flutter/material.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppBarCustom({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      centerTitle: true,
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF8E7CFF),
            Color(0xFF6AD7FF),
          ],
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2)),
      ),
      backgroundColor: scheme.surface.withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 4,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}




