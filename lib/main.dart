import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/splash_screen.dart'; // Importamos la nueva splash

void main() async {
  // 1. Asegurar inicialización de bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar fechas en español
  await initializeDateFormatting('es', null);

  // 3. Arrancar la app directamente (la carga de datos ahora ocurre en la Splash)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kite Habits',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'SF Pro Display', 
        scaffoldBackgroundColor: Colors.black, // Forzamos fondo negro puro
      ),
      // El home ahora es la SplashScreen
      home: const SplashScreen(),
    );
  }
}