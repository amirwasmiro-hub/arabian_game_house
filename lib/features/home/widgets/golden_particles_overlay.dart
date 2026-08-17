import 'dart:math' as math;
import 'package:flutter/material.dart';

class GoldenParticlesOverlay extends StatefulWidget {
  const GoldenParticlesOverlay({super.key});

  @override
  State<GoldenParticlesOverlay> createState() => _GoldenParticlesOverlayState();
}

class _GoldenParticlesOverlayState extends State<GoldenParticlesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<GoldenParticleItem> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    // Lifespan set to 1 hour (3600 seconds) so it never cuts off or stutters
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    )..repeat();

    for (int i = 0; i < 40; i++) {
      _particles.add(GoldenParticleItem(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 2.8 + 1.2,
        speed: _random.nextDouble() * 0.05 + 0.02,
        alpha: _random.nextDouble() * 0.65 + 0.25,
        phaseOffset: _random.nextDouble() * math.pi * 2,
      ));
    }
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
        return CustomPainterWidget(
          particles: _particles,
          progress: _controller.value,
        );
      },
    );
  }
}

class GoldenParticleItem {
  double x;
  double y;
  final double radius;
  final double speed;
  final double alpha;
  final double phaseOffset;

  GoldenParticleItem({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.alpha,
    required this.phaseOffset,
  });
}

class CustomPainterWidget extends StatelessWidget {
  final List<GoldenParticleItem> particles;
  final double progress;

  const CustomPainterWidget({
    super.key,
    required this.particles,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPainterBox(
      painter: _ParticlesPainter(particles: particles, progress: progress),
    );
  }
}

class CustomPainterBox extends SingleChildRenderObjectWidget {
  final CustomPainter painter;

  const CustomPainterBox({super.key, required this.painter});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomPainterBox(painter);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderCustomPainterBox renderObject) {
    renderObject.painter = painter;
  }
}

class RenderCustomPainterBox extends RenderBox {
  CustomPainter _painter;

  RenderCustomPainterBox(this._painter);

  set painter(CustomPainter value) {
    if (_painter == value) return;
    _painter = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _painter.paint(context.canvas, size);
  }
}

class _ParticlesPainter extends CustomPainter {
  final List<GoldenParticleItem> particles;
  final double progress;

  _ParticlesPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final totalSeconds = progress * 3600.0; // Smooth continuous time

    for (final particle in particles) {
      // Continuous upward drift without sudden jumps
      final currentY = (particle.y - totalSeconds * particle.speed * 0.05) % 1.0;
      final yPos = (currentY < 0 ? currentY + 1.0 : currentY) * size.height;
      final xPos = (particle.x + math.sin(totalSeconds * 0.5 + particle.phaseOffset) * 0.04) * size.width;

      paint.color = const Color(0xFFFFD700).withValues(alpha: particle.alpha);
      canvas.drawCircle(Offset(xPos, yPos), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
