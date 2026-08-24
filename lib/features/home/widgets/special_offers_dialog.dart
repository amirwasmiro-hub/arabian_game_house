import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/game_user_provider.dart';
import '../../../core/audio/sound_manager.dart';

class SpecialOffersDialog extends StatelessWidget {
  const SpecialOffersDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const SpecialOffersDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Container(
          width: 520.w,
          constraints: BoxConstraints(maxHeight: 380.h),
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.2,
              colors: [Color(0xFF5A1028), Color(0xFF2A0413), Color(0xFF140209)],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                blurRadius: 30.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Top Ribbon: "+200% EXTRA BONUS"
              Positioned(
                top: -12.h,
                right: 20.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1744), Color(0xFFFF5252)],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.2.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.6),
                        blurRadius: 10.r,
                      ),
                    ],
                  ),
                  child: Text(
                    '🔥 بونص مضاعف +200% لفترة محدودة',
                    style: GoogleFonts.cairo(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(duration: 800.ms, begin: const Offset(0.97, 0.97), end: const Offset(1.03, 1.03)),
              ),

              // Close Button (Top Left)
              Positioned(
                top: 8.h,
                left: 8.w,
                child: GestureDetector(
                  onTap: () {
                    SoundManager().playButtonClick();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, color: Colors.white, size: 16.r),
                  ),
                ),
              ),

              // Main Content
              Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10.h),
                    // Title & Subtitle
                    Text(
                      '👑 باقة الأسطورة الذهبية',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFFFD700),
                        shadows: [
                          Shadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'احصل على ملايين الكوينز وإيموجيات تفاعلية مع حزمة VIP الحصرية',
                      style: GoogleFonts.cairo(
                        fontSize: 7.5.sp,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Rewards Showcase Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildRewardBadge(
                          icon: Icons.monetization_on_rounded,
                          color: const Color(0xFFFFD700),
                          title: '5,000,000',
                          subtitle: 'كوينز ذهبية 🪙',
                        ),
                        _buildRewardBadge(
                          icon: Icons.diamond_rounded,
                          color: const Color(0xFF00E5FF),
                          title: '1,500',
                          subtitle: 'جواهر ملكية 💎',
                        ),
                        _buildRewardBadge(
                          icon: Icons.military_tech_rounded,
                          color: const Color(0xFFFF9100),
                          title: 'VIP 5',
                          subtitle: 'إطار وشارة VIP 👑',
                        ),
                        _buildRewardBadge(
                          icon: Icons.sentiment_very_satisfied_rounded,
                          color: const Color(0xFFE040FB),
                          title: 'طماطم وشباشب',
                          subtitle: 'إيموجيات رمي غير محدودة 🍅',
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Local Payment Wallets Badges (Vodafone Cash, Orange, Etisalat, Google Play)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white12, width: 0.8.w),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'طرق الدفع والشحن المباشر: ',
                            style: GoogleFonts.cairo(fontSize: 7.sp, color: Colors.white60),
                          ),
                          _buildWalletBadge('فودافون كاش', const Color(0xFFE60000)),
                          SizedBox(width: 4.w),
                          _buildWalletBadge('أورنج كاش', const Color(0xFFFF7900)),
                          SizedBox(width: 4.w),
                          _buildWalletBadge('اتصالات كاش', const Color(0xFF78BE20)),
                          SizedBox(width: 4.w),
                          _buildWalletBadge('Google Play', const Color(0xFF4285F4)),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Price & Buy Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Strikethrough Old Price
                        Text(
                          '29.99\$',
                          style: GoogleFonts.montserrat(
                            fontSize: 10.sp,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.white38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Buy Button
                        GestureDetector(
                          onTap: () {
                            final provider = Provider.of<GameUserProvider>(context, listen: false);
                            provider.addCoins(5000000);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '🎉 مبروك! تم إضافة 5,000,000 كوينز وترقية حسابك إلى VIP بنجاح!',
                                  style: GoogleFonts.cairo(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xFFFFD700),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                                  blurRadius: 15.r,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'اشحن الآن بـ 4.99\$ فقط ⚡',
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF3E2723),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(duration: 900.ms, begin: const Offset(0.98, 0.98), end: const Offset(1.02, 1.02)),
                        ),
                      ],
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

  Widget _buildRewardBadge({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 95.w,
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.w),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18.r),
          SizedBox(height: 3.h),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 6.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color, width: 0.6.w),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 6.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
