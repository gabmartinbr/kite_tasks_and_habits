import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; // Asegúrate de tener la dependencia
import '../widgets/pomodoro_timer.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  bool _isWakelockEnabled = false;

  @override
  void dispose() {
    // Importante: Desactivar al salir de la pantalla
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        // BOTÓN ARRIBA A LA DERECHA
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                _isWakelockEnabled 
                    ? Icons.wb_incandescent_rounded 
                    : Icons.wb_incandescent_outlined,
                color: _isWakelockEnabled ? Colors.yellow : Colors.white24,
                size: 22,
              ),
              onPressed: () async {
                setState(() => _isWakelockEnabled = !_isWakelockEnabled);
                if (_isWakelockEnabled) {
                  await WakelockPlus.enable();
                } else {
                  await WakelockPlus.disable();
                }
                HapticFeedback.lightImpact();
              },
            ),
          ),
        ],
      ),
      body: const Center(
        child: PomodoroTimer(),
      ),
    );
  }
}