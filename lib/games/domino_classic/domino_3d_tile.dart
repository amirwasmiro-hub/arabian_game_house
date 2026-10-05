import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Domino3DTile extends StatelessWidget {
  final int top;
  final int bottom;
  final bool isHorizontal;
  final bool isSelected;
  final bool isValid;
  final bool onTable;
  final VoidCallback? onTap;
  final double scale;
  final Color? glowColor;

  const Domino3DTile({
    super.key,
    required this.top,
    required this.bottom,
    this.isHorizontal = false,
    this.isSelected = false,
    this.isValid = true,
    this.onTable = false,
    this.onTap,
    this.scale = 1.0,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    // Real domino proportions (exactly 2:1). Both sides use .r so the ratio
    // never stretches on screens with a different aspect ratio.
    final double shortSide = onTable ? 21.r : 27.r;
    final double longSide = shortSide * 2;
    final double width = isHorizontal ? longSide : shortSide;
    final double height = isHorizontal ? shortSide : longSide;

    final double effectiveWidth = width * scale;
    final double effectiveHeight = height * scale;

    return GestureDetector(
      onTap: isValid ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: effectiveWidth,
        height: effectiveHeight,
        margin: EdgeInsets.all(onTable ? 1.5.w : 2.5.w),
        transform: Matrix4.translationValues(0.0, isSelected ? -8.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          border: glowColor != null
              ? Border.all(color: glowColor!, width: 2.w)
              : isSelected
                  ? Border.all(color: const Color(0xFFFFD700), width: 1.5.w)
                  : isValid && !onTable
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.85),
                          width: 1.2.w,
                        )
                      : null,
          boxShadow: glowColor != null
              ? [
                  BoxShadow(
                    color: glowColor!.withValues(alpha: 0.95),
                    blurRadius: 16.r,
                    spreadRadius: 3.r,
                  ),
                  BoxShadow(
                    color: glowColor!.withValues(alpha: 0.5),
                    blurRadius: 26.r,
                    spreadRadius: 6.r,
                  ),
                ]
              : isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.9),
                        blurRadius: 14.r,
                        spreadRadius: 2.r,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 12.r,
                        offset: const Offset(2, 6),
                      ),
                    ]
                  : isValid && !onTable
                      ? [
                          // Subtle glowing soft white glow (جلو أبيض مضيء خفيف للكروت المتاحة فقط)
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.75),
                            blurRadius: 8.r,
                            spreadRadius: 1.5.r,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.35),
                            blurRadius: 14.r,
                            spreadRadius: 2.5.r,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 4.r,
                            offset: const Offset(1.5, 3.5),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 4.r,
                            offset: const Offset(1.5, 3),
                          ),
                        ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: CustomPaint(
            size: Size(effectiveWidth, effectiveHeight),
            painter: _Realistic3DDominoPainter(
              top: top,
              bottom: bottom,
              isHorizontal: isHorizontal,
              isSelected: isSelected,
              isValid: isValid,
              onTable: onTable,
            ),
          ),
        ),
      ),
    );
  }
}

class _Realistic3DDominoPainter extends CustomPainter {
  final int top;
  final int bottom;
  final bool isHorizontal;
  final bool isSelected;
  final bool isValid;
  final bool onTable;

  _Realistic3DDominoPainter({
    required this.top,
    required this.bottom,
    required this.isHorizontal,
    required this.isSelected,
    required this.isValid,
    required this.onTable,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));

