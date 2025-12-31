import 'package:flutter/material.dart';

class TutorialOverlay extends StatelessWidget {
  final VoidCallback onFinish;
  const TutorialOverlay({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Capa opaca
          GestureDetector(
            onTap: onFinish,
            child: Container(color: Colors.black.withOpacity(0.85)),
          ),
          
          // Explicación Prioridades
          Positioned(
            top: 250, left: 30,
            child: _tutorialStep("PRIORIDADES", "Tus 3 objetivos clave del día.\nDesliza o marca para completar.", Icons.arrow_upward),
          ),

          // Explicación Pensamientos
          Positioned(
            top: 140, right: 30,
            child: _tutorialStep("DIARIO", "Pulsa para escribir y añadir\nuna foto a tu recuerdo.", Icons.arrow_upward),
          ),

          // Explicación Menú Lateral
          Positioned(
            top: 40, right: 60,
            child: Row(
              children: [
                const Text("Configura Pomodoro\ny otras herramientas", 
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w300)),
                const Icon(Icons.arrow_forward, color: Colors.orange, size: 20),
              ],
            ),
          ),

          // Botón Entendido
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.bottom(100),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15)
                ),
                onPressed: onFinish,
                child: const Text("EMPEZAR AHORA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tutorialStep(String title, String desc, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.orange, size: 24),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 5),
        Text(desc, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w300)),
      ],
    );
  }
}