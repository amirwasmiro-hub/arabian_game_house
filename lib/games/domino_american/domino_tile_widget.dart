import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'domino_piece.dart';

enum DominoTileStyle { ebonyDark, classicIvory, cleanNumbers }

class DominoTileWidget extends StatelessWidget {
  final DominoPiece piece;
  final bool isVerticalOnTable;
  final bool isSelected;
  final bool isValid;
  final bool onTable;
  final DominoTileStyle style;
  final VoidCallback? onTap;

  const DominoTileWidget({
    super.key,
    required this.piece,
    this.isVerticalOnTable = false,
    this.isSelected = false,
    this.isValid = true,
    this.onTable = false,
    this.style = DominoTileStyle.classicIvory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double baseWidth = onTable ? (isVerticalOnTable ? 26.w : 52.w) : 32.w;
    final double baseHeight = onTable ? (isVerticalOnTable ? 52.h : 26.h) : 64.h;
    final isVertical = !onTable || isVerticalOnTable;

    return GestureDetector(
      onTap: isValid ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: baseWidth,
        height: baseHeight,
        margin: EdgeInsets.all(onTable ? 2.w : 2.5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.85),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 4,
                    offset: const Offset(1.5, 2.5),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.r),
          child: CustomPaint(
            size: Size(baseWidth, baseHeight),
            painter: _FullDomino3DPainter(
              piece: piece,
              isVertical: isVertical,
              isSelected: isSelected,
              isValid: isValid,
              style: style,
              onTable: onTable,
            ),
          ),
        ),
      ),
    );
  }
}

class _FullDomino3DPainter extends CustomPainter {
  final DominoPiece piece;
  final bool isVertical;
  final bool isSelected;
  final bool isValid;
  final DominoTileStyle style;
  final bool onTable;

  _FullDomino3DPainter({
    required this.piece,
    required this.isVertical,
    required this.isSelected,
    required this.isValid,
    required this.style,
    required this.onTable,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final isEbony = style == DominoTileStyle.ebonyDark;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isEbony
            ? [const Color(0xFF2A2A2A), const Color(0xFF111111)]
            : [const Color(0xFFFFFDF5), const Color(0xFFE8E0CE)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final borderPaint = Paint()
      ..color = isEbony ? const Color(0xFF444444) : const Color(0xFFD0C4AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(rect, borderPaint);

    final linePaint = Paint()
      ..color = isEbony ? const Color(0xFFFFD700) : const Color(0xFF333333)
      ..strokeWidth = 1.2;

    if (isVertical) {
      final midY = size.height / 2;
      canvas.drawLine(Offset(2, midY), Offset(size.width - 2, midY), linePaint);
      final pinPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(Offset(size.width / 2, midY), 1.8.r, pinPaint);

      _drawPips(canvas, piece.a, Rect.fromLTWH(0, 0, size.width, midY), isEbony);
      _drawPips(canvas, piece.b, Rect.fromLTWH(0, midY, size.width, midY), isEbony);
    } else {
      final midX = size.width / 2;
      canvas.drawLine(Offset(midX, 2), Offset(midX, size.height - 2), linePaint);
      final pinPaint = Paint()..color = const Color(0xFFFFD700);
      canvas.drawCircle(Offset(midX, size.height / 2), 1.8.r, pinPaint);

      _drawPips(canvas, piece.a, Rect.fromLTWH(0, 0, midX, size.height), isEbony);
      _drawPips(canvas, piece.b, Rect.fromLTWH(midX, 0, midX, size.height), isEbony);
    }
  }

  void _drawPips(Canvas canvas, int count, Rect halfRect, bool isEbony) {
    if (count == 0) return;
    final pipPaint = Paint()
      ..color = isEbony ? const Color(0xFFFFD700) : const Color(0xFF1E1E1E);

    final radius = onTable ? 1.8.r : 2.5.r;
    final cx = halfRect.center.dx;
    final cy = halfRect.center.dy;
    final dx = halfRect.width * 0.26;
    final dy = halfRect.height * 0.26;

    final positions = <Offset>[];
    if (count == 1) {
      positions.add(Offset(cx, cy));
    } else if (count == 2) {
      positions.addAll([Offset(cx - dx, cy - dy), Offset(cx + dx, cy + dy)]);
    } else if (count == 3) {
      positions.addAll([Offset(cx - dx, cy - dy), Offset(cx, cy), Offset(cx + dx, cy + dy)]);
    } else if (count == 4) {
      positions.addAll([
        Offset(cx - dx, cy - dy), Offset(cx + dx, cy - dy),
        Offset(cx - dx, cy + dy), Offset(cx + dx, cy + dy)
      ]);
    } else if (count == 5) {
      positions.addAll([
        Offset(cx - dx, cy - dy), Offset(cx + dx, cy - dy), Offset(cx, cy),
        Offset(cx - dx, cy + dy), Offset(cx + dx, cy + dy)
      ]);
    } else if (count == 6) {
      positions.addAll([
        Offset(cx - dx, cy - dy), Offset(cx + dx, cy - dy),
        Offset(cx - dx, cy), Offset(cx + dx, cy),
        Offset(cx - dx, cy + dy), Offset(cx + dx, cy + dy)
      ]);
    }

    for (final pos in positions) {
      canvas.drawCircle(pos, radius, pipPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FullDomino3DPainter oldDelegate) => true;
}
