import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class UnoGameScreen extends StatefulWidget {
  const UnoGameScreen({super.key});

  @override
  State<UnoGameScreen> createState() => _UnoGameScreenState();
}

class _UnoGameScreenState extends State<UnoGameScreen> {
  final List<Map<String, dynamic>> _unoCards = [
    {'text': '7', 'color': Colors.red},
    {'text': 'SKIP', 'color': Colors.blue},
    {'text': '+2', 'color': Colors.green},
    {'text': 'REVERSE', 'color': Colors.amber},
    {'text': '+4 WILD', 'color': Colors.purple},
  ];

  void _onPlayUnoCard(int index) {
    SoundManager().playButtonClick();
    setState(() {
      _unoCards.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F092E),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
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
                          'لعبة أونو (Uno)',
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
                          Text('سحب كروت أونو', style: GoogleFonts.cairo(color: Colors.white)),
                          SizedBox(height: 12.h),
                          _buildUnoCardWidget('9', Colors.red),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 90.h,
                    color: Colors.black.withValues(alpha: 0.3),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _unoCards.length,
                      itemBuilder: (context, index) {
                        final c = _unoCards[index];
                        return GestureDetector(
                          onTap: () => _onPlayUnoCard(index),
                          child: _buildUnoCardWidget(c['text'], c['color']),
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

  Widget _buildUnoCardWidget(String text, Color cardColor) {
    return Container(
      width: 50.w,
      height: 75.h,
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white, width: 2.w),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
