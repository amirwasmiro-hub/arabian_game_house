import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DominoTopHeader extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onAddCoinsTap;
  final VoidCallback? onAddTicketsTap;
  final VoidCallback? onExchangeTap;
  final VoidCallback? onOffersTap;

  const DominoTopHeader({
    super.key,
    this.onProfileTap,
    this.onAddCoinsTap,
    this.onAddTicketsTap,
    this.onExchangeTap,
    this.onOffersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          children: [
            // 1. Profile Avatar & Level
            GestureDetector(
              onTap: onProfileTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          blurRadius: 8.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/arabian_cafe_bg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.amber.shade200,
                        size: 24.r,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.w),
                      ),
                      child: Text(
                        'VIP',
                        style: GoogleFonts.cairo(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // 2. Currency Pill 1: Gold Coins (500K)
            _buildCurrencyPill(
              icon: Icons.monetization_on_rounded,
              iconColor: const Color(0xFFFFD700),
              value: '500K',
              onAddTap: onAddCoinsTap,
            ),

            SizedBox(width: 8.w),

            // 3. Currency Pill 2: Green Tickets / Cash (650)
            _buildCurrencyPill(
              icon: Icons.local_activity_rounded,
              iconColor: const Color(0xFF4CAF50),
              value: '650',
              onAddTap: onAddTicketsTap,
            ),

            SizedBox(width: 8.w),

            // 4. Exchange Button (استبدال)
            GestureDetector(
              onTap: onExchangeTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: const Color(0xFF81C784),
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.5),
                      blurRadius: 4.r,
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
                    SizedBox(width: 4.w),
                    Text(
                      'استبدال',
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: 8.w),

            // 5. Special Offers Icon (عروض)
            GestureDetector(
              onTap: onOffersTap,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8F00), Color(0xFFFFC107)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.6),
                      blurRadius: 6.r,
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

            // 6. UTC Time Badge (Top Right)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Text(
                'UTC+0 18:00',
                style: GoogleFonts.montserrat(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyPill({
    required IconData icon,
    required Color iconColor,
    required String value,
    VoidCallback? onAddTap,
  }) {
    return Container(
      height: 26.h,
      padding: EdgeInsets.only(right: 6.w, left: 2.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16.r),
          SizedBox(width: 4.w),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, color: Colors.white, size: 12.r),
            ),
          ),
        ],
      ),
    );
  }
}
