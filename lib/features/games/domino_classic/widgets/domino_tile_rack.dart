import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/domino_piece.dart';
import 'domino_3d_tile.dart';

class DominoTileRack extends StatelessWidget {
  final List<dynamic> playerHand;
  final Set<dynamic> validPieces;
  final dynamic selectedPiece;
  final bool isPlayerTurn;
  final void Function(dynamic piece) onTileTap;

  const DominoTileRack({
    super.key,
    required this.playerHand,
    required this.validPieces,
    this.selectedPiece,
    required this.isPlayerTurn,
    required this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        // Luxury Polished Mahogany Wood Rack
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4E260E),
            Color(0xFF2E1305),
            Color(0xFF190902),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
            width: 1.5.w,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 10.r,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rack Groove Line
          Container(
            height: 2.h,
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF140803),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.15),
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),

          // Tiles Row
          SizedBox(
            height: 68.h,
            child: playerHand.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد قطع متبقية! 🎉',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFFFD700),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: playerHand.map((piece) {
                          final isValid = validPieces.contains(piece) && isPlayerTurn;
                          final isSelected = selectedPiece == piece;

                          final tile = Domino3DTile(
                            top: piece.top,
                            bottom: piece.bottom,
                            isValid: isValid,
                            isSelected: isSelected,
                            onTap: () => onTileTap(piece),
                          );

                          if (!isValid) return tile;

                          return Draggable<DominoPiece>(
                            data: piece,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Transform.scale(
                                scale: 1.15,
                                child: Domino3DTile(
                                  top: piece.top,
                                  bottom: piece.bottom,
                                  isValid: true,
                                  isSelected: true,
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.25,
                              child: tile,
                            ),
                            child: tile,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
