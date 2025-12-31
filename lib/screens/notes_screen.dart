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

  @override
  Widget build(BuildContext context) {
    // Generamos los últimos 14 días para el historial
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
                // --- COLUMNA IZQUIERDA: FECHA ---
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
                          color: isToday ? const Color.fromARGB(255, 211, 211, 211).withOpacity(0.5) : Colors.white10,
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

                // --- COLUMNA DERECHA: CONTENIDO ---
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
                              TextField(
                                controller: widget.controller,
                                maxLines: null,
                                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6, fontWeight: FontWeight.w300),
                                decoration: const InputDecoration(
                                  hintText: "Escribe algo hoy...",
                                  hintStyle: TextStyle(color: Colors.white10),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 15),
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
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: _selectedImage != null ? 200 : 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          image: _selectedImage != null 
            ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) 
            : null,
        ),
        child: _selectedImage == null 
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: Colors.white.withOpacity(0.1), size: 16),
                const SizedBox(width: 8),
                Text("Añadir foto", style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 12)),
              ],
            )
          : null,
      ),
    );
  }

  String getMonth(int m) => ["ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"][m - 1];
}