import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';
import 'pomodoro_screen.dart';
import 'notes_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<Map<String, dynamic>> priorities;

  const DashboardScreen({super.key, required this.habits, required this.priorities});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _noteController = TextEditingController();

  void _showHabitActions(Habit habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(habit.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.white70),
              title: const Text("Archivar", style: TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => habit.deletedAt = DateTime.now());
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text("Eliminar", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                setState(() => widget.habits.remove(habit));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeHabits = widget.habits.where((h) => h.deletedAt == null).toList();
    int habitCompleted = activeHabits.where((h) => h.isCompletedToday).length;
    int taskCompleted = widget.priorities.where((p) => p['isDone']).length;
    String formattedDate = DateFormat('EEEE, d MMMM', 'es').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      endDrawer: _buildRightSlider(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              // CABECERA: Fecha y Botón alineados horizontalmente
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate.toUpperCase(),
                        style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Hoy",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) => IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.notes_rounded, color: Colors.white, size: 28),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Estadísticas Rápidas
              Row(
                children: [
                  _buildSquareStat("TAREAS", "$taskCompleted/${widget.priorities.length}"),
                  const SizedBox(width: 15),
                  _buildSquareStat("HÁBITOS", "$habitCompleted/${activeHabits.length}"),
                ],
              ),

              const SizedBox(height: 15),
              _buildDailySummaryCard(),
              const SizedBox(height: 40),
              
              _sectionHeader("PRIORIDADES"),
              ...List.generate(widget.priorities.length, (i) => _buildPriorityItem(i)),
              
              const SizedBox(height: 40),
              
              // Sección de Hábitos con botón de añadir
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader("HÁBITOS"),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: _showAddHabit,
                  ),
                ],
              ),

              // Lista de Hábitos con Separadores
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeHabits.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white10, 
                  height: 1, 
                  thickness: 0.5,
                ),
                itemBuilder: (context, index) => GestureDetector(
                  onLongPress: () => _showHabitActions(activeHabits[index]),
                  child: _buildHabitItem(activeHabits[index]),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotesScreen(controller: _noteController))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("RESUMEN DEL DÍA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300),
            decoration: const InputDecoration(hintText: "¿Cómo definirías hoy?", hintStyle: TextStyle(color: Colors.white10), border: InputBorder.none),
          ),
        ]),
      ),
    );
  }

  Widget _buildRightSlider(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: const Color(0xFF1C1C1E).withOpacity(0.8),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("MENU", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  _menuItem(Icons.timer_outlined, "POMODORO", () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroScreen()));
                  }),
                  _menuItem(Icons.book_outlined, "DIARIO", () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => NotesScreen(controller: _noteController)));
                  }),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: GestureDetector(
        onTap: onTap,
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildHabitItem(Habit h) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            h.isCompletedToday ? Icons.check_box : Icons.check_box_outline_blank, 
            color: h.isCompletedToday ? h.color : Colors.white24,
            size: 24,
          ),
          onPressed: () => setState(() {
            if (h.isCompletedToday) {
              h.completedDates.removeWhere((d) => isSameDay(d, DateTime.now()));
            } else {
              h.completedDates.add(DateTime.now());
            }
          }),
        ),
        const SizedBox(width: 12),
        Text(h.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
        const Spacer(),
        // Punto de color más grande y alineado con el botón (+)
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(Icons.circle, color: h.color, size: 12),
        ),
      ]),
    );
  }

  Widget _buildSquareStat(String t, String v) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 5),
        Text(v, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    ),
  );

  Widget _buildPriorityItem(int i) {
    var p = widget.priorities[i];
    return Row(children: [
      Text("${i + 1}.", style: const TextStyle(color: Colors.grey)),
      const SizedBox(width: 10),
      Expanded(
        child: TextField(
          controller: p['controller'],
          style: TextStyle(
            color: Colors.white, 
            fontSize: 14, 
            decoration: p['isDone'] ? TextDecoration.lineThrough : null
          ),
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
      Checkbox(
        value: p['isDone'],
        onChanged: (v) => setState(() => p['isDone'] = v),
        activeColor: Colors.white,
        checkColor: Colors.black,
      ),
    ]);
  }

  Widget _sectionHeader(String t) => Text(
    t, 
    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)
  );

  void _showAddHabit() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (c) => AddHabitScreen(existingHabits: widget.habits, onSave: (h) => setState(() => widget.habits.add(h))),
  );

  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}