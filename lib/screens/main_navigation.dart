import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'journal_screen.dart';
import 'stats_screen.dart'; 
import '../models/habit_model.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  
  // Listas compartidas que fluyen por toda la app
  final List<Habit> _sharedHabits = [];
  final List<Map<String, dynamic>> _sharedPriorities = [
    {"controller": TextEditingController(), "isDone": false},
    {"controller": TextEditingController(), "isDone": false},
    {"controller": TextEditingController(), "isDone": false},
  ];

  @override
  Widget build(BuildContext context) {
    // Definimos el orden: Hoy (0), Journal (1), Stats (2)
    final List<Widget> _screens = [
      DashboardScreen(habits: _sharedHabits, priorities: _sharedPriorities),
      JournalScreen(habits: _sharedHabits),
      StatsScreen(habits: _sharedHabits, priorities: _sharedPriorities),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white24,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wb_sunny_outlined), 
            activeIcon: Icon(Icons.wb_sunny), 
            label: "Hoy"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined), 
            activeIcon: Icon(Icons.calendar_today),
            label: "Journal"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded), 
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: "Stats"
          ),
        ],
      ),
    );
  }
}