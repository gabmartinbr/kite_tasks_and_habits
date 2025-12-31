import 'package:flutter/material.dart';

Widget kiteLogo({double size = 80}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          // Cuerpo de la cometa
          Transform.rotate(
            angle: 0.785398, // 45 grados en radianes
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(size * 0.2),
              ),
              child: Center(
                child: Container(
                  width: size * 0.4,
                  height: size * 0.4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          // Hilo de la cometa (Sutil)
          Positioned(
            bottom: -20,
            child: Container(
              width: 2,
              height: 40,
              color: Colors.white24,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text(
        "KITE",
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.3,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
        ),
      ),
    ],
  );
}