import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- PINTOR DE ONDAS Y SELECTOR ---
class LiquidPainter extends CustomPainter {
  final double smoothProgress;
  final double waveOffset;
  final double selectionProgress;
  final bool isSelecting;

  LiquidPainter({
    required this.smoothProgress,
    required this.waveOffset,
    required this.selectionProgress,
    required this.isSelecting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final accentColor = const Color.fromARGB(255, 218, 218, 218);

    final Paint glassPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius, glassPaint);

    if (isSelecting) {
      final Paint sliderPathPaint = Paint()
        ..color = accentColor.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius + 15, sliderPathPaint);

      final Paint sliderPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4;

      double sweepAngle = 2 * pi * selectionProgress;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius + 15), -pi / 2, sweepAngle, false, sliderPaint);

      final double knobAngle = sweepAngle - pi / 2;
      final Offset knobOffset = Offset(center.dx + (radius + 15) * cos(knobAngle), center.dy + (radius + 15) * sin(knobAngle));
      canvas.drawCircle(knobOffset, 5, Paint()..color = Colors.white);
    }

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    
    if (smoothProgress > 0) {
      // --- CORRECCIÓN AQUÍ ---
      // 1. Añadimos un pequeño offset negativo (-10) para que el nivel suba más allá del borde superior al final.
      // 2. Multiplicamos la amplitud por (1 - smoothProgress) para que las ondas se calmen al llegar arriba.
      final double currentLevel = size.height - (size.height * smoothProgress) - (smoothProgress > 0.9 ? 10 : 0);
      final double adaptiveAmplitude = 6.0 * (1.0 - smoothProgress); 

      _drawWave(canvas, size, currentLevel, waveOffset * 0.8, const Color.fromARGB(255, 153, 153, 153).withOpacity(0.15), adaptiveAmplitude);
      _drawWave(canvas, size, currentLevel, waveOffset + pi, const Color.fromARGB(255, 153, 153, 153).withOpacity(0.35), adaptiveAmplitude);
    }
    
    canvas.restore();
  }

  void _drawWave(Canvas canvas, Size size, double level, double offset, Color color, double amplitude) {
    final Path path = Path();
    path.moveTo(0, level);
    for (double i = 0; i <= size.width; i++) {
      double radians = (i / size.width) * 2 * pi;
      double y = level + sin(radians + offset) * amplitude;
      path.lineTo(i, y);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) => true;
}

// --- PINTOR DEL GRÁFICO (Eje Y hasta 15) ---
class ChartPainter extends CustomPainter {
  final List<int> data;
  final bool isMonthly;
  ChartPainter(this.data, {this.isMonthly = false});

  @override
  void paint(Canvas canvas, Size size) {
    final int maxData = data.isNotEmpty ? data.reduce(max) : 0;
    // Escala base en 15. Si se supera, se ajusta automáticamente.
    final double maxVal = (maxData > 13 ? (maxData + 2).toDouble() : 15.0);
    
    final double paddingLeft = 25.0; 
    final double chartWidth = size.width - paddingLeft;
    final double chartHeight = size.height;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final TextStyle labelStyle = TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9);

    for (int i = 0; i <= 3; i++) {
      double yVal = (maxVal / 3) * i;
      double yPos = chartHeight - (yVal / maxVal * chartHeight);
      
      textPainter.text = TextSpan(text: yVal.toInt().toString(), style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, yPos - 6));

