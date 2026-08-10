import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RoyalGoldBottomBar extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onAddCoinsTap;
  final VoidCallback? onAddTicketsTap;
  final VoidCallback? onExchangeTap;
  final VoidCallback? onOffersTap;
  final VoidCallback? onPlayNowTap;

  const RoyalGoldBottomBar({
    super.key,
    this.onProfileTap,
    this.onAddCoinsTap,
    this.onAddTicketsTap,
    this.onExchangeTap,
    this.onOffersTap,
    this.onPlayNowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 56.h,
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2A1005),
              Color(0xFF180802),
              Color(0xFF2A1005),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(
            color: const Color(0xFFFFD700),
            width: 2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
              blurRadius: 16.r,
              spreadRadius: 1.r,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. VIP Avatar with Royal Ornament Frame
            GestureDetector(
              onTap: onProfileTap,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          blurRadius: 10.r,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(2.w),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4A148C),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.amber.shade200,
                        size: 22.r,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2.h,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white, width: 1.w),
                      ),
                      child: Text(
                        'VIP 5',
                        style: GoogleFonts.cairo(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 14.w),

            // 2. 3D Gold Coins Counter Pill (500K)
            _build3DCurrencyPill(
              icon: Icons.monetization_on_rounded,
              iconGradient: const [Color(0xFFFFE082), Color(0xFFFFB300)],
              value: '500K',
              badgeColor: const Color(0xFFFFD700),
              onAddTap: onAddCoinsTap,
            ),

            SizedBox(width: 8.w),

            // 3. 3D Green Ticket Counter Pill (650)
            _build3DCurrencyPill(
              icon: Icons.local_activity_rounded,
              iconGradient: const [Color(0xFFA5D6A7), Color(0xFF2E7D32)],
              value: '650',
              badgeColor: const Color(0xFF4CAF50),
              onAddTap: onAddTicketsTap,
            ),

            SizedBox(width: 8.w),

            // 4. Exchange Button (استبدال)
            GestureDetector(
              onTap: onExchangeTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFFA5D6A7),
                    width: 1.2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.5),
                      blurRadius: 6.r,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 14.r,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'استبدال',
                      style: GoogleFonts.cairo(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 6.w),

            // 5. Offers Gift Icon (عروض)
            GestureDetector(
              onTap: onOffersTap,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6F00), Color(0xFFFFC107)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.7),
                      blurRadius: 8.r,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 16.r,
                ),
              ),
            ),

            const Spacer(),

            // 6. Prominent Royal 3D "العب الآن" Play Now Button
            GestureDetector(
              onTap: onPlayNowTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF8F00),
                      Color(0xFFFF3D00),
                      Color(0xFFDD2C00),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 2.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3D00).withValues(alpha: 0.8),
                      blurRadius: 12.r,
                      spreadRadius: 1.r,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'العب الآن',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4.r,
                            offset: const Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DCurrencyPill({
    required IconData icon,
    required List<Color> iconGradient,
    required String value,
    required Color badgeColor,
    VoidCallback? onAddTap,
  }) {
    return Container(
      height: 30.h,
      padding: EdgeInsets.only(right: 6.w, left: 3.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.8),
          width: 1.2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.3),
            blurRadius: 6.r,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: iconGradient,
            ).createShader(bounds),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18.r,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 11.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
