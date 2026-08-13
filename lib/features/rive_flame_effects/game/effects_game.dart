import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

enum ExplosionType { gold, fire, magic, stars }

class ArabianEffectsGame extends FlameGame with TapCallbacks {
  ExplosionType currentExplosionType = ExplosionType.gold;
  int explosionParticleCount = 40;
  bool isGlowEnabled = true;

  final Random _rnd = Random();

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    final touchPosition = event.localPosition;
    spawnExplosion(touchPosition);
  }

  void spawnExplosion(Vector2 position) {
    switch (currentExplosionType) {
      case ExplosionType.gold:
        _spawnGoldExplosion(position);
        break;
      case ExplosionType.fire:
        _spawnFireExplosion(position);
        break;
      case ExplosionType.magic:
        _spawnMagicExplosion(position);
        break;
      case ExplosionType.stars:
        _spawnStarExplosion(position);
        break;
    }
  }

  void _spawnGoldExplosion(Vector2 position) {
    final particle = Particle.generate(
      count: explosionParticleCount,
      lifespan: 1.2,
      generator: (i) {
        final angle = _rnd.nextDouble() * 2 * pi;
        final speed = 80 + _rnd.nextDouble() * 220;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;
        final color = Color.lerp(
          const Color(0xFFFFD700),
          const Color(0xFFFF8C00),
          _rnd.nextDouble(),
        )!;

        return AcceleratedParticle(
          position: position.clone(),
          speed: velocity,
          acceleration: Vector2(0, 120),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final progress = particle.progress;
              final radius = (1.0 - progress) * (4.0 + _rnd.nextDouble() * 4.0);
              final opacity = (1.0 - progress).clamp(0.0, 1.0);

              final paint = Paint()
                ..color = color.withValues(alpha: opacity)
                ..style = PaintingStyle.fill;

              if (isGlowEnabled) {
                paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 3.0);
              }

              canvas.drawCircle(Offset.zero, radius, paint);
            },
          ),
        );
      },
    );

    add(ParticleSystemComponent(particle: particle));
  }

  void _spawnFireExplosion(Vector2 position) {
    final particle = Particle.generate(
      count: explosionParticleCount + 20,
      lifespan: 1.0,
      generator: (i) {
        final angle = -pi / 2 + (_rnd.nextDouble() - 0.5) * pi * 1.2;
        final speed = 100 + _rnd.nextDouble() * 260;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;
        final colors = [
          const Color(0xFFFF4500),
          const Color(0xFFFF6347),
          const Color(0xFFFFD700),
          const Color(0xFFFF0000),
        ];
        final color = colors[_rnd.nextInt(colors.length)];

        return AcceleratedParticle(
          position: position.clone(),
          speed: velocity,
          acceleration: Vector2(0, -60),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final progress = particle.progress;
              final radius = (1.0 - progress) * (6.0 + _rnd.nextDouble() * 6.0);
              final opacity = (1.0 - progress).clamp(0.0, 1.0);

              final paint = Paint()
                ..color = color.withValues(alpha: opacity)
                ..style = PaintingStyle.fill;

              if (isGlowEnabled) {
                paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
              }

              canvas.drawCircle(Offset.zero, radius, paint);
            },
          ),
        );
      },
    );

    add(ParticleSystemComponent(particle: particle));
  }

  void _spawnMagicExplosion(Vector2 position) {
    final particle = Particle.generate(
      count: explosionParticleCount + 10,
      lifespan: 1.5,
      generator: (i) {
        final angle = _rnd.nextDouble() * 2 * pi;
        final speed = 60 + _rnd.nextDouble() * 180;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;
        final colors = [
          const Color(0xFF9C27B0),
          const Color(0xFFE040FB),
          const Color(0xFF00E5FF),
          const Color(0xFF7C4DFF),
        ];
        final color = colors[_rnd.nextInt(colors.length)];

        return AcceleratedParticle(
          position: position.clone(),
          speed: velocity,
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final progress = particle.progress;
              final size = (1.0 - progress) * (8.0 + _rnd.nextDouble() * 4.0);
              final opacity = (1.0 - progress).clamp(0.0, 1.0);

              final paint = Paint()
                ..color = color.withValues(alpha: opacity)
                ..style = PaintingStyle.fill;

              if (isGlowEnabled) {
                paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 5.0);
              }

              canvas.save();
              canvas.rotate(progress * 4 * pi);
              canvas.drawRect(
                Rect.fromCenter(center: Offset.zero, width: size, height: size),
                paint,
              );
              canvas.restore();
            },
          ),
        );
      },
    );

    add(ParticleSystemComponent(particle: particle));
  }

  void _spawnStarExplosion(Vector2 position) {
    final particle = Particle.generate(
      count: explosionParticleCount,
      lifespan: 1.4,
      generator: (i) {
        final angle = _rnd.nextDouble() * 2 * pi;
        final speed = 90 + _rnd.nextDouble() * 200;
        final velocity = Vector2(cos(angle), sin(angle)) * speed;
        final color = Color.lerp(
          const Color(0xFF00E676),
          const Color(0xFFFFD700),
          _rnd.nextDouble(),
        )!;

        return AcceleratedParticle(
          position: position.clone(),
          speed: velocity,
          acceleration: Vector2(0, 40),
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final progress = particle.progress;
              final radius = (1.0 - progress) * 6.0;
              final opacity = (1.0 - progress).clamp(0.0, 1.0);

              final paint = Paint()
                ..color = color.withValues(alpha: opacity)
                ..style = PaintingStyle.fill;

              if (isGlowEnabled) {
                paint.maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);
              }

              final path = Path();
              const points = 5;
              final outerRadius = radius;
              final innerRadius = radius * 0.4;
              double a = -pi / 2;
              final step = pi / points;

              path.moveTo(
                cos(a) * outerRadius,
                sin(a) * outerRadius,
              );
              for (int p = 0; p < points; p++) {
                a += step;
                path.lineTo(
                  cos(a) * innerRadius,
                  sin(a) * innerRadius,
                );
                a += step;
                path.lineTo(
                  cos(a) * outerRadius,
                  sin(a) * outerRadius,
                );
              }
              path.close();

              canvas.drawPath(path, paint);
            },
          ),
        );
      },
    );

    add(ParticleSystemComponent(particle: particle));
  }
}
