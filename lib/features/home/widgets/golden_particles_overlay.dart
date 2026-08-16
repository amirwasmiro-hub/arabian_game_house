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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    for (int i = 0; i < 35; i++) {
      _particles.add(GoldenParticleItem(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 2.5 + 1.0,
        speed: _random.nextDouble() * 0.0008 + 0.0003,
        alpha: _random.nextDouble() * 0.6 + 0.2,
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

  GoldenParticleItem({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.alpha,
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

    for (final particle in particles) {
      final currentY = (particle.y - progress * particle.speed * 100) % 1.0;
      final yPos = (currentY < 0 ? currentY + 1.0 : currentY) * size.height;
      final xPos = (particle.x + math.sin(progress * math.pi * 2 + particle.y * 10) * 0.03) * size.width;

      paint.color = const Color(0xFFFFD700).withValues(alpha: particle.alpha);
      canvas.drawCircle(Offset(xPos, yPos), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