      canvas.drawLine(
        Offset(paddingLeft, yPos),
        Offset(size.width, yPos),
        Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 0.5,
      );
    }

    if (data.isEmpty || data.every((e) => e == 0)) return;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color.fromARGB(255, 128, 128, 128).withOpacity(0.4), Colors.transparent],
      ).createShader(Rect.fromLTWH(paddingLeft, 0, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color.fromARGB(255, 196, 196, 196)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isMonthly ? 1.2 : 2.5;

    final path = Path();
    final double stepX = chartWidth / (data.length - 1);

    path.moveTo(paddingLeft, chartHeight - (data[0] / maxVal * chartHeight));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(paddingLeft + (i * stepX), chartHeight - (data[i] / maxVal * chartHeight));
    }

    canvas.drawPath(path, linePaint);
    path.lineTo(paddingLeft + (data.length - 1) * stepX, chartHeight);
    path.lineTo(paddingLeft, chartHeight);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> with SingleTickerProviderStateMixin {
  int _totalSeconds = 1500;
  int _secondsDisplay = 1500;
  bool _isRunning = false;
  double _waveOffset = 0.0;
  double _selectionProgress = 25 / 180;

  late AnimationController _mainController;
  
  int dailyPomodoros = 0;
  int weeklyPomodoros = 0;
  int monthlyPomodoros = 0;
  List<int> weeklyData = [0, 0, 0, 0, 0, 0, 0];
  List<int> monthlyData = List.generate(30, (index) => 0);

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _mainController = AnimationController(vsync: this, duration: Duration(seconds: _totalSeconds))..addListener(_updateScene);
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyPomodoros = prefs.getInt('daily_pomo') ?? 0;
      weeklyPomodoros = prefs.getInt('weekly_pomo') ?? 0;
      monthlyPomodoros = prefs.getInt('monthly_pomo') ?? 0;
      List<String>? savedWeekly = prefs.getStringList('weekly_list');
      if (savedWeekly != null) weeklyData = savedWeekly.map((e) => int.parse(e)).toList();
      List<String>? savedMonthly = prefs.getStringList('monthly_list');
      if (savedMonthly != null) monthlyData = savedMonthly.map((e) => int.parse(e)).toList();
    });
  }

  Future<void> _incrementAndSave() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dayIdx = now.weekday - 1;

    setState(() {
      dailyPomodoros++;
      weeklyPomodoros++;
      monthlyPomodoros++;
      weeklyData[dayIdx]++;
      monthlyData[now.day - 1]++;
    });

    await prefs.setInt('daily_pomo', dailyPomodoros);
    await prefs.setInt('weekly_pomo', weeklyPomodoros);
    await prefs.setInt('monthly_pomo', monthlyPomodoros);
    await prefs.setStringList('weekly_list', weeklyData.map((e) => e.toString()).toList());
    await prefs.setStringList('monthly_list', monthlyData.map((e) => e.toString()).toList());
  }

  void _updateScene() {
    if (!mounted) return;
    setState(() {
      _waveOffset += 0.04;
      _secondsDisplay = (_totalSeconds * (1.0 - _mainController.value)).ceil();
      if (_mainController.isCompleted && _isRunning) {
        _isRunning = false;
        _incrementAndSave();
      }
    });
  }

  void _handlePointer(Offset localPosition) {
    if (_isRunning || _mainController.value > 0) return;
    final center = const Offset(140, 140);
    final double angle = atan2(localPosition.dy - center.dy, localPosition.dx - center.dx);
    double normalizedAngle = (angle + pi / 2) % (2 * pi);
    if (normalizedAngle < 0) normalizedAngle += 2 * pi;

    setState(() {
      double progress = normalizedAngle / (2 * pi);
      int minutes = (progress * 180).round();
      if (minutes < 1) minutes = 1; 
      _selectionProgress = minutes / 180;
      _totalSeconds = minutes * 60;
      _secondsDisplay = _totalSeconds;
      _mainController.duration = Duration(seconds: _totalSeconds);
    });
  }

  String _formatTime(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    if (h > 0) return "$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    bool showSlider = !_isRunning && _mainController.value == 0;
    return Expanded(
      child: Column(
        children: [
          const Spacer(flex: 6), // Gran espacio superior para centrar
          
          // CRONÓMETRO (Centrado verticalmente con los Spacers)
          GestureDetector(
            onPanUpdate: (details) => _handlePointer(details.localPosition),
            onPanStart: (details) => _handlePointer(details.localPosition),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 280, height: 280, child: CustomPaint(painter: LiquidPainter(smoothProgress: _mainController.value, waveOffset: _waveOffset, selectionProgress: _selectionProgress, isSelecting: showSlider))),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formatTime(_secondsDisplay), style: TextStyle(color: Colors.white, fontSize: _secondsDisplay >= 3600 ? 52 : 62, fontWeight: FontWeight.w100, letterSpacing: -3)),
                    Text(_isRunning ? "ENFOQUE" : (showSlider ? "AJUSTAR" : "PAUSADO"), style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 6, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // BOTONES DE ACCIÓN
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _btn(icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, onTap: () { setState(() => _isRunning = !_isRunning); _isRunning ? _mainController.forward() : _mainController.stop(); }, isPrimary: true),
              const SizedBox(width: 20),
              _btn(icon: Icons.refresh_rounded, onTap: () { _mainController.reset(); setState(() { _isRunning = false; _secondsDisplay = _totalSeconds; }); }, isPrimary: false),
            ],
          ),

          const Spacer(flex: 5), // Empuja las stats hacia la zona inferior

          // SECCIÓN INFERIOR
          _buildStatsCard(),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showStatsPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.analytics_outlined, color: Color.fromARGB(255, 214, 214, 214), size: 16),
                  SizedBox(width: 8),
                  Text("VER RENDIMIENTO", style: TextStyle(color: Color.fromARGB(255, 189, 189, 189), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30), // Margen final
        ],
      ),
    );
  }

  // --- MÉTODOS DE APOYO ---

  void _showStatsPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(color: const Color(0xFF121212), borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), border: Border.all(color: Colors.white10)),
        padding: const EdgeInsets.all(25),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const TabBar(dividerColor: Colors.transparent, indicatorColor: Color.fromARGB(255, 197, 197, 197), labelColor: Colors.white, unselectedLabelColor: Colors.white24, tabs: [Tab(text: "Semana"), Tab(text: "Mes")]),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildChartContent("RENDIMIENTO SEMANAL", weeklyData, ['L', 'M', 'X', 'J', 'V', 'S', 'D'], false),
                    _buildChartContent("RENDIMIENTO 30 DÍAS", monthlyData, ['S1', 'S2', 'S3', 'S4'], true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContent(String title, List<int> data, List<String> labels, bool isMonthly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: SizedBox(height: 140, width: double.infinity, child: CustomPaint(painter: ChartPainter(data, isMonthly: isMonthly))),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: labels.map((l) => Text(l, style: const TextStyle(color: Colors.white12, fontSize: 10))).toList()),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_stat("Hoy", dailyPomodoros), _stat("Semana", weeklyPomodoros), _stat("Mes", monthlyPomodoros)]),
    );
  }

  Widget _stat(String label, int val) => Column(children: [Text(val.toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text(label.toUpperCase(), style: const TextStyle(color: Colors.white24, fontSize: 8))]);

  Widget _btn({required IconData icon, required VoidCallback onTap, required bool isPrimary}) => GestureDetector(
    onTap: onTap,
    child: Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: isPrimary ? Colors.white : Colors.white.withOpacity(0.05), shape: BoxShape.circle), child: Icon(icon, color: isPrimary ? Colors.black : Colors.white, size: 28)),
  );
}