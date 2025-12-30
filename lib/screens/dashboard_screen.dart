import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import 'add_habit_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<Map<String, dynamic>> priorities;

  const DashboardScreen({super.key, required this.habits, required this.priorities});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Controlador para la nota persistente
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final activeHabits = widget.habits.where((h) => h.deletedAt == null).toList();
    int habitCompleted = activeHabits.where((h) => h.isCompletedToday).length;
    int taskCompleted = widget.priorities.where((p) => p['isDone']).length;

    // Formateo de fecha: "Lunes, Diciembre 29"
    String formattedDate = DateFormat('EEEE, MMMM d', 'es').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // CABECERA: Fecha y "Hoy"
              Text(formattedDate.toUpperCase(), 
                style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Text("Hoy", 
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 25),
              
              // DOS CUADRADOS DE PROGRESO
              Row(
                children: [
                  _buildSquareStat("TAREAS", "$taskCompleted/${widget.priorities.length}"),
                  const SizedBox(width: 15),
                  _buildSquareStat("HÁBITOS", "$habitCompleted/${activeHabits.length}"),
                ],
              ),

              const SizedBox(height: 30),

              // NOTA DEL DÍA
              _sectionHeader("NOTA DEL DÍA"),
              TextField(
                controller: _noteController,
                maxLines: null,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Escribe algo que quieras recordar...",
                  hintStyle: TextStyle(color: Colors.white10, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 30),

              // PRIORIDADES
              _sectionHeader("PRIORIDADES DIARIAS"),
              const SizedBox(height: 10),
              ...List.generate(widget.priorities.length, (index) => _buildPriorityItem(index)),

              const SizedBox(height: 40),

              // SECCIÓN HÁBITOS + BOTÓN AÑADIR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader("HÁBITOS"),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    onPressed: () => _showAddHabit(),
                  ),
                ],
              ),
              
              // LISTA DE HÁBITOS CON SEPARADORES
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activeHabits.length,
                separatorBuilder: (context, index) => Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 0.5,
                    color: Colors.white12,
                  ),
                ),
                itemBuilder: (context, index) => _buildHabitItem(activeHabits[index]),
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareStat(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityItem(int index) {
    var priority = widget.priorities[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("${index + 1}.", style: const TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: priority['controller'],
              style: TextStyle(
                color: Colors.white, 
                fontSize: 15,
                decoration: priority['isDone'] ? TextDecoration.lineThrough : null
              ),
              decoration: const InputDecoration(border: InputBorder.none, hintText: "..."),
            ),
          ),
          Checkbox(
            value: priority['isDone'],
            activeColor: Colors.white,
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (v) => setState(() => priority['isDone'] = v),
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash, color: Colors.white10, size: 18),
            onPressed: () => setState(() => priority['controller'].clear()),
          )
        ],
      ),
    );
  }

  Widget _buildHabitItem(Habit habit) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconButton(
        icon: Icon(
          habit.isCompletedToday ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.square,
          color: habit.isCompletedToday ? habit.color : Colors.white24,
        ),
        onPressed: () => setState(() {
          habit.isCompletedToday = !habit.isCompletedToday;
          if (habit.isCompletedToday) habit.currentStreak++; 
          else if(habit.currentStreak > 0) habit.currentStreak--;
        }),
      ),
      title: Text(habit.name, style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing: Icon(Icons.circle, color: habit.color, size: 8),
    );
  }

  Widget _sectionHeader(String text) => Text(text, 
    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2));

  void _showAddHabit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddHabitScreen(
        existingHabits: widget.habits, 
        onSave: (h) => setState(() => widget.habits.add(h)),
      ),
    );
  }
}