import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'domino_face_down_tile.dart';

class DominoPlayerHud extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String flag;
  final String vipTier;
  final int coins;
  final int tilesCount;
  final bool isCurrentTurn;
  final int remainingSeconds;
  final String? activeSpeechBubble;
  final VoidCallback? onAvatarTap;
  final bool showFaceDownTiles;

  const DominoPlayerHud({
    super.key,
    required this.name,
    required this.avatarUrl,
    this.flag = '🇪🇬',
    this.vipTier = 'VIP 3',
    required this.coins,
    required this.tilesCount,
    required this.isCurrentTurn,
    this.remainingSeconds = 15,
    this.activeSpeechBubble,
    this.onAvatarTap,
    this.showFaceDownTiles = false,
  });

  @override
  Widget build(BuildContext context) {
    final timerProgress = (remainingSeconds / 15.0).clamp(0.0, 1.0);
    final isUrgent = remainingSeconds <= 4;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Main Avatar Card
            GestureDetector(
              onTap: onAvatarTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isCurrentTurn
                        ? (isUrgent ? const Color(0xFFFF1744) : const Color(0xFFFFD700))
                        : Colors.white24,
                    width: isCurrentTurn ? 1.5.w : 0.8.w,
                  ),
                  boxShadow: isCurrentTurn
                      ? [
                          BoxShadow(
                            color: (isUrgent ? const Color(0xFFFF1744) : const Color(0xFFFFD700))
                                .withValues(alpha: 0.5),
                            blurRadius: 10.r,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar with Circular Countdown Ring
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isCurrentTurn)
                          SizedBox(
                            width: 32.w,
                            height: 32.w,
                            child: CircularProgressIndicator(
                              value: timerProgress,
                              strokeWidth: 2.2.w,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isUrgent ? const Color(0xFFFF1744) : const Color(0xFFFFD700),
                              ),
                              backgroundColor: Colors.white12,
                            ),
                          ),
                        Container(
                          width: 26.w,
                          height: 26.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: avatarUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: Colors.amber.shade900,
                                child: const Icon(Icons.person, color: Colors.white, size: 14),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.amber.shade900,
                                child: const Icon(Icons.person, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ),
                        // VIP Badge
                        Positioned(
                          bottom: -2.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E24AA),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: const Color(0xFFFFD700), width: 0.5.w),
                            ),
                            child: Text(
                              vipTier,
                              style: GoogleFonts.montserrat(
                                fontSize: 5.5.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFFD700),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 6.w),

                    // Name, Flag & Coins/Timer (Badge "القطع" deleted per user request)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(flag, style: TextStyle(fontSize: 9.sp)),
                            SizedBox(width: 3.w),
                            Text(
                              name,
                              style: GoogleFonts.cairo(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Coins Pill
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                  width: 0.5.w,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.monetization_on_rounded, color: const Color(0xFFFFD700), size: 7.5.r),
                                  SizedBox(width: 2.w),
                                  Text(
                                    _formatCoins(coins),
                                    style: GoogleFonts.montserrat(
                                      fontSize: 6.5.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFFD700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCurrentTurn) ...[
                              SizedBox(width: 4.w),
                              Text(
                                '⏱️ ${remainingSeconds}s',
                                style: GoogleFonts.montserrat(
                                  fontSize: 7.sp,
                                  fontWeight: FontWeight.w900,
                                  color: isUrgent ? const Color(0xFFFF1744) : const Color(0xFFFFD700),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Face-Down Remaining Tiles Rack (Opponent remaining cards like draw tiles)
            if (showFaceDownTiles && tilesCount > 0) ...[
              SizedBox(height: 3.h),
              _buildOpponentTilesRack(),
            ],
          ],
        ),

        // Speech Bubble
        if (activeSpeechBubble != null)
          Positioned(
            top: -24.h,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 6)],
              ),
              child: Text(
                activeSpeechBubble!,
                style: GoogleFonts.cairo(
                  fontSize: 7.5.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Face-down porcelain domino cards arranged neatly beneath opponent avatar, matching draw tiles
  Widget _buildOpponentTilesRack() {
    if (tilesCount <= 0) return const SizedBox.shrink();
    final count = tilesCount.clamp(0, 14);
    final double tileW = 15.0.w;
    final double tileH = 8.5.h;

    // Spacing between tile starts so they fit neatly in up to 96.w width without negative margins
    final double spacing = count > 1
        ? ((96.w - tileW) / (count - 1)).clamp(5.w, 13.w)
        : 0.0;
    final double totalWidth = count > 1 ? (count - 1) * spacing + tileW : tileW;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
          width: 0.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: totalWidth,
        height: tileH,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(count, (index) {
            return Positioned(
              left: index * spacing,
              top: 0,
              child: const DominoFaceDownTile(
                width: 15.0,
                height: 8.5,
                margin: EdgeInsets.zero,
              ),
            );
          }),
        ),
      ),
    );
  }

  static String _formatCoins(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
