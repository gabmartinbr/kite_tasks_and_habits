import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';
import '../services/storage_service.dart'; // Asegúrate de importar tu servicio

class StatsScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<Map<String, dynamic>> priorities;

  const StatsScreen({super.key, required this.habits, required this.priorities});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _selectedWeek = DateTime.now();
  
  // Guardaremos aquí los conteos de cada día de la semana seleccionada
  // Key: día del 1 al 7, Value: [hábitos_hechos, tareas_hechas]
  Map<int, List<double>> _historyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllWeekData();
  }

  // --- CARGA DE DATOS REALES ---
  Future<void> _loadAllWeekData() async {
    setState(() => _isLoading = true);
    Map<int, List<double>> tempStats = {};

    // Buscamos el lunes de la semana seleccionada
    DateTime Monday = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));

    for (int i = 0; i < 7; i++) {
      DateTime dayToLoad = Monday.add(Duration(days: i));
      
      // 1. Cargar Prioridades de ese día desde el disco
      List<Map<String, dynamic>> dayPriorities = await StorageService.loadPriorities(date: dayToLoad);
      double tasksDone = dayPriorities.where((p) => p['isDone'] == true).length.toDouble();

      // 2. Calcular Hábitos de ese día
      // Como los hábitos guardan su propia lista de fechas, filtramos por el día
      double habitsDone = widget.habits.where((h) => 
        h.completedDates.any((d) => 
          d.year == dayToLoad.year && d.month == dayToLoad.month && d.day == dayToLoad.day
        )
      ).length.toDouble();

      tempStats[i] = [habitsDone, tasksDone];
    }

    setState(() {
      _historyData = tempStats;
      _isLoading = false;
    });
  }

  // --- LÓGICA DE STREAK (La tuya estaba bien) ---
  int _calculateRealStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    int streak = 0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    bool doneToday = habit.completedDates.any((d) => 
        d.year == today.year && d.month == today.month && d.day == today.day);
    DateTime checkDate = doneToday ? today : today.subtract(const Duration(days: 1));

    while (habit.completedDates.any((d) => 
        d.year == checkDate.year && d.month == checkDate.month && d.day == checkDate.day)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final start = _selectedWeek.subtract(Duration(days: _selectedWeek.weekday - 1));
    final end = start.add(const Duration(days: 6));
    String range = "${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM').format(end)}";
    final screenHeight = MediaQuery.of(context).size.height;

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

              SizedBox(height: screenHeight * 0.12), 

              Center(
                child: Column(
                  children: [
                    _sectionHeader("ACTIVIDAD SEMANAL"),
                    const SizedBox(height: 30),
                    _isLoading 
                      ? const SizedBox(height: 180, child: Center(child: CircularProgressIndicator(color: Colors.white24)))
                      : _buildChart(),
                    const SizedBox(height: 20),
                    _buildLegend(),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.15), 

              _sectionHeader("MIS HÁBITOS"),
              const SizedBox(height: 15),
              _buildHabitList(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // --- SELECTOR DE SEMANA ACTUALIZADO ---
  Widget _buildWeekSelector(String range) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF151517), borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white70, size: 20), 
            onPressed: () {
              setState(() => _selectedWeek = _selectedWeek.subtract(const Duration(days: 7)));
              _loadAllWeekData(); // Recargar al cambiar semana
            }),
          Text(range.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white70, size: 20), 
            onPressed: () {
              setState(() => _selectedWeek = _selectedWeek.add(const Duration(days: 7)));
              _loadAllWeekData(); // Recargar al cambiar semana
            }),
        ],
      ),
    );
  }

  // --- GRÁFICO CON DATOS HISTÓRICOS ---
  Widget _buildChart() {
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 6, // Ajustado para que 3 tareas + hábitos queden bien
          barGroups: List.generate(7, (i) {
            // Usamos los datos cargados en el Map
            double habitsCount = _historyData[i]?[0] ?? 0;
            double tasksCount = _historyData[i]?[1] ?? 0;

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: habitsCount, 
                  color: Colors.white, width: 6, borderRadius: BorderRadius.circular(2)
                ),
                BarChartRodData(
                  toY: tasksCount, 
                  color: const Color.fromARGB(234, 167, 167, 167), width: 6, borderRadius: BorderRadius.circular(2)
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
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(['L','M','X','J','V','S','D'][v.toInt()], style: const TextStyle(color: Colors.white24, fontSize: 11)),
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

  // ... (Tus otros métodos _buildLegend, _buildHabitList, _sectionHeader quedan igual)
  
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("HÁBITOS", Colors.white),
        const SizedBox(width: 25),
        _legendItem("TAREAS", const Color.fromARGB(234, 167, 167, 167)),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
      ],
    );
  }

  Widget _buildHabitList() {
    if (widget.habits.isEmpty) {
      return const Center(child: Text("No hay hábitos creados", style: TextStyle(color: Colors.white10, fontSize: 12)));
    }
    return Column(
      children: widget.habits.map((h) {
        int streak = _calculateRealStreak(h);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(color: const Color(0xFF151517), borderRadius: BorderRadius.circular(18)),
          child: Row(
            children: [
              Container(width: 3.5, height: 18, decoration: BoxDecoration(color: h.color, borderRadius: BorderRadius.circular(5))),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, 
                        color: streak > 0 ? Colors.orangeAccent : Colors.white10, size: 14),
                      const SizedBox(width: 4),
                      Text("$streak DÍAS", 
                        style: TextStyle(color: streak > 0 ? Colors.orangeAccent.withOpacity(0.9) : Colors.white10, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                h.isCompletedToday ? Icons.check_circle_rounded : Icons.radio_button_off_rounded, 
                color: h.isCompletedToday ? h.color : const Color.fromARGB(26, 233, 48, 48), 
                size: 20
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionHeader(String title) => Text(title, 
    style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5));
}