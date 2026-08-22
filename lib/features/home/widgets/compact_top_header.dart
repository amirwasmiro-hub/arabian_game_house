import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                // Avatar & Level (Compact)
                GestureDetector(
                  onTap: onProfileTap,
                  child: Row(
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
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
                        child: CircleAvatar(
                          backgroundColor: Colors.amber.shade900,
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 16.r,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          'LV. 5',
                          style: GoogleFonts.montserrat(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10.w),

                // Gold Coins Pill (Compact 500K)
                _buildCompactPill(
                  icon: Icons.monetization_on_rounded,
                  iconColor: const Color(0xFFFFD700),
                  value: '500K',
                  onAddTap: onAddCoinsTap,
                ),

                SizedBox(width: 6.w),

                // Green Tickets Pill (Compact 650)
                _buildCompactPill(
                  icon: Icons.local_activity_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  value: '650',
                  onAddTap: onAddTicketsTap,
                ),

                const Spacer(),

                // Special Offers Gift Icon
                GestureDetector(
                  onTap: onOffersTap,
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        width: 1.w,
                      ),
                    ),
                    child: Icon(
                      Icons.card_giftcard_rounded,
                      color: const Color(0xFFFFD700),
                      size: 15.r,
                    ),
                  ),
                ),
              ],
            ),

            // Centered Game Title
            if (title != null)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                      width: 1.2.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        blurRadius: 10.r,
                      ),
                    ],
                  ),
                  child: Text(
                    title!,
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFD700),
                      letterSpacing: 1.w,
                      shadows: [
                        Shadow(
                          color: const Color(0xFFFFD700),
                          blurRadius: 8.r,
                        ),
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4.r,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
        color: Colors.black.withValues(alpha: 0.4),
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
