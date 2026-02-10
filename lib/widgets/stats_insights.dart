import 'package:flutter/material.dart';

class StatsInsight extends StatelessWidget {
  final int completed;
  final int total;

  const StatsInsight({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    double ratio = total > 0 ? completed / total : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CONSISTENCIA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("${(ratio * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const Text("Tu rendimiento actual esta semana", style: TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 55, height: 55,
                child: CircularProgressIndicator(
                  value: ratio,
                  backgroundColor: Colors.white10,
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
              const Icon(Icons.bolt, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}