import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/game_user_provider.dart';
import '../../../core/audio/sound_manager.dart';

class StakeRoomInfo {
  final String title;
  final int betCoins;
  final int prizeCoins;
  final String minVip;
  final Color primaryColor;
  final Color secondaryColor;
  final String badgeText;

  const StakeRoomInfo({
    required this.title,
    required this.betCoins,
    required this.prizeCoins,
    this.minVip = 'VIP 0',
    required this.primaryColor,
    required this.secondaryColor,
    required this.badgeText,
  });
}

class GameStakesDialog extends StatefulWidget {
  final String gameTitleAr;
  final String gameTitleEn;
  final IconData icon;
  final Widget targetGameScreen;

  const GameStakesDialog({
    super.key,
    required this.gameTitleAr,
    required this.gameTitleEn,
    required this.icon,
    required this.targetGameScreen,
  });

  static void show(
    BuildContext context, {
    required String gameTitleAr,
    required String gameTitleEn,
    required IconData icon,
    required Widget targetGameScreen,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => GameStakesDialog(
        gameTitleAr: gameTitleAr,
        gameTitleEn: gameTitleEn,
        icon: icon,
        targetGameScreen: targetGameScreen,
      ),
    );
  }

  @override
  State<GameStakesDialog> createState() => _GameStakesDialogState();
}

class _GameStakesDialogState extends State<GameStakesDialog> {
  int _selectedModeIndex = 0; // 0: 1v1, 1: 4 Players, 2: Turbo
  final List<String> _modes = ['1 ضد 1 ⚔️', '4 لاعبين 👥', 'لعب سريع ⚡'];

  final List<StakeRoomInfo> _stakes = const [
    StakeRoomInfo(
      title: 'طاولة المبتدئين',
      betCoins: 8000,
      prizeCoins: 16000,
      badgeText: 'سهل',
      primaryColor: Color(0xFF1B5E20),
      secondaryColor: Color(0xFF4CAF50),
    ),
    StakeRoomInfo(
      title: 'طاولة الهواة',
      betCoins: 80000,
      prizeCoins: 160000,
      badgeText: 'شائع 🔥',
      primaryColor: Color(0xFF0D47A1),
      secondaryColor: Color(0xFF29B6F6),
    ),
    StakeRoomInfo(
      title: 'طاولة النخبة',
      betCoins: 800000,
      prizeCoins: 1600000,
      minVip: 'VIP 2',
      badgeText: 'VIP 👑',
      primaryColor: Color(0xFF4A148C),
      secondaryColor: Color(0xFFAB47BC),
    ),
    StakeRoomInfo(
      title: 'طاولة المليونيرات',
      betCoins: 3000000,
      prizeCoins: 6000000,
      minVip: 'VIP 4',
      badgeText: 'أساطير 🏆',
      primaryColor: Color(0xFFB71C1C),
      secondaryColor: Color(0xFFFF5252),
    ),
  ];

  void _joinRoom(StakeRoomInfo stake) {
    final userProvider = Provider.of<GameUserProvider>(context, listen: false);
    if (userProvider.user.coins < stake.betCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'عفواً، رصيد الكوينز غير كافٍ لدخول هذه الطاولة! اشحن من المتجر',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFB71C1C),
        ),
      );
      return;
    }

    userProvider.deductCoins(stake.betCoins);
    SoundManager().playButtonClick();
    Navigator.of(context).pop(); // Close dialog
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => widget.targetGameScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        child: Container(
          width: 580.w,
          constraints: BoxConstraints(maxHeight: 360.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A0845), Color(0xFF150424)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                blurRadius: 25.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Header (Game Name & Modes)
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          blurRadius: 8.r,
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: const Color(0xFF2A0845), size: 16.r),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'غرف ${widget.gameTitleAr}',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                      Text(
                        'اختر طاولة الرهان المناسبة لك',
                        style: GoogleFonts.cairo(
                          fontSize: 7.5.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Mode Segmented Buttons
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white24, width: 0.8.w),
                    ),
                    child: Row(
                      children: List.generate(_modes.length, (idx) {
                        final isSelected = _selectedModeIndex == idx;
                        return GestureDetector(
                          onTap: () {
                            SoundManager().playButtonClick();
                            setState(() => _selectedModeIndex = idx);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              _modes[idx],
                              style: GoogleFonts.cairo(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? const Color(0xFF2A0845) : Colors.white70,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Close Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded, color: Colors.white, size: 14.r),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // 2. Stakes Grid (4 Rooms)
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 0.92,
                  ),
                  itemCount: _stakes.length,
                  itemBuilder: (context, index) {
                    final stake = _stakes[index];
                    return _buildStakeCard(stake);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStakeCard(StakeRoomInfo stake) {
    return GestureDetector(
      onTap: () => _joinRoom(stake),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [stake.primaryColor, stake.secondaryColor.withValues(alpha: 0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.8),
            width: 1.2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: stake.primaryColor.withValues(alpha: 0.5),
              blurRadius: 8.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Badge (Top Right)
            Positioned(
              top: 5.h,
              right: 6.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFFFD700), width: 0.6.w),
                ),
                child: Text(
                  stake.badgeText,
                  style: GoogleFonts.cairo(
                    fontSize: 6.5.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    stake.title,
                    style: GoogleFonts.cairo(
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Bet Amount
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on_rounded, color: const Color(0xFFFFD700), size: 11.r),
                        SizedBox(width: 3.w),
                        Text(
                          _formatNumber(stake.betCoins),
                          style: GoogleFonts.montserrat(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Prize Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'الجائزة: ',
                        style: GoogleFonts.cairo(fontSize: 6.5.sp, color: Colors.white70),
                      ),
                      Text(
                        _formatNumber(stake.prizeCoins),
                        style: GoogleFonts.montserrat(
                          fontSize: 7.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00E676),
                        ),
                      ),
                    ],
                  ),
                  // Play Button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 3.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF9100)],
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        'دخول الطاولة 🎲',
                        style: GoogleFonts.cairo(
                          fontSize: 7.5.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF3E2723),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
}
