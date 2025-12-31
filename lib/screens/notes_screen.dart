import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';

class NotesScreen extends StatefulWidget {
  final TextEditingController controller;
  const NotesScreen({super.key, required this.controller});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  void _loadSavedImage() async {
    String? path = await StorageService.loadImagePath();
    if (path != null && path.isNotEmpty) {
      File imageFile = File(path);
      if (await imageFile.exists()) {
        setState(() => _selectedImage = imageFile);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
        await StorageService.saveImagePath(pickedFile.path);
      }
    } catch (e) {
      debugPrint("Error al subir foto: $e");
    }
  }

  Future<void> _removeImage() async {
    setState(() => _selectedImage = null);
    await StorageService.saveImagePath(""); 
  }

  void _clearNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text("¿Limpiar nota?", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("Se borrará todo el texto de hoy.", style: TextStyle(color: Colors.white38, fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR", style: TextStyle(color: Colors.white24))),
          TextButton(
            onPressed: () {
              widget.controller.clear();
              Navigator.pop(context);
            }, 
            child: const Text("BORRAR", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> days = List.generate(14, (i) => DateTime.now().subtract(Duration(days: i)));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: const Text("DIARIO", style: TextStyle(fontSize: 10, letterSpacing: 4, color: Colors.white24, fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white38, size: 18), 
          onPressed: () => Navigator.pop(context)
        ),
        actions: [
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white12, size: 20),
              onPressed: _clearNote,
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        itemCount: days.length,
        itemBuilder: (context, index) {
          DateTime date = days[index];
          bool isToday = index == 0;
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // COLUMNA IZQUIERDA: FECHA
                SizedBox(
                  width: 45,
                  child: Column(
                    children: [
                      Text(
                        date.day.toString().padLeft(2, '0'),
                        style: TextStyle(
                          color: isToday ? Colors.white : Colors.white12,
                          fontSize: 18,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      Text(
                        getMonth(date.month),
                        style: TextStyle(
                          color: isToday ? Colors.white54 : Colors.white10,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (index != days.length - 1)
                        Expanded(
                          child: Container(
                            width: 0.5, 
                            color: Colors.white.withOpacity(0.05), 
                            margin: const EdgeInsets.symmetric(vertical: 10)
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // COLUMNA DERECHA: CONTENIDO
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 35),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isToday) ...[
                              Text(
                                "PENSAMIENTOS",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: widget.controller,
                                maxLines: null,
                                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6, fontWeight: FontWeight.w300),
                                decoration: const InputDecoration(
                                  hintText: "Escribe algo hoy...",
                                  hintStyle: TextStyle(color: Colors.white10),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildImageSection(),
                            ] else
                              const Text(
                                "Sin pensamientos registrados.",
                                style: TextStyle(color: Colors.white10, fontSize: 13, fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    if (_selectedImage != null) {
      return Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.white.withOpacity(0.1), size: 18),
            const SizedBox(width: 10),
            Text("Añadir foto del día", style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  String getMonth(int m) => ["ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"][m - 1];
}