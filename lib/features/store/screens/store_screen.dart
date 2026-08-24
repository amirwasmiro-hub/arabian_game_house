import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/audio/sound_manager.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag_rounded,
                      color: OrientalTheme.primaryGold, size: 20.r),
                  SizedBox(width: 6.w),
                  Text(
                    'المتجر الملكي 🛒',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxHeight < 300;
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Coins Packages
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'حزم الكوينز 🪙',
                                    style: GoogleFonts.cairo(
                                      color: OrientalTheme.primaryGold,
                                      fontSize: isSmallScreen ? 10.sp : 11.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  GridView.count(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10.w,
                                    mainAxisSpacing: 10.h,
                                    childAspectRatio: isSmallScreen ? 2.2 : 1.8,
                                    children: [
                                      _buildStoreCard('10,000 ذهبية', '1.99\$', '🪙', OrientalTheme.primaryGold),
                                      _buildStoreCard('50,000 ذهبية', '4.99\$', '💰', OrientalTheme.accentOrange),
                                      _buildStoreCard('150,000 ذهبية', '9.99\$', '👑', OrientalTheme.primaryRed),
                                      _buildStoreCard('500,000 ذهبية', '24.99\$', '🏆', OrientalTheme.accentPurple),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 14.w),

                            // Customizations
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'أوراق وطاولات احترافية 🎴',
                                    style: GoogleFonts.cairo(
                                      color: OrientalTheme.primaryGold,
                                      fontSize: isSmallScreen ? 10.sp : 11.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  _buildCustomizationTile(
                                    title: 'ورق لعب الملكي الذهبي',
                                    desc: 'أوراق بتصميم كلاسيكي مذهب',
                                    price: '25,000 🪙',
                                    icon: Icons.style_rounded,
                                    accentColor: OrientalTheme.primaryGold,
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildCustomizationTile(
                                    title: 'طاولة المخمل الاندلسية',
                                    desc: 'مفرش مخملي ملكي فاخر',
                                    price: '50,000 🪙',
                                    icon: Icons.table_bar_rounded,
                                    accentColor: OrientalTheme.accentOrange,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(String title, String price, String emoji, Color accentColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: OrientalTheme.bgCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 22.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    price,
                    style: GoogleFonts.cairo(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 9.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationTile({
    required String title,
    required String desc,
    required String price,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: OrientalTheme.bgCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accentColor, size: 20.r),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.cairo(
                    color: OrientalTheme.textMuted,
                    fontSize: 8.sp,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () => SoundManager().playButtonClick(),
            child: Text(
              price,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 9.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
