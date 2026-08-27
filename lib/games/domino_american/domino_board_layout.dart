import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'domino_american_engine.dart';
import '../domino_classic/domino_piece.dart';
import '../domino_classic/domino_3d_tile.dart';

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
    final isNorthSouthUnlocked = engine.spinner != null && engine.armWest.isNotEmpty && engine.armEast.isNotEmpty;

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
          if (engine.isBoardEmpty)
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
                            selectedPiece != null
                                ? 'اضغط للنزول بـ [${selectedPiece!.a}:${selectedPiece!.b}] 🀄'
                                : 'اختر قطعتك للنزول الأول 🀄',
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
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // West Open Target
                      _buildDropTarget('الغرْب ⬅️', DominoEdgeLocation.west, validEdges.contains(DominoEdgeLocation.west)),

                      // West Arm Tiles (reversed to display outward from center)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: engine.armWest.reversed.map((placed) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 1.w),
                            child: Domino3DTile(
                              top: placed.outwardValue,
                              bottom: placed.inwardValue,
                              isHorizontal: !placed.isDouble,
                              onTable: true,
                            ),
                          );
                        }).toList(),
                      ),

                      // Center Column: North Arm + Spinner + South Arm (scaled down to fit vertical bounds)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // North Open Target (only if unlocked)
                            if (isNorthSouthUnlocked)
                              _buildDropTarget('الشمال ⬆️', DominoEdgeLocation.north, validEdges.contains(DominoEdgeLocation.north), isCompact: true),

                            // North Arm Tiles
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: engine.armNorth.reversed.map((placed) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  child: Domino3DTile(
                                    top: placed.outwardValue,
                                    bottom: placed.inwardValue,
                                    isHorizontal: placed.isDouble,
                                    onTable: true,
                                  ),
                                );
                              }).toList(),
                            ),

                            // Center Spinner Double
                            if (engine.spinner != null)
                              Padding(
                                padding: EdgeInsets.all(2.r),
                                child: Domino3DTile(
                                  top: engine.spinner!.piece.top,
                                  bottom: engine.spinner!.piece.bottom,
                                  isHorizontal: false,
                                  onTable: true,
                                ),
                              ),

                            // South Arm Tiles
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: engine.armSouth.map((placed) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  child: Domino3DTile(
                                    top: placed.inwardValue,
                                    bottom: placed.outwardValue,
                                    isHorizontal: placed.isDouble,
                                    onTable: true,
                                  ),
                                );
                              }).toList(),
                            ),

                            // South Open Target (only if unlocked)
                            if (isNorthSouthUnlocked)
                              _buildDropTarget('الجنوب ⬇️', DominoEdgeLocation.south, validEdges.contains(DominoEdgeLocation.south), isCompact: true),
                          ],
                        ),
                      ),

                      // East Arm Tiles
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: engine.armEast.map((placed) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 1.w),
                            child: Domino3DTile(
                              top: placed.inwardValue,
                              bottom: placed.outwardValue,
                              isHorizontal: !placed.isDouble,
                              onTable: true,
                            ),
                          );
                        }).toList(),
                      ),

                      // East Open Target
                      _buildDropTarget('الشرْق ➡️', DominoEdgeLocation.east, validEdges.contains(DominoEdgeLocation.east)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropTarget(String label, DominoEdgeLocation edge, bool isValid, {bool isCompact = false}) {
    return DragTarget<DominoPiece>(
      onWillAcceptWithDetails: (details) => engine.getValidEdgesFor(details.data).contains(edge),
      onAcceptWithDetails: (details) {
        onPlacePiece?.call(details.data, edge);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        final activeColor = isHovered
            ? Colors.greenAccent
            : (isValid ? const Color(0xFF00E5FF) : const Color(0xFFFFD700));

        return GestureDetector(
          onTap: () {
            if (isValid && selectedPiece != null && onPlacePiece != null) {
              onPlacePiece!(selectedPiece!, edge);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: isCompact ? 1.h : 2.h),
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 6.w : 8.w, vertical: isCompact ? 3.h : 8.h),
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: isHovered ? 0.45 : (isValid ? 0.35 : 0.15)),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: activeColor, width: isValid ? 2.5.w : 1.2.w),
              boxShadow: isValid
                  ? [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.5),
                        blurRadius: 8.r,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHovered ? Icons.check_circle_rounded : Icons.touch_app_rounded,
                  color: Colors.white,
                  size: isCompact ? 13.r : 16.r,
                ),
                if (!isCompact) SizedBox(height: 2.h),
                Text(
                  label,
                  style: GoogleFonts.cairo(color: Colors.white, fontSize: isCompact ? 6.5.sp : 8.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
