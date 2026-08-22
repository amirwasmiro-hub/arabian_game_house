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
            color: Colors.black.withValues(alpha: 0.35),
            border: Border.all(
              color: widget.cardBorderColor,
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.cardBorderColor.withValues(alpha: 0.3),
                blurRadius: 8.r,
                spreadRadius: 0.5.r,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 6.r,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Stack(
              children: [
                // 1. GAME ARTWORK (SEMI-TRANSPARENT WITH SHIMMER)
                if (widget.assetPath != null)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.60,
                      child: Image.asset(
                        widget.assetPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallbackIcon(),
                      ),
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

                // 2. GLASSMORPHIC TOP & BOTTOM GRADIENT OVERLAY
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // 3. ANIMATED "NEW" BADGE
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.7),
                            blurRadius: 6.r,
                          ),
                        ],
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

                // 4. ANIMATED ARABIC GAME TITLE WITH GLOW
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
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 5.r,
                              offset: const Offset(1, 1),
                            ),
                            Shadow(
                              color: const Color(0xFFFFD700)
                                  .withValues(alpha: 0.8),
                              blurRadius: 8.r,
                            ),
                          ],
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
                          color: Colors.white70,
                          letterSpacing: 0.8.w,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 3.r,
                              offset: const Offset(1, 1),
                            ),
                          ],
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
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            widget.cardBgColor.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
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
