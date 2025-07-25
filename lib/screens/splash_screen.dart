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
      duration: const Duration(seconds: 10),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    _textFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    Future.delayed(const Duration(seconds: 3), () {
      _textFadeController.forward();
    });

    Future.delayed(const Duration(seconds: 6), () {
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
          const AnimatedDBZParticles(),
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
                          parent: _logoController,
                          curve: Curves.elasticOut,
                        ),
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
                const SizedBox(height: 60),
                FadeTransition(
                  opacity: _textFadeController,
                  child: const Text(
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
}

class RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint glowPaint = Paint()
      ..color = const Color.fromRGBO(0, 255, 0, 0.3)
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

class AnimatedDBZParticles extends StatefulWidget {
  const AnimatedDBZParticles({super.key});

  @override
  State<AnimatedDBZParticles> createState() => _AnimatedDBZParticlesState();
}

class _AnimatedDBZParticlesState extends State<AnimatedDBZParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_Particle> particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    particles = List.generate(60, (_) => _Particle.random());

    _controller.addListener(() {
      setState(() {
        for (var p in particles) {
          p.update();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        painter: _AnimatedParticlePainter(particles),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Particle {
  Offset position;
  Offset velocity;
  double radius;

  _Particle(this.position, this.velocity, this.radius);

  static _Particle random() {
    final rand = Random();
    return _Particle(
      Offset(rand.nextDouble() * 400, rand.nextDouble() * 800),
      Offset(rand.nextDouble() * 1 - 0.5, rand.nextDouble() * 1 - 0.5),
      rand.nextDouble() * 3 + 1,
    );
  }

  void update() {
    position += velocity;

    // Simple bounds check to bounce around within screen space
    if (position.dx < 0 || position.dx > 400) velocity = Offset(-velocity.dx, velocity.dy);
    if (position.dy < 0 || position.dy > 800) velocity = Offset(velocity.dx, -velocity.dy);
  }
}

class _AnimatedParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _AnimatedParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF00FF00), const Color(0x0000FF00)],
        stops: [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));

    canvas.drawCircle(center, size.width / 2, glowPaint);

    final energyPaint = Paint()
      ..color = const Color.fromRGBO(0, 200, 83, 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 5; i++) {
      final radius = size.width * 0.2 + i * 20;
      canvas.drawCircle(center, radius, energyPaint);
    }

    final sparkPaint = Paint()
      ..color = const Color.fromRGBO(0, 178, 0, 0.1)
      ..style = PaintingStyle.fill;

    for (var p in particles) {
      canvas.drawCircle(p.position, p.radius, sparkPaint);
    }

    final streakPaint = Paint()
      ..color = const Color(0x8800FF00)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 8; i++) {
      final startX = Random().nextDouble() * size.width;
      final startY = Random().nextDouble() * size.height;
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + Random().nextDouble() * 10,
            startY + Random().nextDouble() * 20),
        streakPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
