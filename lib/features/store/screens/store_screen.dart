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
              Text(
                'المتجر الملكي 🛒',
                style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: Coins Packages (4 grid cards)
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'حزم الذهب 🪙',
                            style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6.h),
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                              childAspectRatio: 1.8,
                              children: [
                                _buildStoreCard('10,000 ذهبية', '1.99\$', '🪙', OrientalTheme.primaryGold),
                                _buildStoreCard('50,000 ذهبية', '4.99\$', '💰', OrientalTheme.accentEmerald),
                                _buildStoreCard('150,000 ذهبية', '9.99\$', '👑', OrientalTheme.accentAmber),
                                _buildStoreCard('500,000 ذهبية', '24.99\$', '🏆', OrientalTheme.accentRuby),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Right Side: Custom Decks & Felts
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أوراق وطاولات فاخرة 🎴',
                            style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6.h),
                          _buildCustomizationTile(
                            title: 'ورق لعب ذهب السلاطين',
                            desc: 'أوراق مطعمة بطلاء الذهبي الملكي',
                            price: '25,000 🪙',
                            icon: Icons.style,
                          ),
                          SizedBox(height: 8.h),
                          _buildCustomizationTile(
                            title: 'طاولة الزمرد الأندلسية',
                            desc: 'مفرش مخملي زمردي وزخارف نادرة',
                            price: '50,000 🪙',
                            icon: Icons.table_bar,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreCard(String title, String price, String emoji, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: OrientalTheme.bgCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: TextStyle(fontSize: 22.sp)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontWeight: FontWeight.bold, fontSize: 11.sp),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
            ),
            onPressed: () => SoundManager().playCoinsCollect(),
            child: Text(
              price,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 10.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationTile({required String title, required String desc, required String price, required IconData icon}) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: OrientalTheme.bgCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Row(
        children: [
          Icon(icon, color: OrientalTheme.primaryGold, size: 28.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontWeight: FontWeight.bold, fontSize: 11.sp)),
                Text(desc, style: GoogleFonts.cairo(color: OrientalTheme.textMuted, fontSize: 9.sp)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OrientalTheme.primaryGold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            ),
            onPressed: () => SoundManager().playButtonClick(),
            child: Text(price, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 9.sp)),
          ),
        ],
      ),
    );
  }
}
