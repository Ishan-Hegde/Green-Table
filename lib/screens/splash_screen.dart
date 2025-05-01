import 'dart:math';

import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:green_table/screens/auth/registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final List<AnimationController> _animationControllers = [];
  
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => RegistrationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 1000),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromARGB(255, 138, 237, 138), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated particles
                _buildParticleAnimation(0.0),
                _buildParticleAnimation(0.5),
                _buildParticleAnimation(1.0),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 1.2, end: 1.0),
                  duration: Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Hero(
                        tag: 'app-logo',
                        child: Stack(
                          children: [
                            // Animated border
                            _buildAnimatedBorder(),
                            // Main logo
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(seconds: 1),
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.scale(
                                    scale: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Image.asset(
                                'assets/images/green-table-logo.jpg',
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) => 
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(0xFF00B200).withOpacity(0.5 + index * 0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
// Add these new methods
  Widget _buildParticleAnimation(double delay) {
    final controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();
    _animationControllers.add(controller);

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: controller.value * 2 * 3.14,
            child: CustomPaint(
              painter: _ParticlePainter(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBorder() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(seconds: 2),
      builder: (context, value, child) {
        return CircularProgressIndicator(
          value: value,
          strokeWidth: 2,
          color: Color(0xFF00B200).withOpacity(0.5),
        );
      },
    );
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF00B200).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final random = Random();
    for (var i = 0; i < 15; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}