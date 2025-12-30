import 'package:flutter/cupertino.dart';
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

  @override
  Widget build(BuildContext context) {
    // FILTRO HISTÓRICO:
    final filteredHabits = widget.habits.where((h) {
      DateTime monthStart = DateTime(_viewDate.year, _viewDate.month, 1);
      DateTime nextMonthStart = DateTime(_viewDate.year, _viewDate.month + 1, 1);
      
      bool existiaEnEsteMes = h.createdAt.isBefore(nextMonthStart);
      bool noEstabaBorradoAun = h.deletedAt == null || h.deletedAt!.isAfter(monthStart);
      
      return existiaEnEsteMes && noEstabaBorradoAun;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CupertinoNavigationBar(
        backgroundColor: Colors.black, 
        middle: Text("Journal", style: TextStyle(color: Colors.white))
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 20),
          _buildMonthHeader(),
          const SizedBox(height: 15),
          _buildGridCalendar(),
          const SizedBox(height: 40),
          const Text("ESTADO DE HÁBITOS", 
            style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 5),
          const Text("(Mantén presionado para opciones)", style: TextStyle(color: Colors.white24, fontSize: 10)),
          const SizedBox(height: 25),
          if (filteredHabits.isEmpty)
            const Text("Sin registros para este mes.", style: TextStyle(color: Colors.white10)),
          ...filteredHabits.map((h) => _buildHabitRow(h)),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left, color: Colors.blueAccent), 
          onPressed: () => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month - 1, 1))),
        Text(DateFormat('MMMM yyyy', 'es').format(_viewDate).toUpperCase(), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
        IconButton(icon: const Icon(Icons.chevron_right, color: Colors.blueAccent), 
          onPressed: () => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month + 1, 1))),
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
        bool isToday = d == DateTime.now().day && _viewDate.month == DateTime.now().month && _viewDate.year == DateTime.now().year;
        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday ? Colors.white38 : Colors.white.withOpacity(0.03), 
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isToday ? Colors.white38 : Colors.white12)
          ),
          child: Text("$d", style: TextStyle(color: isToday ? Colors.white : Colors.white38, fontSize: 12)),
        );
      },
    );
  }

  Widget _buildHabitRow(Habit h) {
    return GestureDetector(
      onLongPress: () => _showOptions(h),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.name.toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("🔥 ${h.currentStreak} RACHA", 
                    style: TextStyle(color: h.color, fontSize: 10, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            // Cuadrícula 7x4
            SizedBox(
              width: 150,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, mainAxisSpacing: 5, crossAxisSpacing: 5),
                itemCount: 28,
                itemBuilder: (context, index) {
                  // Simulación visual: el último punto es hoy
                  bool active = (index == 27) ? h.isCompletedToday : (index % 6 != 0); 
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      color: active ? h.color : Colors.white.withOpacity(0.05)
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

  void _showOptions(Habit h) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text("Gestionar '${h.name}'"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => h.deletedAt = DateTime.now());
              Navigator.pop(context);
            },
            child: const Text("Archivar (Mantiene historial)"),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              setState(() {
                widget.habits.remove(h); // BORRADO TOTAL
              });
              Navigator.pop(context);
            },
            child: const Text("Eliminar Definitivamente"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Cancelar"),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}