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
  final DominoPiece? flyingPiece;
  final DominoPiece? recentlyMovedPiece;
  final int? recentlyMovedTimestamp;
  final bool isPlayerTurn;
  final bool isDraggingActive;
  final void Function(dynamic piece) onTileTap;
  final void Function(dynamic piece)? onTileDragStarted;
  final VoidCallback? onTileDragEnded;
  final void Function(DominoPiece from, DominoPiece to)? onReorderTiles;
  final void Function(DominoPiece piece, int targetIndex)? onReorderToIndex;

  const DominoTileRack({
    super.key,
    required this.playerHand,
    required this.validPieces,
    this.selectedPiece,
    this.flyingPiece,
    this.recentlyMovedPiece,
    this.recentlyMovedTimestamp,
    required this.isPlayerTurn,
    this.isDraggingActive = false,
    required this.onTileTap,
    this.onTileDragStarted,
    this.onTileDragEnded,
    this.onReorderTiles,
    this.onReorderToIndex,
  });

  Widget _buildOuterFlankDropZone({
    required bool isRightEdge,
    required int targetIndex,
  }) {
    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        onReorderToIndex?.call(details.data, targetIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return const SizedBox.expand();
      },
    );
  }

  Widget _buildInnerEdgeZone({
    required bool isRightEdge,
    required int targetIndex,
    required bool isDragging,
  }) {
    if (!isDragging) {
      return SizedBox(width: 4.w);
    }

    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        onReorderToIndex?.call(details.data, targetIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: 24.w,
          height: 56.h,
        );
      },
    );
  }

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

    final tilesList = playerHand.map((p) {
      final piece = p as DominoPiece;
      final isValid = validPieces.contains(piece) && isPlayerTurn;
      final isSelected = selectedPiece == piece;

      final baseTile = Domino3DTile(
        top: piece.top,
        bottom: piece.bottom,
        isValid: isValid,
        isSelected: isSelected,
        onTap: () => onTileTap(piece),
      );

      // Hide the card in the hand rack if it is currently flying across the table
      if (flyingPiece == piece) {
        return Opacity(
          opacity: 0.0,
          child: baseTile,
        );
      }

      // Smooth slow landing animation if this tile was recently rearranged in the hand
      final isRecentlyMoved = recentlyMovedPiece == piece;
      Widget animatedTile;
      if (isRecentlyMoved) {
        animatedTile = TweenAnimationBuilder<double>(
          key:
              ValueKey('landing_${piece.a}_${piece.b}_$recentlyMovedTimestamp'),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            final offsetY = -28.h * (1.0 - value);
            final scale = 1.0 + 0.14 * (1.0 - value);
            final glowAlpha = (0.35 * (1.0 - value)).clamp(0.0, 1.0);
            final shadowAlpha = (0.45 * (1.0 - value)).clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(0, offsetY),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.r),
                    boxShadow: value < 0.98
                        ? [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: shadowAlpha),
                              blurRadius: 10.r * (1.0 - value),
                              offset: Offset(0, 8.h * (1.0 - value)),
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: glowAlpha),
                              blurRadius: 8.r * (1.0 - value),
                            ),
                          ]
                        : null,
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: baseTile,
        );
      } else {
        animatedTile = baseTile;
      }

      // Each slot in the rack acts as a DragTarget to allow reordering cards
      final targetWrapper = DragTarget<DominoPiece>(
        onWillAcceptWithDetails: (details) => details.data != piece,
        onAcceptWithDetails: (details) {
          onReorderTiles?.call(details.data, piece);
        },
        builder: (context, candidateData, rejectedData) {
          final isTargetHovered = candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isTargetHovered ? 4.w : 0,
            ),
            decoration: isTargetHovered
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: const Color(0xFF00E676).withValues(alpha: 0.12),
                    border: Border.all(
                      color: const Color(0xFF00E676).withValues(alpha: 0.6),
                      width: 1.2.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E676).withValues(alpha: 0.25),
                        blurRadius: 6.r,
                      ),
                    ],
                  )
                : null,
            child: animatedTile,
          );
        },
      );

      return Draggable<DominoPiece>(
        data: piece,
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
          opacity: 0.25,
          child: Domino3DTile(
            top: piece.top,
            bottom: piece.bottom,
            isValid: isValid,
            isSelected: false,
          ),
        ),
        child: targetWrapper,
      );
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(
        height: 68.r,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // FAR RIGHT outer flank (RTL -> Right side)
            if (isDraggingActive)
              Expanded(
                child: _buildOuterFlankDropZone(
                  isRightEdge: true,
                  targetIndex: 0,
                ),
              ),

            // Center scrollable rack of tiles
            Flexible(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Inner right drop zone (index 0)
                      _buildInnerEdgeZone(
                        isRightEdge: true,
                        targetIndex: 0,
                        isDragging: isDraggingActive,
                      ),

                      // Domino tiles
                      ...tilesList,

                      // Inner left drop zone (index length)
                      _buildInnerEdgeZone(
                        isRightEdge: false,
                        targetIndex: playerHand.length,
                        isDragging: isDraggingActive,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // FAR LEFT outer flank (RTL -> Left side)
            if (isDraggingActive)
              Expanded(
                child: _buildOuterFlankDropZone(
                  isRightEdge: false,
                  targetIndex: playerHand.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
