import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'domino_classic_engine.dart';
import 'domino_piece.dart';
import 'domino_3d_tile.dart';
import 'domino_snake_layout.dart';

class DominoCafeBoard extends StatefulWidget {
  final DominoClassicEngine engine;
  final DominoPiece? selectedPiece;
  final Function(DominoPiece piece, DominoEdgeLocation edge)? onPlacePiece;
  final int totalPotCoins;
  final bool isDragging;

  const DominoCafeBoard({
    super.key,
    required this.engine,
    this.selectedPiece,
    this.onPlacePiece,
    this.totalPotCoins = 160000,
    this.isDragging = false,
  });

  @override
  State<DominoCafeBoard> createState() => _DominoCafeBoardState();
}

class _DominoCafeBoardState extends State<DominoCafeBoard> {
  double _zoomScale = 1.0;
  double _baseScale = 1.0;
  DominoEdgeLocation? _hoveredEdge;
  DominoPiece? _draggedPiece;

  @override
  void didUpdateWidget(covariant DominoCafeBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPiece == null && oldWidget.selectedPiece != null) {
      _hoveredEdge = null;
      _draggedPiece = null;
    }
    if (!widget.isDragging && oldWidget.isDragging) {
      _hoveredEdge = null;
      _draggedPiece = null;
    }
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth;
        final tableHeight = constraints.maxHeight;
        final halfWidth = tableWidth / 2;

