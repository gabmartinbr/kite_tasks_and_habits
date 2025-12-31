import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Importante
import '../models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  final List<Habit> existingHabits;
  final Function(Habit) onSave;

  const AddHabitScreen({
    super.key,
    required this.existingHabits,
    required this.onSave,
  });

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _controller = TextEditingController();
  late Color _selectedColor;

  final List<Color> _colors = [
    const Color(0xFFFFB7B2),
    const Color(0xFFFFDAC1),
    const Color(0xFFE2F0CB),
    const Color(0xFFB5EAD7),
    const Color(0xFFC7CEEA),
    const Color(0xFFF9CCE3),
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors[0];
  }

  // Función para abrir el popup RGB
  void _pickCustomColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ELIGE UN COLOR",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 25),
            // El HueRingPicker es el selector circular minimalista
            HueRingPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
              enableAlpha: false, // Sin transparencias
              displayThumbColor: false, // Para que sea aún más limpio
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "SELECCIONAR",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
        top: 25,
        left: 25,
        right: 25,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "NUEVO HÁBITO",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
            decoration: const InputDecoration(
              hintText: "Nombre del hábito...",
              hintStyle: TextStyle(color: Colors.white10),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "COLOR",
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Colores Pastel predefinidos
                ..._colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 35,
                      height: 35,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),

                // BOTÓN ADICIONAL PARA RGB
                GestureDetector(
                  onTap: _pickCustomColor,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white10, width: 1),
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.green, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.colorize_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  widget.onSave(
                    Habit(
                      name: _controller.text,
                      completedDates: [],
                      colorValue: _selectedColor.value,
                      createdAt: DateTime.now(),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "GUARDAR",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
