import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/audio/sound_manager.dart';

class LudoGameScreen extends StatefulWidget {
  const LudoGameScreen({super.key});

  @override
  State<LudoGameScreen> createState() => _LudoGameScreenState();
}

class _LudoGameScreenState extends State<LudoGameScreen> {
  int _diceResult = 6;
  final List<Color> _playerColors = [
    Colors.red,
    Colors.green,
    Colors.yellow.shade700,
    Colors.blue,
  ];

  void _rollLudoDice() {
    SoundManager().playDiceRoll();
    setState(() {
      _diceResult = (1 + (DateTime.now().millisecond % 6));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1B2B),
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
                          'لعبة لودو (Ludo)',
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
                          Container(
                            width: 200.w,
                            height: 180.h,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: const Color(0xFFFFD700), width: 2),
                            ),
                            child: GridView.count(
                              crossAxisCount: 2,
                              children: List.generate(
                                4,
                                (i) => Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _playerColors[i].withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.stars, color: Colors.white, size: 24.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                            ),
                            onPressed: _rollLudoDice,
                            icon: const Icon(Icons.casino, color: Colors.white),
                            label: Text('رمي نرد لودو: $_diceResult', style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.white)),
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
}
