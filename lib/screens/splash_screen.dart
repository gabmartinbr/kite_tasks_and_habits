import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  String quote = ""; 
  String author = "";
  late AnimationController _controller;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            quote = data[0]['q'];
            author = data[0]['a'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          quote = "La disciplina es el puente entre metas y logros.";
          author = "Jim Rohn";
        });
      }
    }

    final habits = await StorageService.loadHabits();
    final savedPrioritiesData = await StorageService.loadPriorities();
    
    List<Map<String, dynamic>> processedPriorities = List.generate(3, (i) {
      String text = "";
      bool done = false;
      if (i < savedPrioritiesData.length) {
        text = savedPrioritiesData[i]['text'] ?? "";
        done = savedPrioritiesData[i]['isDone'] ?? false;
      }
      return {
        'controller': TextEditingController(text: text),
        'isDone': done,
      };
    });

    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(
          habits: habits,
          priorities: processedPriorities,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SOLO EL LOGO SE MUEVE
            AnimatedBuilder(
              animation: _floatingAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatingAnimation.value),
                  child: Image.asset(
                    'assets/kite_logo.webp',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
            
            // TEXTO KITE ESTÁTICO (MINIMALISTA)
            const SizedBox(height: 15),
            Text(
              "KITE",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 26,
                fontWeight: FontWeight.w200, 
                letterSpacing: 15,           
              ),
            ),
            
            const SizedBox(height: 80),
            
            // MANTRA
            if (quote.isNotEmpty) ...[
              Text(
                "\"$quote\"",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                author.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            const SizedBox(height: 60),
            
            const CircularProgressIndicator(
              color: Colors.white10,
              strokeWidth: 1.5,
            ),
          ],
        ),
      ),
    );
  }
}