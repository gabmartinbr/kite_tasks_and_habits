import 'package:flutter/material.dart';

class Habit {
  String name;
  Color color;
  List<bool> activeDays; 
  int currentStreak;
  bool isCompletedToday;
  List<DateTime> completedDates; // Historial de días completados
  DateTime createdAt;
  DateTime? deletedAt;

  Habit({
    required this.name,
    required this.color,
    required this.activeDays,
    this.currentStreak = 0,
    this.isCompletedToday = false,
    List<DateTime>? completedDates,
    required this.createdAt,
    this.deletedAt,
  }) : completedDates = completedDates ?? [];
}