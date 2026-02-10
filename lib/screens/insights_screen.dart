import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/stats_insights.dart';

class InsightsScreen extends StatelessWidget {
  final int completed;
  final int total;

  const InsightsScreen({super.key, required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CupertinoNavigationBar(
        backgroundColor: Colors.black,
        middle: Text("Análisis Semanal", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            StatsInsight(completed: completed, total: total),
            const SizedBox(height: 20),
            // Aquí podrías añadir más gráficos en el futuro
          ],
        ),
      ),
    );
  }
}