import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';
import 'domino_piece.dart';
import 'domino_3d_tile.dart';

class DominoTileRack extends StatelessWidget {
  final List<dynamic> playerHand;
  final Set<dynamic> validPieces;
  final dynamic selectedPiece;
  final bool isPlayerTurn;
  final void Function(dynamic piece) onTileTap;
  final void Function(dynamic piece)? onTileDragStarted;
  final VoidCallback? onTileDragEnded;

  const DominoTileRack({
    super.key,
    required this.playerHand,
    required this.validPieces,
    this.selectedPiece,
    required this.isPlayerTurn,
    required this.onTileTap,
    this.onTileDragStarted,
    this.onTileDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    if (playerHand.isEmpty) {
      return Center(
        child: Text(
          'لا توجد قطع متبقية! 🎉',
          style: GoogleFonts.cairo(
            color: const Color(0xFFFFD700),
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return SizedBox(
      height: 66.r,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                data: piece as DominoPiece,
                dragAnchorStrategy: (draggable, context, position) {
                  // Offset slightly above the finger so the player can clearly see the tile and drop target
                  return const Offset(20, 50);
                },
                onDragStarted: () {
                  SoundManager().playTileDraw();
                  onTileDragStarted?.call(piece);
                },
                onDragEnd: (_) {
                  onTileDragEnded?.call();
                },
                onDraggableCanceled: (_, __) {
                  onTileDragEnded?.call();
                },
                onDragCompleted: () {
                  onTileDragEnded?.call();
                },
                feedback: Material(
                  color: Colors.transparent,
                  child: Domino3DTile(
                    top: piece.top,
                    bottom: piece.bottom,
                    isValid: false,
                    isSelected: false,
                    scale: 1.15,
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.2,
                  child: tile,
                ),
                child: tile,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
