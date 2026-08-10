import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class BackgammonClassicGameScreen extends StatefulWidget {
  const BackgammonClassicGameScreen({super.key});

  @override
  State<BackgammonClassicGameScreen> createState() => _BackgammonClassicGameScreenState();
}

class _BackgammonClassicGameScreenState extends State<BackgammonClassicGameScreen> {
  int _dice1 = 6;
  int _dice2 = 5;

  void _rollDice() {
    SoundManager().playDiceRoll();
    setState(() {
      _dice1 = 1 + (DateTime.now().microsecond % 6);
      _dice2 = 1 + (DateTime.now().millisecond % 6);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1005),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF4E250A), Color(0xFF1E1005)],
                    radius: 0.9,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFFFD700)),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'طاولة عادية (Classic Backgammon)',
                          style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFFFFD700)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDiceBox(_dice1),
                              SizedBox(width: 16.w),
                              _buildDiceBox(_dice2),
                            ],
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE65100),
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                            ),
                            onPressed: _rollDice,
                            icon: const Icon(Icons.casino, color: Colors.white),
                            label: Text('رمي الزار', style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.white)),
                          ),
                        ],
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

  Widget _buildDiceBox(int val) {
    return Container(
      width: 55.w,
      height: 55.w,
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFD700), width: 2.w),
      ),
      child: Center(
        child: Text(
          '$val',
          style: GoogleFonts.montserrat(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
