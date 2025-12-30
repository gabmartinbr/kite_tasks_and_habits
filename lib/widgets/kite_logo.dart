import 'package:flutter/material.dart';

class KiteLogo extends StatelessWidget {
  final double size;
  const KiteLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF2DD4BF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Icon(Icons.navigation_rounded, size: size, color: Colors.white), 
      // El icono 'navigation' rotado parece una cometa de 3 puntas
    );
  }
}