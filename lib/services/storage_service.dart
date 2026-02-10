import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';

class StorageService {
  // --- UTILIDAD DE FECHA ---
  //static String _getDateKey(DateTime date) => "${date.year}_${date.month}_${date.day}";

  // --- MODO PRUEBA (VIAJE EN EL TIEMPO) ---
  // Para probar mañana, descomenta la línea de testDate y comenta la de arriba
  
  static String _getDateKey(DateTime date) {
    DateTime testDate = date.add(const Duration(days: 1)); 
    return "${testDate.year}_${testDate.month}_${testDate.day}";
  }
  

  // --- GUARDAR Y CARGAR TEXTO (CON FECHA) ---
  static Future<void> saveDailyNote(String note, {DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final day = date ?? DateTime.now();
    await prefs.setString('daily_note_text_${_getDateKey(day)}', note);
  }

  static Future<String> loadDailyNote({DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final day = date ?? DateTime.now();
    return prefs.getString('daily_note_text_${_getDateKey(day)}') ?? "";
  }

  // --- GUARDAR Y CARGAR RUTA DE IMAGEN (CON FECHA) ---
  static Future<void> saveImagePath(String path, {DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final day = date ?? DateTime.now();
    await prefs.setString('daily_note_image_${_getDateKey(day)}', path);
  }

  static Future<String?> loadImagePath({DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final day = date ?? DateTime.now();
    return prefs.getString('daily_note_image_${_getDateKey(day)}');
  }

  // --- HÁBITOS ---
  static const String _habitsKey = 'habits_data';

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(habits.map((h) => h.toJson()).toList());
    await prefs.setString(_habitsKey, encodedData);
  }

  static Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsString = prefs.getString(_habitsKey);
    if (habitsString == null) return [];
    final List<dynamic> jsonData = jsonDecode(habitsString);
    return jsonData.map((h) => Habit.fromJson(h)).toList();
  }

  // --- PRIORIDADES (MODIFICADO PARA TAREAS DIARIAS) ---
  // Ahora la clave de las prioridades también depende de la fecha
  static Future<void> savePriorities(List<Map<String, dynamic>> priorities, {DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final day = date ?? DateTime.now();
    
    final List<Map<String, dynamic>> dataToSave = priorities
        .map((p) => {'text': p['controller'].text, 'isDone': p['isDone']})
        .toList();
    
    // Guardamos con una clave única por día
    await prefs.setString('priorities_data_${_getDateKey(day)}', jsonEncode(dataToSave));
  }

  static Future<List<Map<String, dynamic>>> loadPriorities({DateTime? date}) async {
    final prefs = await SharedPreferences.getInstance();
    final day = date ?? DateTime.now();
    
    // Cargamos la clave específica de ese día
    final String? dataString = prefs.getString('priorities_data_${_getDateKey(day)}');
    
    if (dataString == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(dataString));
  }

  // --- OTROS ---
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_time') ?? true;
  }

  static Future<void> setTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
  }
}