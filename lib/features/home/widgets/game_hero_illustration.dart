import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';

class GameTileIllustration extends StatelessWidget {
  final String gameId;
  final Color primaryColor;

  const GameTileIllustration({
    super.key,
    required this.gameId,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    switch (gameId) {
      case 'poker':
        return _buildPokerIllustration();
      case 'chess':
        return _buildChessIllustration();
      case 'backgammon':
        return _buildBackgammonIllustration();
      case 'jackaroo':
        return _buildJackarooIllustration();
      case 'domino':
        return _buildDominoIllustration();
      case 'snakes':
        return _buildSnakesIllustration();
      case 'parchisi':
        return _buildParchisiIllustration();
      case 'ludo':
        return _buildLudoIllustration();
      case 'ball8':
        return _build8BallIllustration();
      case 'tarneeb':
      default:
        return _buildCardsIllustration();
    }
  }

  // 1. Poker (A Spades & A Hearts cards with gold chips)
  Widget _buildPokerIllustration() {
    return SizedBox(
      width: 70.w,
      height: 50.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(-8.w, -2.h),
            child: Transform.rotate(
              angle: -0.15,
              child: _buildMiniCard('A', '♠', Colors.black),
            ),
          ),
          Transform.translate(
            offset: Offset(8.w, 2.h),
            child: Transform.rotate(
              angle: 0.15,
              child: _buildMiniCard('A', '♥', const Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String rank, String suit, Color color) {
    return Container(
      width: 28.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: OrientalTheme.primaryGold, width: 1.w),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(rank, style: GoogleFonts.cinzel(color: color, fontSize: 8.sp, fontWeight: FontWeight.bold)),
            Text(suit, style: TextStyle(color: color, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }

  // 2. Chess (White Horse / Knight)
  Widget _buildChessIllustration() {
    return Container(
      padding: EdgeInsets.all(4.r),
      child: Icon(Icons.shield_rounded, color: Colors.white, size: 36.r),
    );
  }

  // 3. Backgammon (Board + Dice)
  Widget _buildBackgammonIllustration() {
    return SizedBox(
      width: 60.w,
      height: 45.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.casino, color: OrientalTheme.primaryGold, size: 32.r),
          Positioned(
            right: 4.w,
            bottom: 2.h,
            child: Icon(Icons.circle, color: const Color(0xFFFF9100), size: 16.r),
          ),
        ],
      ),
    );
  }

  // 4. Jackaroo (K Q J cards + board)
  Widget _buildJackarooIllustration() {
    return SizedBox(
      width: 65.w,
      height: 45.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(angle: -0.2, child: _buildMiniCard('K', '♦', const Color(0xFFD32F2F))),
          Transform.rotate(angle: 0.0, child: _buildMiniCard('Q', '♠', Colors.black)),
          Transform.rotate(angle: 0.2, child: _buildMiniCard('J', '♣', Colors.black)),
        ],
      ),
    );
  }

  // 5. Domino (Domino tiles + chips)
  Widget _buildDominoIllustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDominoMiniTile(6, 6),
        SizedBox(width: 4.w),
        _buildDominoMiniTile(5, 3),
      ],
    );
  }

  Widget _buildDominoMiniTile(int top, int bottom) {
    return Container(
      width: 20.w,
      height: 38.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFA),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: OrientalTheme.primaryGold, width: 1.w),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('$top', style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: Colors.black)),
          Container(height: 1.h, color: Colors.black45),
          Text('$bottom', style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  // 6. Snakes & Ladders (Snake + Dice)
  Widget _buildSnakesIllustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('🐍', style: TextStyle(fontSize: 22.sp)),
        Icon(Icons.trending_up_rounded, color: const Color(0xFF4CAF50), size: 24.r),
      ],
    );
  }

  // 7. Parchisi (Dice + Token)
  Widget _buildParchisiIllustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.casino, color: Colors.white, size: 28.r),
        SizedBox(width: 4.w),
        Icon(Icons.stars_rounded, color: const Color(0xFFFF3D00), size: 22.r),
      ],
    );
  }

  // 8. Ludo (Color Tokens + Die)
  Widget _buildLudoIllustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sports_esports, color: const Color(0xFFE91E63), size: 28.r),
        Icon(Icons.casino, color: Colors.white, size: 22.r),
      ],
    );
  }

  // 9. 8Ball (Billiard Cue & 8 Ball)
  Widget _build8BallIllustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('🎱', style: TextStyle(fontSize: 26.sp)),
        SizedBox(width: 4.w),
        Text('🔴', style: TextStyle(fontSize: 16.sp)),
      ],
    );
  }

  // 10. Tarneeb
  Widget _buildCardsIllustration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMiniCard('A', '♠', Colors.black),
        SizedBox(width: 4.w),
        _buildMiniCard('K', '♥', const Color(0xFFD32F2F)),
      ],
    );
  }
}
