import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  final Function(Habit) onSave;
  final List<Habit> existingHabits;
  const AddHabitScreen({super.key, required this.onSave, required this.existingHabits});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _controller = TextEditingController();
  List<bool> _days = List.filled(7, true);
  Color _selColor = const Color(0xFFFFB7B2);
  final List<Color> _pastelColors = [const Color(0xFFFFB7B2), const Color(0xFFFFDAC1), const Color(0xFFE2F0CB), const Color(0xFFB5EAD7), const Color(0xFFC7CEEA)];

  void _openFullColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        content: SingleChildScrollView(child: ColorPicker(pickerColor: _selColor, onColorChanged: (c) => setState(() => _selColor = c.withOpacity(1.0)), enableAlpha: false, labelTypes: const [])),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30, left: 25, right: 25, bottom: MediaQuery.of(context).viewInsets.bottom + 30),
      decoration: const BoxDecoration(color: Color(0xFF1C1C1E), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("NOMBRE DEL HÁBITO", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          TextField(controller: _controller, style: const TextStyle(color: Colors.white, fontSize: 20), decoration: const InputDecoration(hintText: "Ej. Leer", hintStyle: TextStyle(color: Colors.white10), border: InputBorder.none)),
          const SizedBox(height: 25),
          const Text("COLOR", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(height: 50, child: ListView(scrollDirection: Axis.horizontal, children: [
            ..._pastelColors.map((c) => GestureDetector(onTap: () => setState(() => _selColor = c), child: Container(width: 45, margin: const EdgeInsets.only(right: 12), decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: _selColor == c ? Border.all(color: Colors.white, width: 3) : null)))),
            GestureDetector(onTap: _openFullColorPicker, child: Container(width: 45, decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white))),
          ])),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _selColor, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.onSave(Habit(name: _controller.text, color: _selColor, activeDays: _days, createdAt: DateTime.now()));
                Navigator.pop(context);
              }
            },
            child: const Text("CREAR HÁBITO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}