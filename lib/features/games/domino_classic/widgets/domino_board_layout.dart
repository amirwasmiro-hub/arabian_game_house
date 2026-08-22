import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/domino_classic_engine.dart';
import '../models/domino_piece.dart';
import 'domino_tile_widget.dart';

class DominoBoardLayout extends StatelessWidget {
  final DominoClassicEngine engine;
  final DominoPiece? selectedPiece;
  final DominoTileStyle style;
  final Function(DominoPiece piece, DominoEdgeLocation edge)? onPlacePiece;

  const DominoBoardLayout({
    super.key,
    required this.engine,
    this.selectedPiece,
    this.style = DominoTileStyle.classicIvory,
    this.onPlacePiece,
  });

  @override
  Widget build(BuildContext context) {
    final validEdges = selectedPiece != null ? engine.getValidEdgesFor(selectedPiece!) : <DominoEdgeLocation>[];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B1E),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4), width: 3),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 20),
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.white12, width: 0.5)),
                ),
              ),
            ),
          ),
          if (engine.spinnerTile == null && engine.rowWest.isEmpty && engine.rowEast.isEmpty)
            Center(
              child: DragTarget<DominoPiece>(
                onWillAcceptWithDetails: (details) => true,
                onAcceptWithDetails: (details) {
                  if (onPlacePiece != null) onPlacePiece!(details.data, DominoEdgeLocation.east);
                },
                builder: (context, candidateData, rejectedData) {
                  final isHovered = candidateData.isNotEmpty;
                  final borderCol = isHovered ? Colors.greenAccent : const Color(0xFFFFD700);

                  return GestureDetector(
                    onTap: () {
                      if (selectedPiece != null && onPlacePiece != null) {
                        onPlacePiece!(selectedPiece!, DominoEdgeLocation.east);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isHovered ? Icons.system_update_alt_rounded : Icons.grid_on_rounded,
                          size: 48.r,
                          color: borderCol.withValues(alpha: isHovered ? 0.9 : 0.4),
                        ),
                        SizedBox(height: 8.h),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: borderCol.withValues(alpha: isHovered ? 0.35 : 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: borderCol, width: isHovered ? 2.5 : 1.5),
                          ),
                          child: Text(
                            isHovered ? 'اترك الحجر هنا للنزول الأول! 🀄' : 'اسحب أو اضغط لوضع النقلة الأولى 🀄',
                            style: GoogleFonts.cairo(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (validEdges.contains(DominoEdgeLocation.west) || selectedPiece == null)
                      _buildDropTarget('الغرْب', DominoEdgeLocation.west, Colors.amberAccent),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: engine.rowWest.map((bt) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                          child: DominoTileWidget(
                            piece: bt.piece,
                            onTable: true,
                            isVerticalOnTable: bt.isVertical,
                            style: style,
                          ),
                        );
                      }).toList(),
                    ),

                    if (engine.spinnerTile != null)
                      Container(
                        padding: EdgeInsets.all(2.r),
                        child: DominoTileWidget(
                          piece: engine.spinnerTile!.piece,
                          onTable: true,
                          isVerticalOnTable: true,
                          style: style,
                        ),
                      ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: engine.rowEast.map((bt) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                          child: DominoTileWidget(
                            piece: bt.piece,
                            onTable: true,
                            isVerticalOnTable: bt.isVertical,
                            style: style,
                          ),
                        );
                      }).toList(),
                    ),

                    if (validEdges.contains(DominoEdgeLocation.east) || selectedPiece == null)
                      _buildDropTarget('الشرْق', DominoEdgeLocation.east, Colors.amberAccent),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropTarget(String label, DominoEdgeLocation edge, Color color) {
    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) => engine.getValidEdgesFor(details.data).contains(edge),
      onAcceptWithDetails: (details) {
        if (onPlacePiece != null) onPlacePiece!(details.data, edge);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        final activeColor = isHovered ? Colors.greenAccent : color;

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
