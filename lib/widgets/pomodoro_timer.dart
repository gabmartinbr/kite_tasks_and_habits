import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

// --- PINTORES ---
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

    canvas.drawCircle(center, radius, Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke);

    if (isSelecting) {
      canvas.drawCircle(center, radius + 15, Paint()..color = accentColor.withOpacity(0.15)..style = PaintingStyle.stroke..strokeWidth = 2);
      double sweepAngle = 2 * pi * selectionProgress;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius + 15), -pi / 2, sweepAngle, false, 
        Paint()..color = accentColor..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeWidth = 4);
    }

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    if (smoothProgress > 0) {
      final double currentLevel = size.height - (size.height * smoothProgress) - (smoothProgress > 0.9 ? 10 : 0);
      final double adaptiveAmplitude = 6.0 * (1.0 - smoothProgress); 
      _drawWave(canvas, size, currentLevel, waveOffset * 0.8, const Color.fromARGB(255, 153, 153, 153).withOpacity(0.15), adaptiveAmplitude);
      _drawWave(canvas, size, currentLevel, waveOffset + pi, const Color.fromARGB(255, 153, 153, 153).withOpacity(0.35), adaptiveAmplitude);
    }
    canvas.restore();
  }

  void _drawWave(Canvas canvas, Size size, double level, double offset, Color color, double amplitude) {
    final Path path = Path()..moveTo(0, level);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, level + sin((i / size.width) * 2 * pi + offset) * amplitude);
    }
    path..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChartPainter extends CustomPainter {
  final List<int> data;
  final bool isMonthly;
  ChartPainter(this.data, {this.isMonthly = false});

  @override
  void paint(Canvas canvas, Size size) {
    final int maxData = data.isNotEmpty ? data.reduce(max) : 0;
    final double maxVal = (maxData > 13 ? (maxData + 2).toDouble() : 15.0);
    final double paddingLeft = 25.0; 
    final double chartWidth = size.width - paddingLeft;
    final double chartHeight = size.height;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i <= 3; i++) {
      double yVal = (maxVal / 3) * i;
      double yPos = chartHeight - (yVal / maxVal * chartHeight);
      textPainter.text = TextSpan(text: yVal.toInt().toString(), style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9));
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, yPos - 6));
      canvas.drawLine(Offset(paddingLeft, yPos), Offset(size.width, yPos), Paint()..color = Colors.white.withOpacity(0.05));
    }

    if (data.isEmpty || data.every((e) => e == 0)) return;

    final double stepX = chartWidth / (data.length - 1);
    final path = Path()..moveTo(paddingLeft, chartHeight - (data[0] / maxVal * chartHeight));
    for (int i = 1; i < data.length; i++) {
      path.lineTo(paddingLeft + (i * stepX), chartHeight - (data[i] / maxVal * chartHeight));
    }
    canvas.drawPath(path, Paint()..color = const Color.fromARGB(255, 196, 196, 196)..style = PaintingStyle.stroke..strokeWidth = isMonthly ? 1.2 : 2.5);
  }

  @override 
  bool shouldRepaint(covariant ChartPainter oldDelegate) => oldDelegate.data != data;
}