        return GestureDetector(
          onScaleStart: (details) {
            _baseScale = _zoomScale;
          },
          onScaleUpdate: (details) {
            if (details.pointerCount >= 2) {
              setState(() {
                _zoomScale = (_baseScale * details.scale).clamp(0.6, 1.8);
              });
            }
          },
          onDoubleTap: () {
            setState(() {
              _zoomScale = 1.0;
            });
          },
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                setState(() {
                  final delta = pointerSignal.scrollDelta.dy < 0 ? 0.08 : -0.08;
                  _zoomScale = (_zoomScale + delta).clamp(0.6, 1.8);
                });
              }
            },
            child: Container(
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
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.08),
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

                  // 3. Interactive Domino Table Surface (Chain & Targets strictly anchored at center)
                  Positioned.fill(
                    child: Transform.scale(
                      scale: _zoomScale,
                      alignment: Alignment.center,
                      child: isFirstMove
                          ? _buildFirstMoveTarget()
                          : _buildDominoChain(
                              widget.engine.board,
                              canPlayLeft: canPlayLeft,
                              canPlayRight: canPlayRight,
                            ),
                    ),
                  ),

                  // 4. Subtle Zoom Controls (+ / 100% / -) at Top Left of Table
                  Positioned(
                    top: 8.h,
                    left: 10.w,
                    child: _buildZoomControls(),
                  ),

                  // 4. Broad Drop Zones (Left & Right halves of the table)
                  // Placed ON TOP of the table surface so drops anywhere on either half are captured instantly!
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: halfWidth,
                    child: IgnorePointer(
                      ignoring: !widget.isDragging,
                      child: _buildSideDropZone(
                          DominoEdgeLocation.left, halfWidth, tableHeight),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: halfWidth,
                    child: IgnorePointer(
                      ignoring: !widget.isDragging,
                      child: _buildSideDropZone(
                          DominoEdgeLocation.right, halfWidth, tableHeight),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Broad Drop Zone covering a full half of the table.
  /// When a player drags a piece towards that side, it triggers the glow on the END CARD,
  /// shows a subtle ambient highlight, and drops smoothly anywhere on that half.
  Widget _buildSideDropZone(
      DominoEdgeLocation edge, double width, double height) {
    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) {
        final piece = details.data;
        if (widget.engine.board.isEmpty) {
          // First move on empty table: accept valid lead piece anywhere on table
          return widget.engine.getValidEdgesFor(piece).isNotEmpty;
        }
        final valid = widget.engine.getValidEdgesFor(piece);
        // Strict: only accept if the piece can legally be played on THIS side
        return valid.contains(edge);
      },
      onAcceptWithDetails: (details) {
        final piece = details.data;
        setState(() {
          _hoveredEdge = null;
          _draggedPiece = null;
        });
        if (widget.engine.board.isEmpty) {
          widget.onPlacePiece?.call(piece, DominoEdgeLocation.right);
          return;
        }
        if (!widget.engine.getValidEdgesFor(piece).contains(edge)) return;
        widget.onPlacePiece?.call(piece, edge);
      },
      onMove: (details) {
        final piece = details.data;
        final valid = widget.engine.getValidEdgesFor(piece);
        final DominoEdgeLocation? effectiveEdge = widget.engine.board.isEmpty
            ? DominoEdgeLocation.right
            : (valid.contains(edge) ? edge : null);

        if (_hoveredEdge != effectiveEdge || _draggedPiece != piece) {
          setState(() {
            _hoveredEdge = effectiveEdge;
            _draggedPiece = piece;
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
        final isHovered = _hoveredEdge == edge &&
            (candidateData.isNotEmpty || widget.isDragging);
        final isLeft = edge == DominoEdgeLocation.left;
        final highlightColor =
            isLeft ? const Color(0xFF00E5FF) : const Color(0xFFFFD700);

        return GestureDetector(
          onTap: () {
            final piece = widget.selectedPiece ?? _draggedPiece;
            if (piece != null) {
              final valid = widget.engine.getValidEdgesFor(piece);
              if (valid.contains(edge)) {
                widget.onPlacePiece?.call(piece, edge);
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: width,
            height: height,
            decoration: BoxDecoration(
              // Extremely subtle emerald vignette highlight when hovering over this half of the table
              gradient: isHovered
                  ? RadialGradient(
                      center: isLeft
                          ? const Alignment(-0.6, 0.0)
                          : const Alignment(0.6, 0.0),
                      radius: 0.85,
                      colors: [
                        const Color(0xFF00E676).withValues(alpha: 0.12),
                        highlightColor.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    )
                  : null,
              color: Colors.transparent,
            ),
            child: const SizedBox.expand(),
          ),
        );
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
          final borderCol =
              isHovered ? const Color(0xFF00E676) : const Color(0xFFFFD700);

          return GestureDetector(
            onTap: () {
              final piece = widget.selectedPiece ?? _draggedPiece;
              if (piece != null) {
                widget.onPlacePiece?.call(piece, DominoEdgeLocation.right);
              }
            },
            child: AnimatedScale(
              scale: isHovered ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42.r,
                height: 21.r,
                decoration: BoxDecoration(
                  color: borderCol.withValues(alpha: isHovered ? 0.35 : 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: borderCol,
                    width: isHovered ? 2.2.w : 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          borderCol.withValues(alpha: isHovered ? 0.7 : 0.35),
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
              ),
            ),
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
  /// Builds a clean, continuous Domino chain following a 2D rectangular / snake path:
  /// 1. Double tiles stand VERTICALLY (isHorizontal: false).
  /// 2. Normal tiles lay HORIZONTALLY along the rows (isHorizontal: true).
  /// 3. Initial tile is anchored at center (0, 0) and cards never shift or shrink.
  /// 4. Right branch turns UP before the right edge and travels LEFT along the top row.
  /// 5. Left branch turns DOWN before the left edge and travels RIGHT along the bottom row.
  /// 6. Touching values always match physically.
  /// 7. End cards and ghost drop slots glow and accept drops/taps.
  Widget _buildDominoChain(
    List<PlacedDomino> board, {
    required bool canPlayLeft,
    required bool canPlayRight,
  }) {
    if (board.isEmpty) return const SizedBox.shrink();

    final layout = DominoSnakeLayout.compute(
      board: board,
      initialTileIndex: widget.engine.safeInitialTileIndex,
      tileShort: 21.r,
      tileLong: 42.r,
      gap: 2.r,
      rowSpacing: 21.r,
      includeGhosts: true,
    );

    const double boardCanvasWidth = 720.0;
    const double boardCanvasHeight = 240.0;
    final double originX = boardCanvasWidth.w / 2;
    final double originY = boardCanvasHeight.h / 2;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(
          width: boardCanvasWidth.w,
          height: boardCanvasHeight.h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Left Ghost Slot
              if (canPlayLeft && layout.leftGhost != null)
                Positioned(
                  left: originX +
                      layout.leftGhost!.x -
                      (layout.leftGhost!.width / 2),
                  top: originY +
                      layout.leftGhost!.y -
                      (layout.leftGhost!.height / 2),
                  width: layout.leftGhost!.width,
                  height: layout.leftGhost!.height,
                  child: _buildGhostSlot(
                    layout.leftGhost!,
                    _hoveredEdge == DominoEdgeLocation.left,
                  ),
                ),

              // Right Ghost Slot
              if (canPlayRight && layout.rightGhost != null)
                Positioned(
                  left: originX +
                      layout.rightGhost!.x -
                      (layout.rightGhost!.width / 2),
                  top: originY +
                      layout.rightGhost!.y -
                      (layout.rightGhost!.height / 2),
                  width: layout.rightGhost!.width,
                  height: layout.rightGhost!.height,
                  child: _buildGhostSlot(
                    layout.rightGhost!,
                    _hoveredEdge == DominoEdgeLocation.right,
                  ),
                ),

              // Placed Domino chain tiles
              ...layout.tiles.map((item) {
                return Positioned(
                  left: originX + item.x - (item.width / 2),
                  top: originY + item.y - (item.height / 2),
                  width: item.width,
                  height: item.height,
                  child: _buildTileWidget(
                    item: item,
                    totalTiles: board.length,
                    canPlayLeft: canPlayLeft,
                    canPlayRight: canPlayRight,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact, elegant zoom in / out / reset controls (+ / 100% / -)
  Widget _buildZoomControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4.r,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom Out (-)
          GestureDetector(
            onTap: () {
              setState(() {
                _zoomScale = (_zoomScale - 0.1).clamp(0.6, 1.8);
              });
            },
            child: Container(
              padding: EdgeInsets.all(2.5.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.remove_rounded,
                  color: const Color(0xFFFFD700), size: 12.r),
            ),
          ),
          SizedBox(width: 4.w),
          // Percentage / Reset
          GestureDetector(
            onTap: () {
              setState(() {
                _zoomScale = 1.0;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Text(
                '${(_zoomScale * 100).round()}%',
                style: GoogleFonts.montserrat(
                  fontSize: 7.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Zoom In (+)
          GestureDetector(
            onTap: () {
              setState(() {
                _zoomScale = (_zoomScale + 0.1).clamp(0.6, 1.8);
              });
            },
            child: Container(
              padding: EdgeInsets.all(2.5.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded,
                  color: const Color(0xFFFFD700), size: 12.r),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds each tile widget positioned in the 2D snake path.
  /// Middle tiles are clean and static.
  /// Active end cards glow and accept drop / tap.
  Widget _buildTileWidget({
    required DominoTileLayoutItem item,
    required int totalTiles,
    required bool canPlayLeft,
    required bool canPlayRight,
  }) {
    // Single tile edge case (board.length == 1)
    if (totalTiles == 1) {
      Color? singleGlow;
      DominoEdgeLocation? singleEdge;
      if (_hoveredEdge != null) {
        if ((_hoveredEdge == DominoEdgeLocation.left && canPlayLeft) ||
            (_hoveredEdge == DominoEdgeLocation.right && canPlayRight)) {
          singleGlow = const Color(0xFF00E676);
          singleEdge = _hoveredEdge;
        }
      } else if (canPlayLeft && canPlayRight) {
        singleGlow = const Color(0xFFFFD700);
        singleEdge = DominoEdgeLocation.right;
      } else if (canPlayLeft) {
        singleGlow = const Color(0xFF00E5FF);
        singleEdge = DominoEdgeLocation.left;
      } else if (canPlayRight) {
        singleGlow = const Color(0xFFFFD700);
        singleEdge = DominoEdgeLocation.right;
      }

      final baseTile = Domino3DTile(
        top: item.topValue,
        bottom: item.bottomValue,
        isHorizontal: item.isHorizontal,
        onTable: true,
        scale: 1.0,
        glowColor: singleGlow,
      );

      if (singleEdge == null) return baseTile;

      return GestureDetector(
        onTap: () {
          final piece = widget.selectedPiece ?? _draggedPiece;
          if (piece != null) {
            widget.onPlacePiece?.call(piece, singleEdge!);
          }
        },
        child: AnimatedScale(
          scale: _hoveredEdge != null ? 1.06 : (singleGlow != null ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: baseTile,
        ),
      );
    }

    // Multi-tile chain: determine if this tile is an active end
    Color? glowCol;
    DominoEdgeLocation? targetEdge;

    if (item.isFirst && canPlayLeft) {
      targetEdge = DominoEdgeLocation.left;
      glowCol = (_hoveredEdge == DominoEdgeLocation.left)
          ? const Color(0xFF00E676)
          : const Color(0xFF00E5FF);
    } else if (item.isLast && canPlayRight) {
      targetEdge = DominoEdgeLocation.right;
      glowCol = (_hoveredEdge == DominoEdgeLocation.right)
          ? const Color(0xFF00E676)
          : const Color(0xFFFFD700);
    }

    final Widget baseTile = Domino3DTile(
      top: item.topValue,
      bottom: item.bottomValue,
      isHorizontal: item.isHorizontal,
      onTable: true,
      scale: 1.0,
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
        final isHovered =
            candidateData.isNotEmpty || (_hoveredEdge == targetEdge);
        final activeGlow = isHovered ? const Color(0xFF00E676) : glowCol;

        return GestureDetector(
          onTap: () {
            final piece = widget.selectedPiece ?? _draggedPiece;
            if (piece != null) {
              widget.onPlacePiece?.call(piece, targetEdge!);
            }
          },
          child: AnimatedScale(
            scale: isHovered ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: Domino3DTile(
              top: item.topValue,
              bottom: item.bottomValue,
              isHorizontal: item.isHorizontal,
              onTable: true,
              scale: 1.0,
              glowColor: activeGlow,
            ),
          ),
        );
      },
    );
  }

  /// Builds a subtle domino ghost slot directly adjacent to an active end card ("ناحيته")
  /// Completely wordless, perfectly sized like a domino tile, with neon border and pulse.
  Widget _buildGhostSlot(DominoGhostLayoutItem ghostItem, bool isHovered) {
    final edge = ghostItem.edge;
    final isLeft = edge == DominoEdgeLocation.left;
    final defaultColor =
        isLeft ? const Color(0xFF00E5FF) : const Color(0xFFFFD700);

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
          child: AnimatedScale(
            scale: hovered ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: ghostItem.width,
              height: ghostItem.height,
              decoration: BoxDecoration(
                color: color.withValues(alpha: hovered ? 0.35 : 0.12),
                borderRadius: BorderRadius.circular(6.r),
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
                  size: 13.r,
                ),
              ),
            ),
          ),
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
