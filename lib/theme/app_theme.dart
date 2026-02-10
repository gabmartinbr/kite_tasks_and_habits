import 'package:flutter/material.dart';

class KiteTheme {
  // Colores de la cometa según tu imagen
  static const Color kiteDeepPurple = Color(0xFF312E81);
  static const Color kiteTeal = Color(0xFF2DD4BF);
  static const List<Color> kiteGradient = [Color(0xFF4F46E5), Color(0xFF0EA5E9)];

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(0xFF0A0A0B), // Un gris casi negro para las tarjetas
  );
}