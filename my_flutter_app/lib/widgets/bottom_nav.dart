import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Чат'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Настройки'),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}





