import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/domino_american_engine.dart';
import '../models/domino_piece.dart';
import '../../domino_classic/widgets/domino_3d_tile.dart';

class DominoBoardLayout extends StatelessWidget {
  final DominoAmericanEngine engine;
  final DominoPiece? selectedPiece;
  final Function(DominoPiece piece, DominoEdgeLocation edge)? onPlacePiece;

  const DominoBoardLayout({
    super.key,
    required this.engine,
    this.selectedPiece,
    this.onPlacePiece,
  });

  @override
  Widget build(BuildContext context) {
    final validEdges = selectedPiece != null ? engine.getValidEdgesFor(selectedPiece!) : <DominoEdgeLocation>[];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [
            Color(0xFF0F4D2A),
            Color(0xFF0A331C),
            Color(0xFF04180C),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6), width: 2.5.w),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (engine.spinnerTile == null && engine.rowWest.isEmpty && engine.rowEast.isEmpty)
            Center(
              child: DragTarget<DominoPiece>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  if (onPlacePiece != null) onPlacePiece!(details.data, DominoEdgeLocation.east);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovered = candidateData.isNotEmpty;
                  final borderCol = isHovered ? const Color(0xFF00E676) : const Color(0xFFFFD700);

                  return GestureDetector(
                    onTap: () {
                      if (selectedPiece != null && onPlacePiece != null) {
                        onPlacePiece!(selectedPiece!, DominoEdgeLocation.east);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: borderCol.withValues(alpha: isHovered ? 0.35 : 0.15),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: borderCol, width: isHovered ? 2.5.w : 1.5.w),
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
                            isHovered ? 'اترك الحجر هنا للنزول الأول! 🀄' : 'اضغط أو اسحب الحجر للنزول الأول 🀄',
                            style: GoogleFonts.cairo(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (validEdges.contains(DominoEdgeLocation.west) || selectedPiece == null)
                      _buildDropTarget('الغرْب', DominoEdgeLocation.west),

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

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (validEdges.contains(DominoEdgeLocation.north))
                          _buildDropTarget('الشمال', DominoEdgeLocation.north),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: engine.colNorth.map((bt) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              child: Domino3DTile(
                                top: bt.piece.top,
                                bottom: bt.piece.bottom,
                                isHorizontal: !bt.isVertical,
                                onTable: true,
                              ),
                            );
                          }).toList(),
                        ),

                        if (engine.spinnerTile != null)
                          Padding(
                            padding: EdgeInsets.all(2.r),
                            child: Domino3DTile(
                              top: engine.spinnerTile!.piece.top,
                              bottom: engine.spinnerTile!.piece.bottom,
                              isHorizontal: false,
                              onTable: true,
                            ),
                          ),

                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: engine.colSouth.map((bt) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              child: Domino3DTile(
                                top: bt.piece.top,
                                bottom: bt.piece.bottom,
                                isHorizontal: !bt.isVertical,
                                onTable: true,
                              ),
                            );
                          }).toList(),
                        ),

                        if (validEdges.contains(DominoEdgeLocation.south))
                          _buildDropTarget('الجنوب', DominoEdgeLocation.south),
                      ],
                    ),

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

                    if (validEdges.contains(DominoEdgeLocation.east) || selectedPiece == null)
                      _buildDropTarget('الشرْق', DominoEdgeLocation.east),
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
        if (onPlacePiece != null) onPlacePiece!(details.data, edge);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        final isValidSelected = selectedPiece != null && engine.getValidEdgesFor(selectedPiece!).contains(edge);
        final activeColor = isHovered
            ? Colors.greenAccent
            : (isValidSelected ? const Color(0xFF00E5FF) : const Color(0xFFFFD700));

        return GestureDetector(
          onTap: () {
            if (selectedPiece != null && onPlacePiece != null) {
              onPlacePiece!(selectedPiece!, edge);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: isHovered ? 0.45 : 0.25),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: activeColor, width: isHovered ? 3 : 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isHovered ? Icons.check_circle : Icons.add_circle, color: activeColor, size: 22.r),
                SizedBox(height: 2.h),
                Text(
                  isHovered ? 'اسقط هنا!' : label,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
