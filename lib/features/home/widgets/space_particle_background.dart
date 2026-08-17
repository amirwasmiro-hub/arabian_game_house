import 'dart:math' as math;
import 'package:flutter/material.dart';

class SpaceParticleBackground extends StatefulWidget {
  final Widget? child;
  const SpaceParticleBackground({super.key, this.child});

  @override
  State<SpaceParticleBackground> createState() => _SpaceParticleBackgroundState();
}

class _SpaceParticleBackgroundState extends State<SpaceParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random(42);
  late List<_StarParticle> _stars;

  @override
  void initState() {
    super.initState();
    _stars = List.generate(45, (index) {
      return _StarParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 2.0 + 0.8,
        opacity: _random.nextDouble() * 0.7 + 0.3,
        speed: _random.nextDouble() * 0.4 + 0.2,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SpaceParticlePainter(
            stars: _stars,
            animationValue: _controller.value,
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

class _StarParticle {
  final double x;
  final double y;
  final double radius;
  final double opacity;
  final double speed;

  _StarParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
    required this.speed,
  });
}

class _SpaceParticlePainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double animationValue;

  _SpaceParticlePainter({
    required this.stars,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cosmic Deep Background Gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.2),
        radius: 1.2,
        colors: [
          const Color(0xFF2C1052), // Deep purple glow center
          const Color(0xFF14072B),
          const Color(0xFF090314),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Cyan & Pink Subtle Lightning/Nebula Beams
    final cyanBeamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF00F2FE).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(size.width * 0.2, 0, size.width * 0.25, size.height));

    final pinkBeamPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFE91E63).withValues(alpha: 0.12),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(size.width * 0.55, 0, size.width * 0.25, size.height));

    final pathCyan = Path()
      ..moveTo(size.width * 0.25, 0)
      ..lineTo(size.width * 0.45, size.height)
      ..lineTo(size.width * 0.35, size.height)
      ..lineTo(size.width * 0.15, 0)
      ..close();

    final pathPink = Path()
      ..moveTo(size.width * 0.55, 0)
      ..lineTo(size.width * 0.75, size.height)
      ..lineTo(size.width * 0.65, size.height)
      ..lineTo(size.width * 0.45, 0)
      ..close();

    canvas.drawPath(pathCyan, cyanBeamPaint);
    canvas.drawPath(pathPink, pinkBeamPaint);

    // 3. Twinkling Stars
    for (var star in stars) {
      final pulse = math.sin((animationValue * math.pi * 2 * star.speed)) * 0.3;
      final currentOpacity = (star.opacity + pulse).clamp(0.1, 1.0);

      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: currentOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

      final dx = star.x * size.width;
      final dy = star.y * size.height;

      canvas.drawCircle(Offset(dx, dy), star.radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpaceParticlePainter oldDelegate) => true;
}
