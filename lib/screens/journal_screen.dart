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
    // Filtro para mostrar solo hábitos que existían en el mes seleccionado y no estaban borrados
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
          _buildGridCalendar(), // Calendario principal (Heatmap)
          const SizedBox(height: 40),
          const Text("ESTADO DE HÁBITOS", 
            style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 25),
          if (filteredHabits.isEmpty)
            const Text("Sin registros para este mes.", style: TextStyle(color: Colors.white10)),
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
          icon: const Icon(Icons.chevron_left, color: Color.fromARGB(255, 175, 175, 175)), 
          onPressed: () => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month - 1, 1))
        ),
        Text(DateFormat('MMMM yyyy', 'es').format(_viewDate).toUpperCase(), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Color.fromARGB(255, 175, 175, 175)), 
          onPressed: () => setState(() => _viewDate = DateTime(_viewDate.year, _viewDate.month + 1, 1))
        ),
      ],
    );
  }

  // Calendario principal que muestra la actividad general
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

        // Contar cuántos hábitos se completaron ese día
        int completedCount = widget.habits.where((h) => 
          h.completedDates.any((cd) => cd.year == dateInGrid.year && cd.month == dateInGrid.month && cd.day == dateInGrid.day)
        ).length;

        bool isToday = d == DateTime.now().day && _viewDate.month == DateTime.now().month && _viewDate.year == DateTime.now().year;

        return Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: completedCount > 0 
                ? const Color.fromARGB(220, 45, 196, 121).withOpacity((completedCount / (widget.habits.isEmpty ? 1 : widget.habits.length)).clamp(0.2, 0.9)) 
                : Colors.white.withOpacity(0.03), 
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isToday ? Colors.white38 : Colors.white12)
          ),
          child: Text("$d", style: TextStyle(color: isToday ? Colors.white : Colors.white38, fontSize: 12)),
        );
      },
    );
  }

  // Fila de cada hábito con su mini-calendario propio
  Widget _buildHabitRow(Habit h) {
    // Calculamos los mismos parámetros que el calendario de arriba para que coincidan las formas
    final int daysInMonth = DateUtils.getDaysInMonth(_viewDate.year, _viewDate.month);
    final int offset = DateTime(_viewDate.year, _viewDate.month, 1).weekday - 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 20),
          // MINI CALENDARIO DE PUNTOS (Réplica del de arriba)
          SizedBox(
            width: 120, // Ajustamos el ancho para que quepa bien a la derecha
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 días de la semana
                mainAxisSpacing: 4, 
                crossAxisSpacing: 4
              ),
              itemCount: daysInMonth + offset,
              itemBuilder: (context, index) {
                if (index < offset) return const SizedBox.shrink(); // Espacios vacíos al inicio del mes
                
                final int day = index - offset + 1;
                DateTime dateInGrid = DateTime(_viewDate.year, _viewDate.month, day);
                
                // Comprobamos si este hábito específico se completó en esta fecha
                bool active = h.completedDates.any((cd) => 
                  cd.year == dateInGrid.year && cd.month == dateInGrid.month && cd.day == dateInGrid.day
                );

                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    // Si está activo, fondo de color sólido. 
                    // Si no, transparente para que solo se vea el borde.
                    color: active ? h.color : Colors.transparent, 
                    border: Border.all(
                      // Borde del color del hábito si está activo, 
                      // o un gris muy sutil (blanco con 0.05 de opacidad) si está vacío.
                      color: active ? h.color : Colors.white.withOpacity(0.3), 
                      width: 2.0, // Grosor fino para que sea elegante
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}