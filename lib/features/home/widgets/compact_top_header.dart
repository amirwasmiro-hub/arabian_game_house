import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/providers/game_user_provider.dart';

class CompactTopHeader extends StatelessWidget {
  final String? title;
  final VoidCallback? onProfileTap;
  final VoidCallback? onAddCoinsTap;
  final VoidCallback? onAddTicketsTap;
  final VoidCallback? onOffersTap;

  const CompactTopHeader({
    super.key,
    this.title,
    this.onProfileTap,
    this.onAddCoinsTap,
    this.onAddTicketsTap,
    this.onOffersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GameUserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final ping = userProvider.pingMs;
        final isOnline = userProvider.isOnline;

        Color pingColor = const Color(0xFF00E676);
        if (!isOnline || ping > 200) {
          pingColor = const Color(0xFFFF1744);
        } else if (ping > 100) {
          pingColor = const Color(0xFFFFD600);
        }

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            height: 38.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [
                    // 1. Avatar, Level & VIP Crown (Compact & Cached)
                    GestureDetector(
                      onTap: onProfileTap,
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 30.w,
                                height: 30.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 1.5.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                                      blurRadius: 6.r,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user.avatarUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.amber.shade900,
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.amber.shade900,
                                      child: const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // VIP Crown Mini Badge
                              Positioned(
                                top: -6.h,
                                right: -4.w,
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF9100),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.military_tech_rounded,
                                    size: 9.r,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 5.w),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8E24AA), Color(0xFF4A148C)],
                                  ),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                                    width: 0.8.w,
                                  ),
                                ),
                                child: Text(
                                  user.vipTier,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 7.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'LV. ${user.level}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 7.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 8.w),

                    // 2. Gold Coins Pill (Animated Balance)
                    _buildCompactPill(
                      icon: Icons.monetization_on_rounded,
                      iconColor: const Color(0xFFFFD700),
                      value: _formatCompactNumber(user.coins),
                      onAddTap: onAddCoinsTap,
                    ),

                    SizedBox(width: 5.w),

                    // 3. Green Tickets / Diamonds Pill
                    _buildCompactPill(
                      icon: Icons.diamond_rounded,
                      iconColor: const Color(0xFF00E5FF),
                      value: '${user.gems}',
                      onAddTap: onAddTicketsTap,
                    ),

                    const Spacer(),

                    // 4. Domino Cafe Style Live Ping Indicator (ms)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: pingColor.withValues(alpha: 0.6),
                          width: 0.8.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: pingColor,
                              boxShadow: [
                                BoxShadow(
                                  color: pingColor.withValues(alpha: 0.8),
                                  blurRadius: 4.r,
                                ),
                              ],
                            ),
                          )
                              .animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .scale(duration: 1000.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
                          SizedBox(width: 4.w),
                          Text(
                            isOnline ? '$ping ms' : 'Offline',
                            style: GoogleFonts.montserrat(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w700,
                              color: pingColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 6.w),

                    // 5. Special Offers & Super Bonus Gift Icon
                    GestureDetector(
                      onTap: onOffersTap,
                      child: Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFF6F00)],
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          color: const Color(0xFF3E2723),
                          size: 15.r,
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .scale(duration: 700.ms, begin: const Offset(0.95, 0.95), end: const Offset(1.1, 1.1))
                          .shimmer(duration: 2000.ms, color: Colors.white),
                    ),
                  ],
                ),

                // Centered App/Game Title
                if (title != null)
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.7),
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          title!,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFFD700),
                            letterSpacing: 0.5.w,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFFFD700),
                                blurRadius: 6.r,
                              ),
                              const Shadow(
                                color: Colors.black,
                                blurRadius: 3,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  Widget _buildCompactPill({
    required IconData icon,
    required Color iconColor,
    required String value,
    VoidCallback? onAddTap,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 14.r),
          SizedBox(width: 4.w),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 10.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
