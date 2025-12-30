import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'journal_screen.dart';
import '../models/habit_model.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  // Inicializamos las listas aquí mismo
  final List<Habit> _sharedHabits = [];
  final List<Map<String, dynamic>> _sharedPriorities = [
    {"controller": TextEditingController(), "isDone": false},
    {"controller": TextEditingController(), "isDone": false},
    {"controller": TextEditingController(), "isDone": false},
  ];

  @override
  Widget build(BuildContext context) {
    // Definimos las pantallas dentro del build para que siempre reciban las listas actualizadas
    final List<Widget> _screens = [
      DashboardScreen(habits: _sharedHabits, priorities: _sharedPriorities),
      JournalScreen(habits: _sharedHabits),
    ];

    return Scaffold(
      body: IndexedStack( // Usar IndexedStack mantiene el estado de las pestañas mejor
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white24,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny_outlined), label: "Hoy"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Journal"),
        ],
      ),
    );
  }
}