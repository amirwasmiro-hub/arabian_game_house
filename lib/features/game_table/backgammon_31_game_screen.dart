import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class Backgammon31GameScreen extends StatefulWidget {
  const Backgammon31GameScreen({super.key});

  @override
  State<Backgammon31GameScreen> createState() => _Backgammon31GameScreenState();
}

class _Backgammon31GameScreenState extends State<Backgammon31GameScreen> {
  int _dice1 = 3;
  int _dice2 = 1;
  int _score31 = 18;

  void _rollDice() {
    SoundManager().playDiceRoll();
    setState(() {
      _dice1 = 1 + (DateTime.now().microsecond % 6);
      _dice2 = 1 + (DateTime.now().millisecond % 6);
      _score31 = (_score31 + 2) % 31;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF240E0E),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF5E1B1B), Color(0xFF240E0E)],
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
                          'طاولة 31 (Backgammon 31)',
                          style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFFFFD700)),
                        ),
                        const Spacer(),
                        Text('مجموع النرد: $_score31 / 31', style: GoogleFonts.cairo(color: Colors.amber)),
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
                              backgroundColor: const Color(0xFFFF9800),
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                            ),
                            onPressed: _rollDice,
                            icon: const Icon(Icons.casino, color: Colors.white),
                            label: Text('رمي الرمية 31', style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.white)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFD700), width: 2.w),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
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
