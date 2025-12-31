import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';
import '../services/storage_service.dart';
import 'add_habit_screen.dart';
import 'pomodoro_screen.dart';
import 'journal_screen.dart';
import 'stats_screen.dart';
import 'notes_screen.dart';

class DashboardScreen extends StatefulWidget {
  final List<Habit> habits;
  final List<Map<String, dynamic>> priorities;

  const DashboardScreen({super.key, required this.habits, required this.priorities});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDailyNote();
    
    // Guardado automático mientras escribes
    _noteController.addListener(() {
      StorageService.saveDailyNote(_noteController.text);
    });
  }

  Future<void> _loadDailyNote() async {
    String savedNote = await StorageService.loadDailyNote();
    setState(() {
      _noteController.text = savedNote;
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0: return _buildDashboardView();
      case 1: return JournalScreen(habits: widget.habits);
      case 2: return StatsScreen(habits: widget.habits, priorities: widget.priorities);
      default: return _buildDashboardView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      endDrawer: _buildRightMenu(context),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: const Color(0xFF1C1C1E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: "DASHBOARD"),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: "JOURNAL"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "STATS"),
        ],
      ),
    );
  }

  Widget _buildDashboardView() {
    final activeHabits = widget.habits.where((h) => h.deletedAt == null).toList();
    int habitCompleted = activeHabits.where((h) => h.isCompletedToday).length;
    int taskCompleted = widget.priorities.where((p) => p['isDone']).length;
    String formattedDate = DateFormat('EEEE, d MMMM', 'es').format(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(formattedDate),
            const SizedBox(height: 25),
            
            Row(
              children: [
                _buildSquareStat("TAREAS", "$taskCompleted/${widget.priorities.length}"),
                const SizedBox(width: 15),
                _buildSquareStat("HÁBITOS", "$habitCompleted/${activeHabits.length}"),
              ],
            ),
            
            const SizedBox(height: 15),
            // Se envía título vacío para que no ocupe espacio
            _buildWideStat("Escribe un pensamiento...", _noteController),

            const SizedBox(height: 40),
            _buildPrioritiesSection(),
            
            const SizedBox(height: 40),
            _buildHabitsSection(activeHabits),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES MODIFICADOS ---

  Widget _buildWideStat(String hint, TextEditingController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), 
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Centra verticalmente el icono y el texto
        children: [
          IconButton(
            icon: const Icon(Icons.sticky_note_2_rounded, color: Colors.white38, size: 22),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => NotesScreen(controller: controller))
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 1,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.white10, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero, // Elimina espacios internos extra
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- RESTO DE COMPONENTES ---

  Widget _buildHeader(String date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date.toUpperCase(), style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const Text("Hoy", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
        Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu_open_rounded, color: Colors.white, size: 28),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        )),
      ],
    );
  }

  Widget _buildSquareStat(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritiesSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionHeader("PRIORIDADES"),
      const SizedBox(height: 10),
      ...List.generate(widget.priorities.length, (i) => _buildPriorityItem(i)),
    ]);
  }

  Widget _buildPriorityItem(int i) {
    var p = widget.priorities[i];
    return Row(
      children: [
        // --- NÚMERO DE PRIORIDAD ---
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(
            "${i + 1}.",
            style: TextStyle(
              color: p['isDone'] ? Colors.white10 : Colors.white24,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        // ---------------------------
        Expanded(
          child: TextField(
            controller: p['controller'],
            style: TextStyle(
              color: p['isDone'] ? Colors.white24 : Colors.white,
              decoration: p['isDone'] ? TextDecoration.lineThrough : null,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
            decoration: InputDecoration(
              hintText: "Prioridad ${i + 1}",
              hintStyle: const TextStyle(color: Color.fromARGB(61, 255, 255, 255)),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        Checkbox(
          value: p['isDone'],
          onChanged: (v) {
            setState(() => p['isDone'] = v);
            StorageService.savePriorities(widget.priorities);
          },
          activeColor: Colors.transparent,
          checkColor: Colors.white,
          side: const BorderSide(color: Color.fromARGB(80, 212, 212, 212), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Color.fromARGB(88, 255, 255, 255), size: 20),
          onPressed: () {
            setState(() {
              p['controller'].clear();
              p['isDone'] = false;
            });
            StorageService.savePriorities(widget.priorities);
          },
        ),
      ],
    );
  }

  Widget _buildHabitsSection(List<Habit> habits) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _sectionHeader("HÁBITOS"),
        IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white38, size: 20), onPressed: _showAddHabit),
      ]),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: habits.length,
        separatorBuilder: (c, i) => const SizedBox(height: 5),
        itemBuilder: (c, i) => _buildHabitItem(habits[i]),
      ),
    ]);
  }

  Widget _buildHabitItem(Habit h) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconButton(
        icon: Icon(
          h.isCompletedToday ? Icons.done_rounded : Icons.radio_button_unchecked_rounded, 
          color: h.isCompletedToday ? h.color : Colors.white24, size: 26),
        onPressed: () {
          setState(() {
            if (h.isCompletedToday) {
              h.completedDates.removeWhere((d) => isSameDay(d, DateTime.now()));
            } else {
              h.completedDates.add(DateTime.now());
            }
          });
          StorageService.saveHabits(widget.habits);
        },
      ),
      title: Text(h.name, style: TextStyle(color: h.isCompletedToday ? Colors.white38 : Colors.white, fontSize: 15)),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Container(width: 8, height: 8, decoration: BoxDecoration(color: h.color, shape: BoxShape.circle)),
      ),
    );
  }

  Widget _buildRightMenu(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1C1C1E),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(30),
              child: Text("MENU", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ),
            _drawerItem(Icons.timer_outlined, "Pomodoro", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PomodoroScreen()));
            }),
            _drawerItem(Icons.edit_note_rounded, "Notas del día", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotesScreen(controller: _noteController)));
            }),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback tap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      onTap: tap,
    );
  }

  void _showAddHabit() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (c) => AddHabitScreen(
      existingHabits: widget.habits, 
      onSave: (h) {
        setState(() => widget.habits.add(h));
        StorageService.saveHabits(widget.habits);
      }
    ),
  );

  Widget _sectionHeader(String t) => Text(t, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1));
  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}