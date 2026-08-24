import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'star_explosion_overlay.dart';

class DominoGameCard extends StatefulWidget {
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final String? assetPath;
  final Color cardBgColor;
  final Color cardBorderColor;
  final bool isNew;
  final VoidCallback onTap;

  const DominoGameCard({
    super.key,
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    this.assetPath,
    required this.cardBgColor,
    required this.cardBorderColor,
    this.isNew = false,
    required this.onTap,
  });

  @override
  State<DominoGameCard> createState() => _DominoGameCardState();
}

class _DominoGameCardState extends State<DominoGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        StarExplosionOverlay.spawnExplosion(context, details.globalPosition);
        _pressController.forward();
      },
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 105.w,
          height: 75.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: widget.cardBgColor,
            border: Border.all(
              color: widget.cardBorderColor,
              width: 1.2.w,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Stack(
              children: [
                // 1. GAME ARTWORK (SOLID 100% OPAQUE)
                if (widget.assetPath != null)
                  Positioned.fill(
                    child: Image.asset(
                      widget.assetPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackIcon(),
                    )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .shimmer(
                          duration: 2500.ms,
                          color:
                              const Color(0xFFFFD700).withValues(alpha: 0.25),
                        ),
                  )
                else
                  _buildFallbackIcon(),

                // 2. ANIMATED "NEW" BADGE
                if (widget.isNew)
                  Positioned(
                    top: 5.h,
                    right: 5.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF1744), Color(0xFFFF5252)],
                        ),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.white, width: 0.8.w),
                      ),
                      child: Text(
                        'NEW',
                        style: GoogleFonts.montserrat(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    )
                        .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true),
                        )
                        .scale(
                          duration: 800.ms,
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.05, 1.05),
                        ),
                  ),

                // 3. ARABIC & ENGLISH GAME TITLES (FLAT, NO SHADOWS)
                Positioned(
                  bottom: 6.h,
                  left: 4.w,
                  right: 4.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.titleAr,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD700),
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        widget.titleEn,
                        style: GoogleFonts.montserrat(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.8.w,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      color: widget.cardBgColor,
      child: Center(
        child: Icon(
          widget.icon,
          size: 52.r,
          color: const Color(0xFFFFD700),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              duration: 1500.ms,
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.1, 1.1),
            )
            .shimmer(
              duration: 2000.ms,
              color: Colors.amber.shade100,
            ),
      ),
    );
  }
}
