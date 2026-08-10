import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class DominoAmericanGameScreen extends StatefulWidget {
  const DominoAmericanGameScreen({super.key});

  @override
  State<DominoAmericanGameScreen> createState() => _DominoAmericanGameScreenState();
}

class _DominoAmericanGameScreenState extends State<DominoAmericanGameScreen> {
  final int _boneyardCount = 14;
  int _playerPoints = 150;
  final List<String> _myDominoes = ['6|6', '5|5', '6|3', '4|2', '1|1'];

  void _onPlayDomino(int index) {
    SoundManager().playButtonClick();
    setState(() {
      _myDominoes.removeAt(index);
      _playerPoints += 12;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071228),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF071228)],
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
                          'دومينو أمريكاني (American Dominoes)',
                          style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFFFFD700)),
                        ),
                        const Spacer(),
                        Text('السحب المتبقي: $_boneyardCount', style: GoogleFonts.cairo(color: Colors.white)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('مجموع نقاطي: $_playerPoints', style: GoogleFonts.cairo(fontSize: 16.sp, color: Colors.amber)),
                          SizedBox(height: 20.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDominoTile('6|6'),
                              SizedBox(width: 8.w),
                              _buildDominoTile('6|3'),
                              SizedBox(width: 8.w),
                              _buildDominoTile('3|5'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 85.h,
                    color: Colors.black.withValues(alpha: 0.3),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _myDominoes.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onPlayDomino(index),
                          child: _buildDominoTile(_myDominoes[index]),
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

  Widget _buildDominoTile(String text) {
    final parts = text.split('|');
    return Container(
      width: 45.w,
      height: 70.h,
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFFFD700), width: 1.5.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(parts[0], style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
          Divider(color: const Color(0xFFFFD700), height: 1.h),
          Text(parts[1], style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