    // 1. Deep 3D Ivory Gradient Face (Real Porcelain/Bone Domino)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF), // Bright reflection
          Color(0xFFFAF7EE), // Rich Ivory
          Color(0xFFEBE3D0), // Bone Tone
          Color(0xFFD4C8B0), // Shadowed base
        ],
        stops: [0.0, 0.25, 0.75, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);

    // 2. 3D Bevel Rim Highlight (Glossy edges)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, highlightPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF9E8F75).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(rrect, borderPaint);

    // 3. Center Metallic Dividing Groove & Golden Pivot Pin (المسمار المعدني في المنتصف)
    if (isHorizontal) {
      final midX = size.width / 2;
      // Groove
      canvas.drawLine(
        Offset(midX, 2),
        Offset(midX, size.height - 2),
        Paint()
          ..color = const Color(0xFF6B5B45)
          ..strokeWidth = 1.5,
      );
      canvas.drawLine(
        Offset(midX + 1, 2),
        Offset(midX + 1, size.height - 2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = 0.8,
      );
      // Golden Brass Rivet Pin
      _drawBrassPin(canvas, Offset(midX, size.height / 2));

      // Draw Left & Right Pips
      final leftRect = Rect.fromLTWH(0, 0, midX, size.height);
      final rightRect = Rect.fromLTWH(midX, 0, midX, size.height);
      _drawPips(canvas, leftRect, top);
      _drawPips(canvas, rightRect, bottom);
    } else {
      final midY = size.height / 2;
      // Groove
      canvas.drawLine(
        Offset(2, midY),
        Offset(size.width - 2, midY),
        Paint()
          ..color = const Color(0xFF6B5B45)
          ..strokeWidth = 1.5,
      );
      canvas.drawLine(
        Offset(2, midY + 1),
        Offset(size.width - 2, midY + 1),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = 0.8,
      );
      // Golden Brass Rivet Pin
      _drawBrassPin(canvas, Offset(size.width / 2, midY));

      // Draw Top & Bottom Pips
      final topRect = Rect.fromLTWH(0, 0, size.width, midY);
      final bottomRect = Rect.fromLTWH(0, midY, size.width, midY);
      _drawPips(canvas, topRect, top);
      _drawPips(canvas, bottomRect, bottom);
    }

    // 4. Selection Aura Overlay
    if (isSelected) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.25)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawBrassPin(Canvas canvas, Offset center) {
    // Outer Pin Rim
    canvas.drawCircle(
      center,
      2.2,
      Paint()..color = const Color(0xFF8B6B14),
    );
    // Golden Center
    canvas.drawCircle(
      center,
      1.6,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFF8D6E63)],
        ).createShader(Rect.fromCircle(center: center, radius: 1.6)),
    );
  }

  void _drawPips(Canvas canvas, Rect half, int count) {
    if (count == 0) return;

    final cx = half.center.dx;
    final cy = half.center.dy;
    final w = half.width;
    final h = half.height;
    final dx = w * 0.26;
    final dy = h * 0.26;
    final pipRadius = min(w, h) * 0.11;

    final positions = <Offset>[];

    switch (count) {
      case 1:
        positions.add(Offset(cx, cy));
        break;
      case 2:
        positions.addAll([Offset(cx - dx, cy - dy), Offset(cx + dx, cy + dy)]);
        break;
      case 3:
        positions.addAll([
          Offset(cx - dx, cy - dy),
          Offset(cx, cy),
          Offset(cx + dx, cy + dy)
        ]);
        break;
      case 4:
        positions.addAll([
          Offset(cx - dx, cy - dy),
          Offset(cx + dx, cy - dy),
          Offset(cx - dx, cy + dy),
          Offset(cx + dx, cy + dy),
        ]);
        break;
      case 5:
        positions.addAll([
          Offset(cx - dx, cy - dy),
          Offset(cx + dx, cy - dy),
          Offset(cx, cy),
          Offset(cx - dx, cy + dy),
          Offset(cx + dx, cy + dy),
        ]);
        break;
      case 6:
        if (onTable && (top == 6 && bottom == 6)) {
          // كارت 6:6 على الطاولة فقط: 3 صفوف كل صف فيه 2 دوت (بالطول)
          positions.addAll([
            Offset(cx - dx, cy - dy),
            Offset(cx + dx, cy - dy),
            Offset(cx - dx, cy),
            Offset(cx + dx, cy),
            Offset(cx - dx, cy + dy),
            Offset(cx + dx, cy + dy),
          ]);
        } else if (onTable) {
          // باقي الكروت التي تحتوي على 6 على الطاولة: صفّين كل صف 3 دوت
          positions.addAll([
            Offset(cx - dx, cy - dy),
            Offset(cx, cy - dy),
            Offset(cx + dx, cy - dy),
            Offset(cx - dx, cy + dy),
            Offset(cx, cy + dy),
            Offset(cx + dx, cy + dy),
          ]);
        } else {
          // في اليد: كما هو مرسوم (3 صفوف كل صف فيه 2 دوت)
          positions.addAll([
            Offset(cx - dx, cy - dy),
            Offset(cx + dx, cy - dy),
            Offset(cx - dx, cy),
            Offset(cx + dx, cy),
            Offset(cx - dx, cy + dy),
            Offset(cx + dx, cy + dy),
          ]);
        }
        break;
    }

    // Color theme for pips: ALL PIPS ARE PURE JET BLACK (كل الدوت في كل الكروت باللون الأسود)
    const Color pipPrimaryColor = Color(0xFF1A1A1A);
    const Color pipShadowColor = Color(0xFF000000);

    for (final pos in positions) {
      // 1. Pip Inset Shadow (Engraved 3D feel)
      canvas.drawCircle(
        Offset(pos.dx, pos.dy + 0.6),
        pipRadius + 0.4,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.6),
      );
      // 2. Pip Body
      canvas.drawCircle(
        pos,
        pipRadius,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 0.8,
            colors: [
              pipPrimaryColor.withValues(alpha: 0.9),
              pipShadowColor,
            ],
          ).createShader(Rect.fromCircle(center: pos, radius: pipRadius)),
      );
      // 3. Specular Dot on Pip
      canvas.drawCircle(
        Offset(pos.dx - pipRadius * 0.35, pos.dy - pipRadius * 0.35),
        pipRadius * 0.25,
        Paint()..color = Colors.white.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Realistic3DDominoPainter old) {
    return old.top != top ||
        old.bottom != bottom ||
        old.isHorizontal != isHorizontal ||
        old.isSelected != isSelected ||
        old.isValid != isValid ||
        old.onTable != onTable;
  }
}
