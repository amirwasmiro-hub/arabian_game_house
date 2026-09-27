import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'domino_classic_engine.dart';
import 'domino_piece.dart';
import 'domino_3d_tile.dart';

class DominoCafeBoard extends StatefulWidget {
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
  State<DominoCafeBoard> createState() => _DominoCafeBoardState();
}

class _DominoCafeBoardState extends State<DominoCafeBoard> {
  final TransformationController _transformController = TransformationController();
  DominoEdgeLocation? _hoveredEdge;
  DominoPiece? _draggedPiece;

  void _zoomIn() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale < 2.0) {
      _transformController.value = _transformController.value.clone()
        ..multiply(Matrix4.diagonal3Values(1.2, 1.2, 1.0));
    }
  }

  void _zoomOut() {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale > 0.6) {
      _transformController.value = _transformController.value.clone()
        ..multiply(Matrix4.diagonal3Values(0.85, 0.85, 1.0));
    }
  }

  @override
  void didUpdateWidget(covariant DominoCafeBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPiece == null && oldWidget.selectedPiece != null) {
      _hoveredEdge = null;
      _draggedPiece = null;
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectivePiece = widget.selectedPiece ?? _draggedPiece;
    final validEdges = effectivePiece != null
        ? widget.engine.getValidEdgesFor(effectivePiece)
        : <DominoEdgeLocation>[];

    final isFirstMove = widget.engine.board.isEmpty;
    final canPlayLeft = validEdges.contains(DominoEdgeLocation.left);
    final canPlayRight = validEdges.contains(DominoEdgeLocation.right);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        // Royal Green Velvet Felt with dark radial vignette across full screen
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.25,
          colors: [
            Color(0xFF0F4D2A), // Vibrant emerald felt center
            Color(0xFF0A331C), // Deep green
            Color(0xFF04180C), // Dark mahogany edge vignette
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Arabesque Table Patterns (Subtle watermarks in corners)
          Positioned(
            top: 10.h,
            right: 12.w,
            child: Icon(
              Icons.all_inclusive_rounded,
              color: const Color(0xFFFFD700).withValues(alpha: 0.08),
              size: 44.r,
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: 12.w,
            child: Icon(
              Icons.all_inclusive_rounded,
              color: const Color(0xFFFFD700).withValues(alpha: 0.08),
              size: 44.r,
            ),
          ),

          // 2. Table Watermark: Stake Value written large on the table felt with subtle shadow
          Center(
            child: IgnorePointer(
              child: Text(
                _formatNumber(widget.totalPotCoins),
                style: GoogleFonts.cairo(
                  fontSize: 52.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.08),
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(1, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Invisible Broad Drop Zones (Left & Right halves of the table)
          // Placed BEHIND the chain so they catch drops towards either side
          // with ZERO visual clutter (no boxes, no borders, no text).
          if (!isFirstMove) ...[
            Positioned(
              left: 0,
              top: 30.h,
              bottom: 30.h,
              width: MediaQuery.of(context).size.width * 0.5,
              child: _buildSideDropZone(DominoEdgeLocation.left),
            ),
            Positioned(
              right: 0,
              top: 30.h,
              bottom: 30.h,
              width: MediaQuery.of(context).size.width * 0.5,
              child: _buildSideDropZone(DominoEdgeLocation.right),
            ),
          ],

          // 4. Interactive Domino Table Surface (Chain & Glowing End Targets)
          Positioned.fill(
            child: isFirstMove
                ? _buildFirstMoveTarget()
                : _buildDominoChain(
                    widget.engine.board,
                    canPlayLeft: canPlayLeft,
                    canPlayRight: canPlayRight,
                  ),
          ),

          // 5. Standalone Zoom In & Zoom Out Icons (No Box)
          if (!isFirstMove)
            Positioned(
              top: 8.h,
              left: 10.w,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_in_rounded, color: Color(0xFFFFD700), size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                    tooltip: 'تكبير',
                    onPressed: _zoomIn,
                  ),
                  SizedBox(width: 4.w),
                  IconButton(
                    icon: const Icon(Icons.zoom_out_rounded, color: Color(0xFFFFD700), size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                    tooltip: 'تصغير',
                    onPressed: _zoomOut,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Completely invisible DragTarget drop zone covering a whole half of the table.
  /// NO boxes, NO borders, NO text!
  /// When a player drags a valid piece over that side, it triggers the glow on the END CARD.
  Widget _buildSideDropZone(DominoEdgeLocation edge) {
    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) {
        final piece = details.data;
        return widget.engine.getValidEdgesFor(piece).contains(edge);
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _hoveredEdge = null;
          _draggedPiece = null;
        });
        widget.onPlacePiece?.call(details.data, edge);
      },
      onMove: (details) {
        if (_hoveredEdge != edge || _draggedPiece != details.data) {
          setState(() {
            _hoveredEdge = edge;
            _draggedPiece = details.data;
          });
        }
      },
      onLeave: (data) {
        if (_hoveredEdge == edge) {
          setState(() {
            _hoveredEdge = null;
            _draggedPiece = null;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        // Completely invisible - NO boxes, NO text!
        return const SizedBox.expand();
      },
    );
  }

  /// Subtle, elegant first-move target with NO text:
  /// A domino silhouette slot in the center that glows gold, and turns emerald green when hovered.
  Widget _buildFirstMoveTarget() {
    return Center(
      child: DragTarget<DominoPiece>(
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) {
          setState(() {
            _hoveredEdge = null;
            _draggedPiece = null;
          });
          widget.onPlacePiece?.call(details.data, DominoEdgeLocation.right);
        },
        onMove: (details) {
          if (_draggedPiece != details.data) {
            setState(() {
              _draggedPiece = details.data;
            });
          }
        },
        onLeave: (_) {
          setState(() {
            _draggedPiece = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          final isHovered = candidateData.isNotEmpty;
          final borderCol = isHovered ? const Color(0xFF00E676) : const Color(0xFFFFD700);

          return GestureDetector(
            onTap: () {
              final piece = widget.selectedPiece ?? _draggedPiece;
              if (piece != null) {
                widget.onPlacePiece?.call(piece, DominoEdgeLocation.right);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: borderCol.withValues(alpha: isHovered ? 0.35 : 0.12),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: borderCol,
                  width: isHovered ? 2.2.w : 1.5.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: borderCol.withValues(alpha: isHovered ? 0.7 : 0.35),
                    blurRadius: isHovered ? 16.r : 8.r,
                    spreadRadius: isHovered ? 2.r : 0.5.r,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isHovered ? Icons.check_rounded : Icons.add_rounded,
                  size: 16.r,
                  color: borderCol,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(duration: 1000.ms, begin: const Offset(0.96, 0.96), end: const Offset(1.04, 1.04)),
          );
        },
      ),
    );
  }

  /// Builds a clean, continuous Domino chain where:
  /// 1. Double ("بافة") tiles stand VERTICALLY (isHorizontal: false).
  /// 2. Normal tiles lay HORIZONTALLY (isHorizontal: true).
  /// 3. CrossAxisAlignment.center ensures horizontal tiles touch vertical double tiles
  ///    EXACTLY at the middle waist ("فى المنتصف") aligned with the dividing pin.
  /// 4. End tiles glow directly when valid.
  /// 5. A subtle glowing domino ghost slot appears at the open side of the last valid card.
  /// 6. Dropping on the card, ghost slot, or table side executes the move smoothly.
  Widget _buildDominoChain(
    List<PlacedDomino> board, {
    required bool canPlayLeft,
    required bool canPlayRight,
  }) {
    if (board.isEmpty) return const SizedBox.shrink();

    // Auto-scale to ensure long domino chains remain visible on screen
    final double unscaledWidth = board.fold<double>(
      0.0,
      (sum, p) => sum + (p.isDouble ? 27.w : 51.w),
    );
    final double autoScale = (680.w / unscaledWidth).clamp(0.65, 1.0);

    // CRITICAL: We enforce TextDirection.ltr for the Domino chain so that
    // board[0] (Left end) is laid out on the physical LEFT, and board[N-1] (Right end)
    // is laid out on the physical RIGHT.
    // This guarantees matching touching values meet physically!
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onDoubleTap: () {
          // Reset zoom & pan on double tap
          _transformController.value = Matrix4.identity();
        },
        child: InteractiveViewer(
          transformationController: _transformController,
          minScale: 0.35,
          maxScale: 2.5,
          boundaryMargin: EdgeInsets.symmetric(horizontal: 400.w, vertical: 150.h),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Ghost Slot (at the left open side of the chain)
                  if (canPlayLeft && board.length > 1)
                    _buildGhostSlot(
                      DominoEdgeLocation.left,
                      autoScale,
                      _hoveredEdge == DominoEdgeLocation.left,
                    ),

                  // Domino chain tiles
                  ...List.generate(board.length, (i) {
                    final placed = board[i];
                    final isFirst = (i == 0);
                    final isLast = (i == board.length - 1);

                    return _buildTileWidget(
                      placed: placed,
                      index: i,
                      isFirst: isFirst,
                      isLast: isLast,
                      totalTiles: board.length,
                      canPlayLeft: canPlayLeft,
                      canPlayRight: canPlayRight,
                      scale: autoScale,
                    );
                  }),

                  // Right Ghost Slot (at the right open side of the chain)
                  if (canPlayRight && board.length > 1)
                    _buildGhostSlot(
                      DominoEdgeLocation.right,
                      autoScale,
                      _hoveredEdge == DominoEdgeLocation.right,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds each tile widget.
  /// Middle tiles are clean and static.
  /// The last valid card at the end of the chain glows directly!
  Widget _buildTileWidget({
    required PlacedDomino placed,
    required int index,
    required bool isFirst,
    required bool isLast,
    required int totalTiles,
    required bool canPlayLeft,
    required bool canPlayRight,
    required double scale,
  }) {
    final isDouble = placed.isDouble;
    final isHorizontal = !isDouble;

    // Single tile edge case (board.length == 1)
    if (totalTiles == 1) {
      return _buildSingleTileTarget(
        placed: placed,
        canPlayLeft: canPlayLeft,
        canPlayRight: canPlayRight,
        scale: scale,
      );
    }

    // Determine if this tile is an active end that should glow and accept drops
    Color? glowCol;
    DominoEdgeLocation? targetEdge;

    if (isFirst && canPlayLeft) {
      targetEdge = DominoEdgeLocation.left;
      glowCol = (_hoveredEdge == DominoEdgeLocation.left)
          ? const Color(0xFF00E676) // Vibrant Emerald when hovered towards this side
          : const Color(0xFF00E5FF); // Glowing Cyan for Left End
    } else if (isLast && canPlayRight) {
      targetEdge = DominoEdgeLocation.right;
      glowCol = (_hoveredEdge == DominoEdgeLocation.right)
          ? const Color(0xFF00E676) // Vibrant Emerald when hovered towards this side
          : const Color(0xFFFFD700); // Glowing Gold for Right End
    }

    final Widget baseTile = Domino3DTile(
      top: placed.leftValue,
      bottom: placed.rightValue,
      isHorizontal: isHorizontal,
      onTable: true,
      scale: scale,
      glowColor: glowCol,
    );

    if (targetEdge == null) {
      // Middle tile: static, clean, zero interaction
      return baseTile;
    }

    // Active end tile: Wrap with DragTarget and GestureDetector
    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) =>
          widget.engine.getValidEdgesFor(details.data).contains(targetEdge),
      onAcceptWithDetails: (details) {
        setState(() {
          _hoveredEdge = null;
          _draggedPiece = null;
        });
        widget.onPlacePiece?.call(details.data, targetEdge!);
      },
      onMove: (details) {
        if (_hoveredEdge != targetEdge || _draggedPiece != details.data) {
          setState(() {
            _hoveredEdge = targetEdge;
            _draggedPiece = details.data;
          });
        }
      },
      onLeave: (_) {
        if (_hoveredEdge == targetEdge) {
          setState(() {
            _hoveredEdge = null;
            _draggedPiece = null;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty || (_hoveredEdge == targetEdge);
        final activeGlow = isHovered ? const Color(0xFF00E676) : glowCol;

        return GestureDetector(
          onTap: () {
            final piece = widget.selectedPiece ?? _draggedPiece;
            if (piece != null) {
              widget.onPlacePiece?.call(piece, targetEdge!);
            }
          },
          child: Domino3DTile(
            top: placed.leftValue,
            bottom: placed.rightValue,
            isHorizontal: isHorizontal,
            onTable: true,
            scale: scale,
            glowColor: activeGlow,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                duration: isHovered ? 450.ms : 800.ms,
                begin: const Offset(0.97, 0.97),
                end: const Offset(1.05, 1.05),
              ),
        );
      },
    );
  }

  /// Builds a subtle domino ghost slot directly adjacent to an active end card ("ناحيته")
  /// Completely wordless, perfectly sized like a domino tile, with neon border and pulse.
  Widget _buildGhostSlot(DominoEdgeLocation edge, double scale, bool isHovered) {
    final isLeft = edge == DominoEdgeLocation.left;
    final defaultColor = isLeft ? const Color(0xFF00E5FF) : const Color(0xFFFFD700);

    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) =>
          widget.engine.getValidEdgesFor(details.data).contains(edge),
      onAcceptWithDetails: (details) {
        setState(() {
          _hoveredEdge = null;
          _draggedPiece = null;
        });
        widget.onPlacePiece?.call(details.data, edge);
      },
      onMove: (details) {
        if (_hoveredEdge != edge || _draggedPiece != details.data) {
          setState(() {
            _hoveredEdge = edge;
            _draggedPiece = details.data;
          });
        }
      },
      onLeave: (_) {
        if (_hoveredEdge == edge) {
          setState(() {
            _hoveredEdge = null;
            _draggedPiece = null;
          });
        }
      },
      builder: (context, candidateData, rejectedData) {
        final hovered = candidateData.isNotEmpty || isHovered;
        final color = hovered ? const Color(0xFF00E676) : defaultColor;

        return GestureDetector(
          onTap: () {
            final piece = widget.selectedPiece ?? _draggedPiece;
            if (piece != null) {
              widget.onPlacePiece?.call(piece, edge);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44.w * scale,
            height: 22.h * scale,
            margin: EdgeInsets.symmetric(horizontal: 3.w * scale),
            decoration: BoxDecoration(
              color: color.withValues(alpha: hovered ? 0.35 : 0.12),
              borderRadius: BorderRadius.circular(6.r * scale),
              border: Border.all(
                color: color,
                width: hovered ? 2.2.w : 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: hovered ? 0.7 : 0.35),
                  blurRadius: hovered ? 14.r : 8.r,
                  spreadRadius: hovered ? 2.r : 0.5.r,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                hovered ? Icons.check_rounded : Icons.add_rounded,
                color: color,
                size: 13.r * scale,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                duration: hovered ? 450.ms : 800.ms,
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
              ),
        );
      },
    );
  }

  /// Builds the single tile target when the board has only 1 placed tile
  Widget _buildSingleTileTarget({
    required PlacedDomino placed,
    required bool canPlayLeft,
    required bool canPlayRight,
    required double scale,
  }) {
    final isDouble = placed.isDouble;
    final isHorizontal = !isDouble;

    Color? glowCol;
    if (_hoveredEdge != null) {
      if ((_hoveredEdge == DominoEdgeLocation.left && canPlayLeft) ||
          (_hoveredEdge == DominoEdgeLocation.right && canPlayRight)) {
        glowCol = const Color(0xFF00E676);
      }
    } else if (canPlayLeft && canPlayRight) {
      glowCol = const Color(0xFFFFD700);
    } else if (canPlayLeft) {
      glowCol = const Color(0xFF00E5FF);
    } else if (canPlayRight) {
      glowCol = const Color(0xFFFFD700);
    }

    final tileWidget = GestureDetector(
      onTap: () {
        final piece = widget.selectedPiece ?? _draggedPiece;
        if (piece != null) {
          final edge = canPlayRight ? DominoEdgeLocation.right : DominoEdgeLocation.left;
          widget.onPlacePiece?.call(piece, edge);
        }
      },
      child: Domino3DTile(
        top: placed.leftValue,
        bottom: placed.rightValue,
        isHorizontal: isHorizontal,
        onTable: true,
        scale: scale,
        glowColor: glowCol,
      )
          .animate(target: glowCol != null ? 1 : 0)
          .scale(duration: 600.ms, begin: const Offset(0.97, 0.97), end: const Offset(1.05, 1.05)),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (canPlayLeft)
          _buildGhostSlot(
            DominoEdgeLocation.left,
            scale,
            _hoveredEdge == DominoEdgeLocation.left,
          ),
        tileWidget,
        if (canPlayRight)
          _buildGhostSlot(
            DominoEdgeLocation.right,
            scale,
            _hoveredEdge == DominoEdgeLocation.right,
          ),
      ],
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
