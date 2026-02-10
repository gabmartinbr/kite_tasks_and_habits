import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppleNotes extends StatelessWidget {
  final TextEditingController controller;
  const AppleNotes({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24), // Más aire
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(28), // Bordes más orgánicos
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "PENSAMIENTOS",
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: null,
            cursorColor: Colors.white24,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w300, // Fuente más ligera
            ),
            decoration: InputDecoration(
              hintText: "Escribe cómo va tu día...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.05)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}