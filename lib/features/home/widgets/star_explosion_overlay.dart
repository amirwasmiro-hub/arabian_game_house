import 'dart:math' as math;
import 'package:flutter/material.dart';

class StarBurstParticle {
  double x;
  double y;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double maxLifespan;
  double currentAge = 0.0;
  final double rotationSpeed;
  double rotation = 0.0;

  StarBurstParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.maxLifespan,
    required this.rotationSpeed,
  });

  bool update(double delta) {
    currentAge += delta;
    x += vx * delta * 60;
    y += vy * delta * 60 + 0.5; // slight gravity
    rotation += rotationSpeed * delta;
    return currentAge < maxLifespan;
  }
}

class StarExplosionOverlay extends StatefulWidget {
  const StarExplosionOverlay({super.key});

  static void spawnExplosion(BuildContext context, Offset globalPosition) {
    final state = context.findAncestorStateOfType<_StarExplosionOverlayState>();
    state?._addExplosion(globalPosition);
  }

  @override
  State<StarExplosionOverlay> createState() => _StarExplosionOverlayState();
}

class _StarExplosionOverlayState extends State<StarExplosionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<StarBurstParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick);
  }

  void _addExplosion(Offset position) {
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFFF8DC), // Cornsilk
      const Color(0xFFFF8C00), // Dark Orange
      const Color(0xFF00E676), // Bright Green
      const Color(0xFFE040FB), // Magenta
      Colors.white,
    ];

    for (int i = 0; i < 35; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = _random.nextDouble() * 4.5 + 1.5;
      _particles.add(StarBurstParticle(
        x: position.dx,
        y: position.dy,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        size: _random.nextDouble() * 10.0 + 8.0,
        color: colors[_random.nextInt(colors.length)],
        maxLifespan: _random.nextDouble() * 0.4 + 0.4,
        rotationSpeed: (_random.nextDouble() - 0.5) * 8.0,
      ));
    }

    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _tick() {
    if (_particles.isEmpty) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
      return;
    }

    setState(() {
      _particles.removeWhere((p) => !p.update(0.016));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _StarPainter(particles: List.from(_particles)),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final List<StarBurstParticle> particles;

  _StarPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final progress = (p.currentAge / p.maxLifespan).clamp(0.0, 1.0);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final currentSize = p.size * (1.0 - progress * 0.3);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      _drawStar(canvas, Offset.zero, 5, currentSize, currentSize * 0.45, paint);
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Offset center, int points, double outerRadius,
      double innerRadius, Paint paint) {
    final path = Path();
    double angle = -math.pi / 2;
    final step = math.pi / points;

    path.moveTo(
      center.dx + math.cos(angle) * outerRadius,
      center.dy + math.sin(angle) * outerRadius,
    );

    for (int i = 0; i < points; i++) {
      angle += step;
      path.lineTo(
        center.dx + math.cos(angle) * innerRadius,
        center.dy + math.sin(angle) * innerRadius,
      );
      angle += step;
      path.lineTo(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) => true;
}
