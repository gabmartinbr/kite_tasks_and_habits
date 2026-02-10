import 'package:flutter/material.dart';

class Habit {
  String name;
  List<DateTime> completedDates;
  int colorValue; // Guardamos el número del color (persistente)
  DateTime? deletedAt;
  DateTime createdAt;

  Habit({
    required this.name,
    required this.completedDates,
    required this.colorValue,
    this.deletedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // --- GETTERS (No se pasan al constructor, se calculan) ---

  // Convierte el int guardado en un objeto Color para la UI
  Color get color => Color(colorValue);

  // Calcula si está completado hoy
  bool get isCompletedToday {
    final now = DateTime.now();
    return completedDates.any((d) => 
      d.year == now.year && d.month == now.month && d.day == now.day);
  }

  // Calcula la racha actual automáticamente
  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    
    // Ordenamos las fechas de más reciente a más antigua
    List<DateTime> sortedDates = List.from(completedDates)..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime checkDate = isCompletedToday ? today : today.subtract(const Duration(days: 1));

    for (var date in sortedDates) {
      DateTime dateOnly = DateTime(date.year, date.month, date.day);
      if (dateOnly == checkDate) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (dateOnly.isBefore(checkDate)) {
        break;
      }
    }
    return streak;
  }

  // --- PERSISTENCIA JSON ---

  Map<String, dynamic> toJson() => {
    'name': name,
    'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
    'colorValue': colorValue,
    'deletedAt': deletedAt?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    name: json['name'],
    completedDates: (json['completedDates'] as List)
        .map((d) => DateTime.parse(d))
        .toList(),
    colorValue: json['colorValue'],
    deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
  );
}