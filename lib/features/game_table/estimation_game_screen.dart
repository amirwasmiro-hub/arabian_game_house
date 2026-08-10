import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class EstimationGameScreen extends StatefulWidget {
  const EstimationGameScreen({super.key});

  @override
  State<EstimationGameScreen> createState() => _EstimationGameScreenState();
}

class _EstimationGameScreenState extends State<EstimationGameScreen> {
  int _currentBid = 5;
  final int _currentRound = 1;
  int _myScore = 120;
  final int _opponentScore = 95;

  final List<String> _myHandCards = [
    '♠ A', '♠ K', '♥ Q', '♥ 10', '♦ J', '♣ 9', '♣ 8'
  ];

  void _onPlayCard(int index) {
    SoundManager().playButtonClick();
    setState(() {
      _myHandCards.removeAt(index);
      _myScore += 10;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1A12),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF1B4D2E), Color(0xFF0A2414)],
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
                          'لعبة استميشن (Estimation)',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'الجولة $_currentRound | التقدير: $_currentBid',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircleAvatar(child: Icon(Icons.person)),
                                SizedBox(width: 8.w),
                                Text(
                                  'المنافس | النقاط: $_opponentScore',
                                  style: GoogleFonts.cairo(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCardWidget('♠ K', isPlayed: true),
                              SizedBox(width: 12.w),
                              _buildCardWidget('♠ 10', isPlayed: true),
                            ],
                          ),
                          SizedBox(height: 30.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9800),
                                ),
                                onPressed: () {
                                  setState(() => _currentBid++);
                                },
                                child: Text('رفع التقدير', style: GoogleFonts.cairo(color: Colors.white)),
                              ),
                              SizedBox(width: 16.w),
                              Text(
                                'نقاطي: $_myScore',
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 90.h,
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    color: Colors.black.withValues(alpha: 0.3),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _myHandCards.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onPlayCard(index),
                          child: _buildCardWidget(_myHandCards[index]),
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

  Widget _buildCardWidget(String cardText, {bool isPlayed = false}) {
    return Container(
      width: 55.w,
      height: 75.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5.w),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Text(
          cardText,
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: cardText.contains('♥') || cardText.contains('♦')
                ? Colors.red
                : Colors.black,
          ),
        ),
      ),
    );
  }
}
