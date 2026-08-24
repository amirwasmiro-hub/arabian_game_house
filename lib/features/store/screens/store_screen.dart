import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/providers/game_user_provider.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  void _buyCoins(BuildContext context, int coins, String price) {
    final provider = Provider.of<GameUserProvider>(context, listen: false);
    provider.addCoins(coins);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🎉 تم شحن ${_formatNumber(coins)} كوينز بنجاح بقيمة $price!',
          style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD700),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Store Bar with Live Coins Display
                Consumer<GameUserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.user;
                    return Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700), size: 16),
                          onPressed: () => Navigator.pop(context),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.shopping_bag_rounded, color: OrientalTheme.primaryGold, size: 18.r),
                        SizedBox(width: 6.w),
                        Text(
                          'المتجر الملكي 🛒',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        // Gold Coins Balance
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.monetization_on_rounded, color: const Color(0xFFFFD700), size: 13.r),
                              SizedBox(width: 4.w),
                              Text(
                                _formatNumber(user.coins),
                                style: GoogleFonts.montserrat(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6.w),
                        // Diamonds Balance
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.diamond_rounded, color: const Color(0xFF00E5FF), size: 13.r),
                              SizedBox(width: 4.w),
                              Text(
                                '${user.gems}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: 6.h),

                // Local Egyptian / Gulf Wallets Banner
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A0845),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3), width: 0.8.w),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '💳 الدفع المحلي متاح:',
                        style: GoogleFonts.cairo(fontSize: 7.5.sp, fontWeight: FontWeight.bold, color: const Color(0xFFFFD700)),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'فودافون كاش | أورنج كاش | اتصالات كاش | فوري | بطاقات مدى | Apple / Google Pay',
                        style: GoogleFonts.cairo(fontSize: 7.sp, color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 6.h),

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
                                      'حزم الكوينز 🪙 (اضغط للشحن الفوري)',
                                      style: GoogleFonts.cairo(
                                        color: OrientalTheme.primaryGold,
                                        fontSize: isSmallScreen ? 9.5.sp : 10.5.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8.w,
                                      mainAxisSpacing: 8.h,
                                      childAspectRatio: isSmallScreen ? 2.3 : 1.9,
                                      children: [
                                        _buildStoreCard(context, '10,000 ذهبية', '1.99\$', '🪙', OrientalTheme.primaryGold, 10000),
                                        _buildStoreCard(context, '50,000 ذهبية', '4.99\$', '💰', OrientalTheme.accentOrange, 50000),
                                        _buildStoreCard(context, '150,000 ذهبية', '9.99\$', '👑', OrientalTheme.primaryRed, 150000),
                                        _buildStoreCard(context, '500,000 ذهبية', '24.99\$', '🏆', OrientalTheme.accentPurple, 500000),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12.w),

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
                                        fontSize: isSmallScreen ? 9.5.sp : 10.5.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    _buildCustomizationTile(
                                      context: context,
                                      title: 'ورق لعب الملكي الذهبي',
                                      desc: 'أوراق بتصميم كلاسيكي مذهب',
                                      price: '25,000 🪙',
                                      priceNum: 25000,
                                      icon: Icons.style_rounded,
                                      accentColor: OrientalTheme.primaryGold,
                                    ),
                                    SizedBox(height: 6.h),
                                    _buildCustomizationTile(
                                      context: context,
                                      title: 'طاولة المخمل الاندلسية',
                                      desc: 'مفرش مخملي ملكي فاخر',
                                      price: '50,000 🪙',
                                      priceNum: 50000,
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
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    String title,
    String price,
    String emoji,
    Color accentColor,
    int coinsAmount,
  ) {
    return GestureDetector(
      onTap: () => _buyCoins(context, coinsAmount, price),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: OrientalTheme.bgCard,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.5),
            width: 1.w,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.15),
              blurRadius: 6.r,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 20.sp)),
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
                      fontSize: 9.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      price,
                      style: GoogleFonts.cairo(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 8.5.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 3000.ms, color: Colors.white10),
    );
  }

  Widget _buildCustomizationTile({
    required BuildContext context,
    required String title,
    required String desc,
    required String price,
    required int priceNum,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: EdgeInsets.all(8.r),
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
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: accentColor, size: 18.r),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.cairo(
                    color: OrientalTheme.textMuted,
                    fontSize: 7.sp,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: () {
              final provider = Provider.of<GameUserProvider>(context, listen: false);
              final success = provider.deductCoins(priceNum);
              if (success) {
                SoundManager().playWinFanfare();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 مبروك! تم شراء $title بنجاح!', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('رصيد الكوينز غير كافٍ!', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFFB71C1C),
                  ),
                );
              }
            },
            child: Text(
              price,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w900,
                fontSize: 8.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
