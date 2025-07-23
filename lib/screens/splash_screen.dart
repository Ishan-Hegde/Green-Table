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
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
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
                              width: 210, // Adjust as needed
                              height: 210,
                              fit: BoxFit
                                  .cover, // ensures the image fills the oval
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _textFadeController,
                  child: Text(
                    "Turning Leftovers into Lifelines",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade800,
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
      width: 240, // Increased from 180
      height: 240, // Increased from 180
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
          colors: [Color(0xFFA8E6A3), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: ParticlePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint glowPaint = Paint()
      ..color = const Color(0xFF00B200).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final Paint ringPaint = Paint()
      ..color = const Color(0xFF00B200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, glowPaint);
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, ringPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ParticlePainter extends CustomPainter {
  final Random random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF00B200).withOpacity(0.15)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final offset = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
