import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Renders a natural, static face-down Domino tile using Ivory / Bone Porcelain
/// material matching player tiles, with a central golden brass rivet pin.
/// No motion effects, no pulsing, and no glowing lights.
class DominoFaceDownTile extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isSelectable;
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const DominoFaceDownTile({
    super.key,
    this.onTap,
    this.isSelectable = false,
    this.width = 28.0,
    this.height = 14.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width.r,
        height: height.r,
        margin: margin ?? EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3.r),
          // Deep 3D Ivory Gradient Face (Real Porcelain/Bone Domino matching player tiles)
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF), // Bright reflection
              Color(0xFFFAF7EE), // Rich Ivory
              Color(0xFFEBE3D0), // Bone Tone
              Color(0xFFD4C8B0), // Shadowed base
            ],
            stops: [0.0, 0.25, 0.75, 1.0],
          ),
          border: Border.all(
            color: const Color(0xFF9E8F75).withValues(alpha: 0.8),
            width: 0.8.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 3.r,
              offset: const Offset(1, 1.5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Center Metallic Dividing Groove Line (subtle)
            Positioned(
              top: 1.5.h,
              bottom: 1.5.h,
              child: Container(
                width: 0.8.w,
                color: const Color(0xFF6B5B45).withValues(alpha: 0.35),
              ),
            ),
            // Central Golden Brass Rivet Pin
            Container(
              width: 4.r,
              height: 4.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFFF176), // Brass reflection
                    Color(0xFFFFD700), // Pure Gold
                    Color(0xFFB8860B), // Deep brass shadow
                  ],
                  stops: [0.0, 0.45, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 1.r,
                    offset: const Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
