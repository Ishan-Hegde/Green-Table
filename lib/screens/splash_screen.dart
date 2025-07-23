import 'dart:math';
import 'package:flutter/material.dart';
import 'package:green_table/screens/auth/registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _logoController;
  late final AnimationController _textFadeController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _textFadeController.forward();
    });

    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const RegistrationScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _logoController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RepaintBoundary(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRotatingRing(),
                      ScaleTransition(
                        scale: CurvedAnimation(
                            parent: _logoController, curve: Curves.elasticOut),
                        child: Hero(
                          tag: 'app-logo',
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/green-table-logo-1.png',
                              width: 210,
                              height: 210,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60 ),
                FadeTransition(
                  opacity: _textFadeController,
                  child: Text(
                    "Turning Leftovers into Lifelines",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingRing() {
    return SizedBox(
      width: 240,
      height: 240,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationController.value * 2 * pi,
            child: CustomPaint(
              painter: RingPainter(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0C1E12),
            Color(0xFF122F1E),
            Color(0xFF1B3B2B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: DBZParticlePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint glowPaint = Paint()
      ..color = const Color(0xFF00FF00).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final Paint ringPaint = Paint()
      ..color = const Color(0xFF00FF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(size.center(Offset.zero), size.width / 1.5, glowPaint);
    canvas.drawCircle(size.center(Offset.zero), size.width / 1.5, ringPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DBZParticlePainter extends CustomPainter {
  final Random random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // ⚡ Glow aura
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00FF00),
          const Color(0x0000FF00),
        ],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    canvas.drawCircle(center, size.width / 2, glowPaint);

    // 💨 Energy pulses
    final energyPaint = Paint()
      ..color = const Color(0xFF00C853).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 5; i++) {
      final radius = size.width * 0.2 + i * 20;
      canvas.drawCircle(center, radius, energyPaint);
    }

    // 🌟 Random energy sparks
    final sparkPaint = Paint()
      ..color = const Color(0xFF00B200).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      final offset = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(offset, radius, sparkPaint);
    }

    // ⚡ Light streaks
    final streakPaint = Paint()
      ..color = const Color(0x8800FF00)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 8; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + random.nextDouble() * 10,
            startY + random.nextDouble() * 20),
        streakPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
