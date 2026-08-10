import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class TarneebGameScreen extends StatefulWidget {
  const TarneebGameScreen({super.key});

  @override
  State<TarneebGameScreen> createState() => _TarneebGameScreenState();
}

class _TarneebGameScreenState extends State<TarneebGameScreen> {
  final String _trumpSuit = '♠ الكبة';
  int _team1Score = 31;
  final int _team2Score = 24;

  final List<String> _cards = ['♠ 10', '♠ J', '♠ Q', '♥ K', '♦ A', '♣ 9'];

  void _onPlayCard(int index) {
    SoundManager().playButtonClick();
    setState(() {
      _cards.removeAt(index);
      _team1Score += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF190A0A),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF5D1010), Color(0xFF190A0A)],
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
                          'لعبة تارنيب (Tarneeb)',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'حكم التارنيب: $_trumpSuit',
                          style: GoogleFonts.cairo(color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildScoreCard('فريقنا', _team1Score),
                            _buildScoreCard('الفريق المنافس', _team2Score),
                          ],
                        ),
                        SizedBox(height: 30.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildCardItem('♠ A'),
                            SizedBox(width: 10.w),
                            _buildCardItem('♥ Q'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 90.h,
                    color: Colors.black.withValues(alpha: 0.3),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onPlayCard(index),
                          child: _buildCardItem(_cards[index]),
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

  Widget _buildScoreCard(String title, int score) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFFD700)),
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.cairo(color: Colors.white)),
          Text('$score', style: GoogleFonts.cairo(fontSize: 18.sp, color: const Color(0xFFFFD700))),
        ],
      ),
    );
  }

  Widget _buildCardItem(String text) {
    return Container(
      width: 52.w,
      height: 72.h,
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.amber),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: text.contains('♥') || text.contains('♦') ? Colors.red : Colors.black,
          ),
        ),
      ),
    );
  }
}
