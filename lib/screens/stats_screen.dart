import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';

class StatsScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<Map<String, dynamic>> priorities;

  const StatsScreen({super.key, required this.habits, required this.priorities});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _focusedDay = DateTime.now();

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // CÁLCULO REAL DE HÁBITOS
  double _getHabitCompletion(int dayIndex) {
    int todayIndex = DateTime.now().weekday - 1;
    // Solo muestra datos si es HOY y estamos en la semana actual
    if (dayIndex == todayIndex && _isSameWeek(_focusedDay, DateTime.now())) {
      return widget.habits.where((h) => h.isCompletedToday).length.toDouble();
    }
    return 0.0; // Sin datos de ejemplo
  }

  // CÁLCULO REAL DE TAREAS
  double _getTaskCompletion(int dayIndex) {
    int todayIndex = DateTime.now().weekday - 1;
    if (dayIndex == todayIndex && _isSameWeek(_focusedDay, DateTime.now())) {
      return widget.priorities.where((p) => p['isDone']).length.toDouble();
    }
    return 0.0; // Sin datos de ejemplo
  }

  bool _isSameWeek(DateTime d1, DateTime d2) {
    final s1 = _getStartOfWeek(d1);
    final s2 = _getStartOfWeek(d2);
    return s1.year == s2.year && s1.month == s2.month && s1.day == s2.day;
  }

  @override
  Widget build(BuildContext context) {
    final start = _getStartOfWeek(_focusedDay);
    final end = start.add(const Duration(days: 6));
    String range = "${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(end)}";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Progreso", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),

              // Selector de Semana
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 15, color: Colors.white), 
                      onPressed: () => setState(() => _focusedDay = _focusedDay.subtract(const Duration(days: 7)))),
                    Text(range.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.white), 
                      onPressed: () => setState(() => _focusedDay = _focusedDay.add(const Duration(days: 7)))),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              _sectionHeader("ACTIVIDAD SEMANAL"),
              const SizedBox(height: 30),

              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    // Altura dinámica basada en el total de elementos
                    maxY: (widget.habits.length > widget.priorities.length 
                        ? widget.habits.length 
                        : widget.priorities.length).toDouble() + 1,
                    barGroups: List.generate(7, (i) => BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(toY: _getHabitCompletion(i), color: Colors.white, width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                        BarChartRodData(toY: _getTaskCompletion(i), color: Colors.white.withOpacity(0.2), width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                      ],
                    )),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(days[value.toInt()], style: const TextStyle(color: Colors.white24, fontSize: 12)),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legendItem("Hábitos", Colors.white),
                  const SizedBox(width: 20),
                  _legendItem("Tareas", Colors.white24),
                ],
              ),

              const SizedBox(height: 50),
              _sectionHeader("RESUMEN GENERAL"),
              const SizedBox(height: 15),
              _statTile("Hábitos Activos", "${widget.habits.length}", Icons.auto_awesome_outlined),
              _statTile("Tareas Completadas", "${widget.priorities.where((p) => p['isDone']).length}/${widget.priorities.length}", Icons.check_circle_outline),

              const SizedBox(height: 40),
              _sectionHeader("DETALLE POR HÁBITO"),
              const SizedBox(height: 15),

              // LISTA DE HÁBITOS SIN DATOS DE EJEMPLO
              if (widget.habits.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No hay hábitos creados aún.", style: TextStyle(color: Colors.white24, fontSize: 14)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.habits.length,
                  itemBuilder: (context, index) {
                    final habit = widget.habits[index];
                    
                    // PROGRESO REAL: Basado solo en si está hecho hoy (1/7) o no (0/7)
                    // Para que sea 2/7, 3/7, etc., necesitamos guardar el histórico.
                    double progress = habit.isCompletedToday ? (1 / 7) : 0.0;
                    int daysDone = habit.isCompletedToday ? 1 : 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(habit.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              Text("$daysDone/7 DÍAS", style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
                              FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: habit.color,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(color: habit.color.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("${(progress * 100).toInt()}% de consistencia semanal", style: TextStyle(color: habit.color.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _statTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 20),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String text) => Text(text, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5));
}