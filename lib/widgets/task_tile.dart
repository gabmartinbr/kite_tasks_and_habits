import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onTap;

  const TaskTile({super.key, required this.title, required this.isDone, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
              color: isDone ? Colors.greenAccent : Colors.white24,
              size: 26,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: isDone ? Colors.grey[600] : Colors.white,
                decoration: isDone ? TextDecoration.lineThrough : null,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}