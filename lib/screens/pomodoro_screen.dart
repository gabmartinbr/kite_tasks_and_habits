import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart'; 
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
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              setState(() => _isWakelockEnabled = !_isWakelockEnabled);
              _isWakelockEnabled ? await WakelockPlus.enable() : await WakelockPlus.disable();
              HapticFeedback.mediumImpact();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _isWakelockEnabled ? Colors.yellow.withOpacity(0.0) : Colors.white.withOpacity(0.05),
                // borderRadius: BorderRadius.circular(20),
                // border: Border.all(
                //   color: _isWakelockEnabled ? Colors.yellow.withOpacity(0.5) : Colors.white10,
                // ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isWakelockEnabled ? Icons.wb_incandescent_rounded : Icons.wb_incandescent_outlined,
                    color: _isWakelockEnabled ? Colors.yellow : Colors.white24,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isWakelockEnabled ? "" : "",
                    style: TextStyle(
                      color: _isWakelockEnabled ? const Color.fromARGB(255, 255, 170, 59) : Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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