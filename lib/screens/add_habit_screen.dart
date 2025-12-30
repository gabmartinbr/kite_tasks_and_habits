import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Importante añadir la dependencia
import '../models/habit_model.dart';

class AddHabitScreen extends StatefulWidget {
  final Function(Habit) onSave;
  final List<Habit> existingHabits;

  const AddHabitScreen({
    super.key, 
    required this.onSave, 
    required this.existingHabits
  });

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _controller = TextEditingController();
  List<bool> _days = List.filled(7, true);
  final List<String> _weekDays = ["L", "M", "X", "J", "V", "S", "D"];

  // Paleta inicial de colores pasteles
  final List<Color> _pastelColors = [
    const Color(0xFFFFB7B2), const Color(0xFFFFDAC1),
    const Color(0xFFE2F0CB), const Color(0xFFB5EAD7),
    const Color(0xFFC7CEEA), const Color(0xFFF3D1F4),
  ];

  late Color _selColor;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selColor = _pastelColors[0];
  }

  // Función para abrir el selector RGB
  void _openFullColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E), // Fondo oscuro para que combine
        title: const Text("Color personalizado", style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selColor,
            onColorChanged: (color) {
              setState(() => _selColor = color.withOpacity(1.0)); // Forzamos solidez
            },
            enableAlpha: false, // <--- ELIMINA LA BARRA DE OPACIDAD
            labelTypes: const [], // <--- ELIMINA LOS NÚMEROS Y CÓDIGOS (Más minimalista)
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            child: const Text("ACEPTAR", style: TextStyle(color: Colors.blueAccent)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _validateAndSave() {
    final String name = _controller.text.trim();
    
    if (name.isEmpty) {
      setState(() => _errorMessage = "Ponle un nombre");
      return;
    }

    // RESTRICCIÓN DE OPACIDAD: 
    // .withOpacity(1.0) asegura que el color sea sólido, 
    // sin importar qué eligió el usuario en el picker.
    final Color solidColor = _selColor.withOpacity(1.0);

    widget.onSave(Habit(
      name: name,
      color: solidColor, // Guardamos la versión sólida
      activeDays: _days,
      createdAt: DateTime.now(),
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 30, left: 25, right: 25, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 30
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E), 
        borderRadius: BorderRadius.vertical(top: Radius.circular(30))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel("NOMBRE DEL HÁBITO"),
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            decoration: InputDecoration(
              hintText: "Ej. Leer", 
              hintStyle: const TextStyle(color: Colors.white10), 
              border: InputBorder.none,
              errorText: _errorMessage,
            ),
          ),
          const SizedBox(height: 25),
          _sectionLabel("FRECUENCIA"),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) => _buildDayToggle(i)),
          ),
          const SizedBox(height: 30),
          _sectionLabel("COLOR"),
          const SizedBox(height: 15),
          
          // LISTA DESLIZABLE DE COLORES + BOTÓN MÁS
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pastelColors.length + 1, // +1 para el botón de añadir
              itemBuilder: (context, index) {
                if (index == _pastelColors.length) {
                  return _buildAddColorButton();
                }
                return _buildColorCircle(_pastelColors[index]);
              },
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selColor, 
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: _validateAndSave,
            child: const Text("CREAR HÁBITO", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    bool isSelected = _selColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selColor = color),
      child: Container(
        width: 45,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.black54, size: 20) : null,
      ),
    );
  }

  Widget _buildAddColorButton() {
    return GestureDetector(
      onTap: _openFullColorPicker,
      child: Container(
        width: 45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white70),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text, 
    style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2));

  Widget _buildDayToggle(int index) {
    bool selected = _days[index];
    return GestureDetector(
      onTap: () => setState(() => _days[index] = !_days[index]),
      child: Container(
        width: 38, height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? _selColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(_weekDays[index], 
          style: TextStyle(color: selected ? Colors.black : Colors.white38, fontWeight: FontWeight.bold)),
      ),
    );
  }
}