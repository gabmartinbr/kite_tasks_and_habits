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
  // Mapas para almacenar los datos de cada día en memoria
  final Map<int, String> _notesHistory = {};
  final Map<int, File?> _imagesHistory = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllHistory();
  }

  Future<void> _loadAllHistory() async {
    // Cargamos datos para los últimos 14 días
    for (int i = 0; i < 14; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      
      // Cargar nota
      String note = await StorageService.loadDailyNote(date: date);
      _notesHistory[i] = note;

      // Cargar imagen
      String? path = await StorageService.loadImagePath(date: date);
      if (path != null && path.isNotEmpty) {
        File imageFile = File(path);
        if (await imageFile.exists()) {
          _imagesHistory[i] = imageFile;
        }
      }
    }
    
    // El controlador principal siempre debe tener la nota de HOY (índice 0)
    widget.controller.text = _notesHistory[0] ?? "";
    
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (pickedFile != null) {
      await StorageService.saveImagePath(pickedFile.path); // Guarda para hoy
      setState(() {
        _imagesHistory[0] = File(pickedFile.path);
      });
    }
  }

  Future<void> _removeImage() async {
    await StorageService.saveImagePath(""); 
    setState(() => _imagesHistory[0] = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));

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
                _buildDateColumn(date, isToday, index == days.length - 1),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildNoteCard(index, isToday),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateColumn(DateTime date, bool isToday, bool isLast) {
    return SizedBox(
      width: 45,
      child: Column(
        children: [
          Text(date.day.toString().padLeft(2, '0'),
            style: TextStyle(color: isToday ? Colors.white : Colors.white12, fontSize: 18, fontWeight: FontWeight.w200)),
          Text(["ENE", "FEB", "MAR", "ABR", "MAY", "JUN", "JUL", "AGO", "SEP", "OCT", "NOV", "DIC"][date.month - 1],
            style: TextStyle(color: isToday ? Colors.white54 : Colors.white10, fontSize: 8, fontWeight: FontWeight.bold)),
          if (!isLast) Expanded(child: Container(width: 0.5, color: Colors.white.withOpacity(0.05), margin: const EdgeInsets.symmetric(vertical: 10))),
        ],
      ),
    );
  }

  Widget _buildNoteCard(int index, bool isToday) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 35),
      decoration: BoxDecoration(color: const Color(0xFF1C1C1E), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isToday ? "PENSAMIENTOS" : "MEMORIA", 
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          if (isToday)
            TextField(
              controller: widget.controller,
              maxLines: null,
              onChanged: (val) => StorageService.saveDailyNote(val),
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6, fontWeight: FontWeight.w300),
              decoration: const InputDecoration(hintText: "Escribe algo hoy...", hintStyle: TextStyle(color: Colors.white10), border: InputBorder.none, isDense: true),
            )
          else
            Text(
              _notesHistory[index]?.isNotEmpty == true ? _notesHistory[index]! : "Sin pensamientos registrados.",
              style: TextStyle(color: _notesHistory[index]?.isNotEmpty == true ? Colors.white70 : Colors.white10, fontSize: 15, height: 1.6, fontStyle: _notesHistory[index]?.isEmpty == true ? FontStyle.italic : FontStyle.normal),
            ),
          const SizedBox(height: 20),
          _buildImageSection(index, isToday),
        ],
      ),
    );
  }

  Widget _buildImageSection(int index, bool isToday) {
    File? img = _imagesHistory[index];
    if (img != null) {
      return Stack(
        children: [
          Container(
            height: 180, width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: FileImage(img), fit: BoxFit.cover)),
          ),
          if (isToday) Positioned(top: 10, right: 10, child: GestureDetector(onTap: _removeImage, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, color: Colors.white, size: 16)))),
        ],
      );
    }
    if (isToday) {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 55, width: double.infinity,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, color: Colors.white.withOpacity(0.1), size: 18), const SizedBox(width: 10), Text("Añadir foto", style: TextStyle(color: Colors.white.withOpacity(0.1), fontSize: 12))]),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}