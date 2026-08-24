import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../logic/domino_classic_engine.dart';
import '../models/domino_piece.dart';
import 'domino_3d_tile.dart';

class DominoCafeBoard extends StatelessWidget {
  final DominoClassicEngine engine;
  final DominoPiece? selectedPiece;
  final Function(DominoPiece piece, DominoEdgeLocation edge)? onPlacePiece;
  final int totalPotCoins;

  const DominoCafeBoard({
    super.key,
    required this.engine,
    this.selectedPiece,
    this.onPlacePiece,
    this.totalPotCoins = 160000,
  });

  @override
  Widget build(BuildContext context) {
    final validEdges = selectedPiece != null
        ? engine.getValidEdgesFor(selectedPiece!)
        : <DominoEdgeLocation>[];

    final isFirstMove = engine.board.isEmpty;
    final leftVal = engine.leftEnd;
    final rightVal = engine.rightEnd;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        // Royal Green Velvet Felt with dark radial vignette
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [
            Color(0xFF0F4D2A), // Vibrant emerald felt center
            Color(0xFF0A331C), // Deep green
            Color(0xFF04180C), // Dark mahogany edge vignette
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
          width: 2.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 18.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Arabesque Table Patterns (Subtle watermarks in corners)
          Positioned(
            top: 10.h,
            left: 10.w,
            child: Icon(
              Icons.all_inclusive_rounded,
              color: const Color(0xFFFFD700).withValues(alpha: 0.08),
              size: 48.r,
            ),
          ),
          Positioned(
            bottom: 10.h,
            right: 10.w,
            child: Icon(
              Icons.all_inclusive_rounded,
              color: const Color(0xFFFFD700).withValues(alpha: 0.08),
              size: 48.r,
            ),
          ),

          // 2. Center Pot / Total Stakes Badge (Domino Cafe Style)
          Positioned(
            top: 8.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 8.r,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on_rounded, color: const Color(0xFFFFD700), size: 14.r),
                  SizedBox(width: 4.w),
                  Text(
                    'مجموع الرهان: ${_formatNumber(totalPotCoins)}',
                    style: GoogleFonts.cairo(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(duration: 1500.ms, begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02)),
          ),

          // 3. First Move Drop Zone (When board is empty)
          if (isFirstMove)
            Center(
              child: DragTarget<DominoPiece>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  onPlacePiece?.call(details.data, DominoEdgeLocation.right);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovered = candidateData.isNotEmpty;
                  final borderCol = isHovered ? const Color(0xFF00E676) : const Color(0xFFFFD700);

                  return GestureDetector(
                    onTap: () {
                      if (selectedPiece != null) {
                        onPlacePiece?.call(selectedPiece!, DominoEdgeLocation.right);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: borderCol.withValues(alpha: isHovered ? 0.35 : 0.15),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: borderCol,
                          width: isHovered ? 2.5.w : 1.5.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: borderCol.withValues(alpha: 0.4),
                            blurRadius: 15.r,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHovered ? Icons.touch_app_rounded : Icons.casino_rounded,
                            size: 32.r,
                            color: borderCol,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            selectedPiece != null
                                ? 'اضغط هنا للنزول بـ [${selectedPiece!.a}:${selectedPiece!.b}] 🀄'
                                : 'اختر قطعتك للنزول الأول 🀄',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.4)),
                  );
                },
              ),
            )
          // 4. Live Domino Chain in Strict LTR Direction (أطراف الدومينو من اليسار لليمين)
          else
            Center(
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 20.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Physical Left Drop Target (طرف اليسار)
                      _buildDropTarget(
                        edge: DominoEdgeLocation.left,
                        openValue: leftVal ?? 0,
                        isValid: validEdges.contains(DominoEdgeLocation.left),
                        isHoverable: selectedPiece != null,
                      ),

                      // Chain of placed tiles strictly from Left (0) to Right (N)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: engine.board.map((placed) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 1.w),
                            child: Domino3DTile(
                              top: placed.leftValue,
                              bottom: placed.rightValue,
                              isHorizontal: !placed.isDouble,
                              onTable: true,
                            ),
                          );
                        }).toList(),
                      ),

                      // Physical Right Drop Target (طرف اليمين)
                      _buildDropTarget(
                        edge: DominoEdgeLocation.right,
                        openValue: rightVal ?? 0,
                        isValid: validEdges.contains(DominoEdgeLocation.right),
                        isHoverable: selectedPiece != null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropTarget({
    required DominoEdgeLocation edge,
    required int openValue,
    required bool isValid,
    required bool isHoverable,
  }) {
    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) =>
          engine.getValidEdgesFor(details.data).contains(edge),
      onAcceptWithDetails: (details) {
        onPlacePiece?.call(details.data, edge);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        Color targetColor = const Color(0xFFFFD700);
        if (isHovered) {
          targetColor = const Color(0xFF00E676);
        } else if (isValid) {
          targetColor = const Color(0xFF00E5FF);
        }

        final isLeft = edge == DominoEdgeLocation.left;

        return GestureDetector(
          onTap: () {
            if (isValid && selectedPiece != null) {
              onPlacePiece?.call(selectedPiece!, edge);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            decoration: BoxDecoration(
              color: targetColor.withValues(alpha: isHovered ? 0.5 : (isValid ? 0.35 : 0.12)),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: targetColor,
                width: isValid ? 2.5.w : 1.2.w,
              ),
              boxShadow: isValid
                  ? [
                      BoxShadow(
                        color: targetColor.withValues(alpha: 0.6),
                        blurRadius: 10.r,
                        spreadRadius: 1.r,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHovered
                      ? Icons.check_circle_rounded
                      : (isLeft ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded),
                  color: Colors.white,
                  size: 18.r,
                ),
                SizedBox(height: 2.h),
                // Show exposed required number clearly in Arabic
                Text(
                  isLeft ? '⬅️ طرف ($openValue)' : 'طرف ($openValue) ➡️',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          )
              .animate(target: isValid ? 1 : 0)
              .scale(duration: 500.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.08, 1.08)),
        );
      },
    );
  }

  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
