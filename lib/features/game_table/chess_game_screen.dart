import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class ChessGameScreen extends StatefulWidget {
  const ChessGameScreen({super.key});

  @override
  State<ChessGameScreen> createState() => _ChessGameScreenState();
}

class _ChessGameScreenState extends State<ChessGameScreen> {
  int _movesCount = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140D07),
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
                          'لعبة الشطرنج (Chess)',
                          style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFFFFD700)),
                        ),
                        const Spacer(),
                        Text('النقلات: $_movesCount', style: GoogleFonts.cairo(color: Colors.white)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 220.w,
                        height: 200.h,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFFD700), width: 3),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                          ),
                          itemCount: 64,
                          itemBuilder: (context, index) {
                            final row = index ~/ 8;
                            final col = index % 8;
                            final isDark = (row + col) % 2 == 1;
                            return GestureDetector(
                              onTap: () {
                                SoundManager().playButtonClick();
                                setState(() => _movesCount++);
                              },
                              child: Container(
                                color: isDark ? const Color(0xFF3E2723) : const Color(0xFFD7CCC8),
                                child: Center(
                                  child: index == 28
                                      ? Icon(Icons.star, color: Colors.amber, size: 14.r)
                                      : null,
                                ),
                              ),
                            );
                          },
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
}
