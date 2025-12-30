import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';

class StatsScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<Map<String, dynamic>> priorities;

  const StatsScreen({super.key, required this.habits, required this.priorities});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _selectedWeek = DateTime.now();
  List<int> _weeklyPomodoros = [0, 0, 0, 0, 0, 0, 0];

  @override
  void initState() {
    super.initState();
    _loadPomodoroData();
  }

  Future<void> _loadPomodoroData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedWeekly = prefs.getStringList('weekly_list');
    if (savedWeekly != null) {
      setState(() => _weeklyPomodoros = savedWeekly.map((e) => int.parse(e)).toList());
    }
  }

  // --- LÓGICA DE FILTRADO Y CÁLCULO REAL ---

  bool _isFuture() {
    final now = DateTime.now();
    final startOfCurrentWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfSelectedWeek = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    return startOfSelectedWeek.isAfter(startOfCurrentWeek);
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final s1 = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    final s2 = now.subtract(Duration(days: now.weekday - 1));
    return s1.year == s2.year && s1.month == s2.month && s1.day == s2.day;
  }

  Map<String, dynamic> _calculateWeeklyStats() {
    if (_isFuture()) return {'done': 0, 'total': 0, 'percent': 0.0};

    // Meta: Hábitos (frecuencia semanal) + Tareas actuales
    int totalHabitGoals = widget.habits.length * 7;
    int totalTaskGoals = widget.priorities.length;
    int grandTotal = totalHabitGoals + totalTaskGoals;

    // Progreso (Solo cuenta si es la semana actual, para histórico se requiere DB)
    int completedSoFar = 0;
    if (_isCurrentWeek()) {
      completedSoFar = widget.habits.where((h) => h.isCompletedToday).length +
                       widget.priorities.where((p) => p['isDone']).length;
    }

    return {
      'done': completedSoFar,
      'total': grandTotal,
      'percent': grandTotal > 0 ? (completedSoFar / grandTotal) : 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final start = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    final end = start.add(const Duration(days: 6));
    String range = "${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(end)}";
    
    final stats = _calculateWeeklyStats();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text("Progreso", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildWeekSelector(range),
              const SizedBox(height: 25),
              
              Row(
                children: [
                  _statCard(
                    "RACHAS HOY", 
                    "${_isCurrentWeek() ? widget.habits.where((h) => h.isCompletedToday).length : 0}", 
                    Icons.local_fire_department_rounded, 
                    Colors.orangeAccent
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    "META SEMANAL", 
                    "${stats['done']}/${stats['total']}", 
                    Icons.stars_rounded, 
                    const Color(0xFFADFF2F)
                  ),
                ],
              ),
              const SizedBox(height: 10),
              
              _buildProgressPanel(stats['percent']),

              const SizedBox(height: 35),
              _sectionHeader("ACTIVIDAD SEMANAL"),
              const SizedBox(height: 20),
              _buildChart(),
              
              const SizedBox(height: 35),
              _sectionHeader("MIS HÁBITOS"),
              const SizedBox(height: 15),
              _buildHabitList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENTES LIMPIOS ---

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF151517),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressPanel(double percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF151517),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("LOGRO TOTAL", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
              Text("${(percent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.05),
              color: const Color(0xFFADFF2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector(String range) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF151517), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 20), 
            onPressed: () => setState(() => _selectedWeek = _selectedWeek.subtract(const Duration(days: 7)))),
          Text(range.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 20), 
            onPressed: () => setState(() => _selectedWeek = _selectedWeek.add(const Duration(days: 7)))),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barGroups: List.generate(7, (i) {
            // Solo mostramos datos en la barra del día actual si estamos en la semana actual
            bool isToday = _isCurrentWeek() && (i == DateTime.now().weekday - 1);
            
            return BarChartGroupData(
              x: i,
              barRods: [
                // Barra de Hábitos (Blanca)
                BarChartRodData(
                  toY: isToday ? widget.habits.where((h) => h.isCompletedToday).length.toDouble() : 0, 
                  color: Colors.white, 
                  width: 5,
                  borderRadius: BorderRadius.circular(2)
                ),
                // Barra de Tareas (Opaca)
                BarChartRodData(
                  toY: isToday ? widget.priorities.where((p) => p['isDone']).length.toDouble() : 0, 
                  color: Colors.white.withOpacity(0.1), 
                  width: 5,
                  borderRadius: BorderRadius.circular(2)
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(['L','M','X','J','V','S','D'][v.toInt()], style: const TextStyle(color: Colors.white24, fontSize: 10)),
                ),
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildHabitList() {
    if (widget.habits.isEmpty) {
      return const Center(child: Text("No hay hábitos creados", style: TextStyle(color: Colors.white10, fontSize: 12)));
    }
    return Column(
      children: widget.habits.map((h) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(color: const Color(0xFF151517), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(width: 3, height: 15, decoration: BoxDecoration(color: h.color, borderRadius: BorderRadius.circular(5))),
            const SizedBox(width: 12),
            Text(h.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400)),
            const Spacer(),
            Icon(
              h.isCompletedToday ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, 
              color: h.isCompletedToday ? h.color : Colors.white10, 
              size: 18
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _sectionHeader(String title) => Text(title, style: const TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.2));
}