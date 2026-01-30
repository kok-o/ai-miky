import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const MessageBubble({super.key, required this.text, required this.isUser, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser
        ? Colors.deepPurple[300]
        : (isError ? Colors.red[100] : Colors.grey[300]);
    final textColor = isError ? Colors.red[800] : Colors.black;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isError ? Border.all(color: Colors.red[300]!, width: 1) : null,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: textColor, fontWeight: isError ? FontWeight.w500 : FontWeight.normal),
        ),
      ),
    );
  }
}





