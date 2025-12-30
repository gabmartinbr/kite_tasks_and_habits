import 'package:flutter/material.dart';

class Habit {
  String name;
  Color color;
  List<bool> activeDays; 
  int currentStreak;
  bool isCompletedToday;
  DateTime createdAt;    // Fecha de nacimiento del hábito
  DateTime? deletedAt;   // Fecha en la que se "borró"

  Habit({
    required this.name,
    required this.color,
    required this.activeDays,
    this.currentStreak = 0,
    this.isCompletedToday = false,
    required this.createdAt,
    this.deletedAt,
  });
}