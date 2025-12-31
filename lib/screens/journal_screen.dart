import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';

class JournalScreen extends StatefulWidget {
  final List<Habit> habits;
  const JournalScreen({super.key, required this.habits});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  DateTime _viewDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  // --- CÁLCULO DE RACHA DINÁMICA ---
  int _calculateRealStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    
    int streak = 0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    // Comprobamos si hoy está completado
    bool doneToday = habit.completedDates.any((d) => 
        d.year == today.year && d.month == today.month && d.day == today.day);
    
    // Si no está hecho hoy, la racha sigue viva si se hizo ayer
    DateTime checkDate = doneToday ? today : today.subtract(const Duration(days: 1));

    while (habit.completedDates.any((d) => 
        d.year == checkDate.year && d.month == checkDate.month && d.day == checkDate.day)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // --- ACCIONES DEL HÁBITO ---
  void _showHabitActions(Habit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
              ),
              Text(habit.name.toUpperCase(), 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.archive_outlined, color: Colors.white70),
                title: const Text("Archivar Hábito", style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => habit.deletedAt = DateTime.now());
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
                title: const Text("Eliminar por completo", style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  setState(() => widget.habits.remove(habit));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredHabits = widget.habits.where((h) {
      DateTime monthStart = DateTime(_viewDate.year, _viewDate.month, 1);
      DateTime nextMonthStart = DateTime(_viewDate.year, _viewDate.month + 1, 1);
      bool existiaEnEsteMes = h.createdAt.isBefore(nextMonthStart);
      bool noEstabaBorradoAun = h.deletedAt == null || h.deletedAt!.isAfter(monthStart);
      return existiaEnEsteMes && noEstabaBorradoAun;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("JOURNAL", 
          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          _buildMonthHeader(),
          const SizedBox(height: 15),
          _buildGridCalendar(),
          const SizedBox(height: 40),
          const Text("ESTADO DE HÁBITOS \n(mantén para opciones)", 
            style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 25),
          if (filteredHabits.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Sin registros para este mes.", style: TextStyle(color: Colors.white10)),
            ),
          ...filteredHabits.map((h) => _buildHabitRow(h)),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white38), 
          onPressed: () => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month - 1, 1))
        ),
        Text(DateFormat('MMMM yyyy', 'es').format(_viewDate).toUpperCase(), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white38), 
          onPressed: () => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month + 1, 1))
        ),
      ],
    );
  }

  Widget _buildGridCalendar() {
    final int days = DateUtils.getDaysInMonth(_viewDate.year, _viewDate.month);
    final int offset = DateTime(_viewDate.year, _viewDate.month, 1).weekday - 1;
    
    return GridView.builder(
      shrinkWrap: true, 
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days + offset,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox.shrink();
        final int d = index - offset + 1;
        DateTime dateInGrid = DateTime(_viewDate.year, _viewDate.month, d);

        int completedCount = widget.habits.where((h) => 
          h.completedDates.any((cd) => cd.year == dateInGrid.year && cd.month == dateInGrid.month && cd.day == dateInGrid.day)
        ).length;

        bool isToday = d == DateTime.now().day && _viewDate.month == DateTime.now().month && _viewDate.year == DateTime.now().year;

        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: completedCount > 0 
                ? const Color(0xFF2DC479).withOpacity((completedCount / (widget.habits.isEmpty ? 1 : widget.habits.length)).clamp(0.2, 0.9)) 
                : Colors.white.withOpacity(0.03), 
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isToday ? Colors.white38 : Colors.transparent)
          ),
          child: Text("$d", style: TextStyle(color: isToday ? Colors.white : Colors.white38, fontSize: 11)),
        );
      },
    );
  }

  Widget _buildHabitRow(Habit h) {
    int streak = _calculateRealStreak(h);
    bool hasStreak = streak > 0;
    final int daysInMonth = DateUtils.getDaysInMonth(_viewDate.year, _viewDate.month);
    final int offset = DateTime(_viewDate.year, _viewDate.month, 1).weekday - 1;

    return InkWell(
      onLongPress: () => _showHabitActions(h),
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.name.toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // FUEGO GAMIFICADO
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded, 
                            // Gris claro (white10) si no hay racha, color del hábito si la hay
                            color: hasStreak ? h.color : const Color.fromARGB(137, 255, 255, 255), 
                            size: 13
                          ),
                          if (!hasStreak)
                            Transform.rotate(
                              angle: -0.5,
                              child: Container(width: 12, height: 1.5, color: Colors.white24),
                            ),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Text(hasStreak ? "$streak DÍAS" : "0 DÍAS", 
                        style: TextStyle(
                          color: hasStreak ? h.color.withOpacity(0.7) : Colors.white24, 
                          fontSize: 9, 
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5
                        )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 130, 
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
                itemCount: daysInMonth + offset,
                itemBuilder: (context, index) {
                  if (index < offset) return const SizedBox.shrink();
                  final int day = index - offset + 1;
                  DateTime dateInGrid = DateTime(_viewDate.year, _viewDate.month, day);
                  bool active = h.completedDates.any((cd) => 
                    cd.year == dateInGrid.year && cd.month == dateInGrid.month && cd.day == dateInGrid.day
                  );

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      color: active ? h.color : Colors.transparent, 
                      border: Border.all(
                        color: active ? h.color : Colors.white.withOpacity(0.1), 
                        width: 1.5,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}