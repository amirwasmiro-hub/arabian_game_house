import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class DominoClassicGameScreen extends StatefulWidget {
  const DominoClassicGameScreen({super.key});

  @override
  State<DominoClassicGameScreen> createState() => _DominoClassicGameScreenState();
}

class _DominoClassicGameScreenState extends State<DominoClassicGameScreen> {
  final List<String> _hand = ['4|4', '4|1', '1|5', '0|0', '2|6'];
  int _score = 80;

  void _playTile(int index) {
    SoundManager().playButtonClick();
    setState(() {
      _hand.removeAt(index);
      _score += 15;
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
                    colors: [Color(0xFF4A2508), Color(0xFF1E1005)],
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
                          'دومينو عادية (Classic Dominoes)',
                          style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFFFFD700)),
                        ),
                        const Spacer(),
                        Text('النقاط: $_score', style: GoogleFonts.cairo(color: Colors.amber)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildWhiteTile('4|4'),
                          SizedBox(width: 6.w),
                          _buildWhiteTile('4|1'),
                          SizedBox(width: 6.w),
                          _buildWhiteTile('1|5'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    color: Colors.black.withValues(alpha: 0.3),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _hand.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _playTile(index),
                          child: _buildWhiteTile(_hand[index]),
                        );
                      },
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

  Widget _buildWhiteTile(String text) {
    final parts = text.split('|');
    return Container(
      width: 44.w,
      height: 70.h,
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.black, width: 1.5.w),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(parts[0], style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
          Divider(color: Colors.black, height: 1.h),
          Text(parts[1], style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
