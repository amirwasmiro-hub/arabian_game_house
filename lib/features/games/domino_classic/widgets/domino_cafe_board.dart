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

    final isFirstMove = engine.spinnerTile == null &&
        engine.rowWest.isEmpty &&
        engine.rowEast.isEmpty;

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
                  onPlacePiece?.call(details.data, DominoEdgeLocation.east);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovered = candidateData.isNotEmpty;
                  final borderCol = isHovered ? const Color(0xFF00E676) : const Color(0xFFFFD700);

                  return GestureDetector(
                    onTap: () {
                      if (selectedPiece != null) {
                        onPlacePiece?.call(selectedPiece!, DominoEdgeLocation.east);
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
                            isHovered
                                ? 'اترك الحجر هنا للنزول الأول! 🀄'
                                : 'اضغط أو اسحب قطعة الدومينو للنزول الأول 🀄',
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
          // 4. Live Serpentine Domino Chain (سلسلة الدومينو النشطة)
          else
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // West Drop Target (طرف الغرب)
                    if (validEdges.contains(DominoEdgeLocation.west) || selectedPiece == null)
                      _buildDropTarget('طرف اليسار ⬅️', DominoEdgeLocation.west),

                    // West Row Tiles
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: engine.rowWest.map((bt) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: Domino3DTile(
                            top: bt.piece.top,
                            bottom: bt.piece.bottom,
                            isHorizontal: !bt.isVertical,
                            onTable: true,
                          ),
                        );
                      }).toList(),
                    ),

                    // Center Spinner Double Tile
                    if (engine.spinnerTile != null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Domino3DTile(
                          top: engine.spinnerTile!.piece.top,
                          bottom: engine.spinnerTile!.piece.bottom,
                          isHorizontal: false, // Perpendicular Double
                          onTable: true,
                        ),
                      ),

                    // East Row Tiles
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: engine.rowEast.map((bt) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.w),
                          child: Domino3DTile(
                            top: bt.piece.top,
                            bottom: bt.piece.bottom,
                            isHorizontal: !bt.isVertical,
                            onTable: true,
                          ),
                        );
                      }).toList(),
                    ),

                    // East Drop Target (طرف الشرق)
                    if (validEdges.contains(DominoEdgeLocation.east) || selectedPiece == null)
                      _buildDropTarget('طرف اليمين ➡️', DominoEdgeLocation.east),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropTarget(String label, DominoEdgeLocation edge) {
    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) => engine.getValidEdgesFor(details.data).contains(edge),
      onAcceptWithDetails: (details) {
        onPlacePiece?.call(details.data, edge);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        final isValidSelected = selectedPiece != null &&
            engine.getValidEdgesFor(selectedPiece!).contains(edge);

        Color targetColor = const Color(0xFFFFD700);
        if (isHovered) {
          targetColor = const Color(0xFF00E676);
        } else if (isValidSelected) {
          targetColor = const Color(0xFF00E5FF);
        }

        return GestureDetector(
          onTap: () {
            if (isValidSelected && selectedPiece != null) {
              onPlacePiece?.call(selectedPiece!, edge);
            }
          },
          child: Container(
            width: 32.w,
            height: 52.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: targetColor.withValues(alpha: isHovered ? 0.4 : 0.18),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: targetColor,
                width: isHovered ? 2.5.w : 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: targetColor.withValues(alpha: 0.5),
                  blurRadius: 8.r,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isHovered
                    ? Icons.download_done_rounded
                    : (edge == DominoEdgeLocation.west
                        ? Icons.arrow_back_rounded
                        : Icons.arrow_forward_rounded),
                color: Colors.white,
                size: 18.r,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(duration: 800.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),
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