// --- WIDGET PRINCIPAL ---
class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});
  @override State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> with SingleTickerProviderStateMixin {
  int _totalSeconds = 1500, _secondsDisplay = 1500;
  bool _isRunning = false;
  double _waveOffset = 0.0, _selectionProgress = 25 / 180;
  late AnimationController _mainController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  int dailyPomodoros = 0, weeklyPomodoros = 0, monthlyPomodoros = 0;
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
    if (!mounted) return;
    setState(() {
      dailyPomodoros = prefs.getInt('daily_pomo') ?? 0;
      weeklyPomodoros = prefs.getInt('weekly_pomo') ?? 0;
      monthlyPomodoros = prefs.getInt('monthly_pomo') ?? 0;
      
      List<String>? sw = prefs.getStringList('weekly_list');
      if (sw != null && sw.length == 7) {
        weeklyData = sw.map((e) => int.parse(e)).toList();
      }
      
      List<String>? sm = prefs.getStringList('monthly_list');
      if (sm != null && sm.length == 30) {
        monthlyData = sm.map((e) => int.parse(e)).toList();
      }
    });
  }

  Future<void> _incrementAndSave() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // Reproducir sonido al terminar
    await _audioPlayer.play(AssetSource('end_pomo.mp3'));

    setState(() {
      dailyPomodoros++;
      weeklyPomodoros++;
      monthlyPomodoros++;
      weeklyData[now.weekday - 1]++;
      monthlyData[(now.day - 1).clamp(0, 29)]++;
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
        HapticFeedback.vibrate();
      }
    });
  }

  void _handlePointer(Offset pos) {
    if (_isRunning || _mainController.value > 0) return;
    double angle = atan2(pos.dy - 140, pos.dx - 140);
    double normalized = (angle + pi / 2) % (2 * pi);
    if (normalized < 0) normalized += 2 * pi;
    setState(() {
      int minutes = ((normalized / (2 * pi)) * 180).round().clamp(1, 180);
      _selectionProgress = minutes / 180;
      _totalSeconds = minutes * 60;
      _secondsDisplay = _totalSeconds;
      _mainController.duration = Duration(seconds: _totalSeconds);
    });
  }

  String _formatTime(int s) {
    int mins = s ~/ 60;
    int secs = s % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    bool showSlider = !_isRunning && _mainController.value == 0;
    return Column(
      children: [
        const Spacer(flex: 6),
        GestureDetector(
          onPanUpdate: (d) => _handlePointer(d.localPosition),
          onPanStart: (d) => _handlePointer(d.localPosition),
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 280, height: 280, child: CustomPaint(painter: LiquidPainter(smoothProgress: _mainController.value, waveOffset: _waveOffset, selectionProgress: _selectionProgress, isSelecting: showSlider))),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_formatTime(_secondsDisplay), style: TextStyle(color: Colors.white, fontSize: _secondsDisplay >= 3600 ? 52 : 62, fontWeight: FontWeight.w100)),
              Text(_isRunning ? "ENFOQUE" : (showSlider ? "AJUSTAR" : "PAUSADO"), style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 6, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
        const SizedBox(height: 30),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _btn(
            icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, 
            onTap: () { 
              setState(() => _isRunning = !_isRunning); 
              _isRunning ? _mainController.forward() : _mainController.stop(); 
            }, 
            isPrimary: true
          ),
          const SizedBox(width: 20),
          _btn(
            icon: Icons.refresh_rounded, 
            onTap: () { 
              _mainController.reset(); 
              setState(() { _isRunning = false; _secondsDisplay = _totalSeconds; }); 
            }, 
            isPrimary: false
          ),
        ]),
        const Spacer(flex: 5),
        _buildStatsCard(),
        const SizedBox(height: 12),
        _buildRendimientoBtn(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildRendimientoBtn() => GestureDetector(
    onTap: _showStatsPopup,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15)),
      child: const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.analytics_outlined, color: Colors.white24, size: 16),
        SizedBox(width: 8),
        Text("VER RENDIMIENTO", style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ]),
    ),
  );

  void _showStatsPopup() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(color: Color(0xFF121212), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(25),
        child: DefaultTabController(length: 2, child: Column(children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          const TabBar(dividerColor: Colors.transparent, indicatorColor: Colors.white70, tabs: [Tab(text: "Semana"), Tab(text: "Mes")]),
          Expanded(child: TabBarView(children: [
            _buildChartContent("RENDIMIENTO SEMANAL", weeklyData, ['L', 'M', 'X', 'J', 'V', 'S', 'D'], false),
            _buildChartContent("RENDIMIENTO 30 DÍAS", monthlyData, ['S1', 'S2', 'S3', 'S4'], true),
          ])),
        ])),
      ),
    );
  }

  Widget _buildChartContent(String title, List<int> data, List<String> labels, bool isMonthly) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 30),
      Text(title, style: const TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
      SizedBox(height: 140, width: double.infinity, child: CustomPaint(painter: ChartPainter(data, isMonthly: isMonthly))),
      const SizedBox(height: 15),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: labels.map((l) => Text(l, style: const TextStyle(color: Colors.white12, fontSize: 10))).toList()),
    ]);

  Widget _buildStatsCard() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), 
    margin: const EdgeInsets.symmetric(horizontal: 30),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.02), 
      borderRadius: BorderRadius.circular(25), 
      border: Border.all(color: Colors.white.withOpacity(0.05))
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        _stat("Hoy", dailyPomodoros), 
        _stat("Semana", weeklyPomodoros), 
        _stat("Mes", monthlyPomodoros)
      ]
    ),
  );

  Widget _stat(String label, int val) => Column(children: [
    Text(val.toString(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), 
    Text(label.toUpperCase(), style: const TextStyle(color: Colors.white24, fontSize: 8))
  ]);

  Widget _btn({required IconData icon, required VoidCallback onTap, required bool isPrimary}) => GestureDetector(
    onTap: onTap, 
    child: Container(
      padding: const EdgeInsets.all(22), 
      decoration: BoxDecoration(
        color: isPrimary ? Colors.white : Colors.white.withOpacity(0.05), 
        shape: BoxShape.circle
      ), 
      child: Icon(icon, color: isPrimary ? Colors.black : Colors.white, size: 28)
    )
  );

  @override void dispose() { 
    _mainController.dispose(); 
    _audioPlayer.dispose();
    super.dispose(); 
  }
}