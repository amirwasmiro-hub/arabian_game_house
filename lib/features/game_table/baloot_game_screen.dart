import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/oriental_theme.dart';
import '../../core/audio/sound_manager.dart';

class PlayingCard {
  final String suit; // ♠, ♥, ♦, ♣
  final String value; // A, K, Q, J, 10, 9, 8, 7
  final Color color;
  bool isSelected;

  PlayingCard({
    required this.suit,
    required this.value,
    required this.color,
    this.isSelected = false,
  });
}

class BalootGameScreen extends StatefulWidget {
  final String roomName;
  final int betCoins;

  const BalootGameScreen({
    super.key,
    this.roomName = 'مجلس السلاطين 👑',
    this.betCoins = 5000,
  });

  @override
  State<BalootGameScreen> createState() => _BalootGameScreenState();
}

class _BalootGameScreenState extends State<BalootGameScreen> with TickerProviderStateMixin {
  final SoundManager _soundManager = SoundManager();

  int _ourScore = 48;
  final int _theirScore = 32;
  final String _currentBid = 'صن ♠';
  String _currentTurn = 'أنت (السلطان)';

  final List<PlayingCard> _myHand = [
    PlayingCard(suit: '♠', value: 'A', color: Colors.white),
    PlayingCard(suit: '♠', value: 'K', color: Colors.white),
    PlayingCard(suit: '♥', value: 'J', color: Colors.redAccent),
    PlayingCard(suit: '♦', value: 'Q', color: Colors.redAccent),
    PlayingCard(suit: '♣', value: '10', color: Colors.white),
    PlayingCard(suit: '♦', value: '9', color: Colors.redAccent),
    PlayingCard(suit: '♠', value: '7', color: Colors.white),
  ];

  final List<PlayingCard> _tableCards = [
    PlayingCard(suit: '♥', value: 'A', color: Colors.redAccent),
    PlayingCard(suit: '♥', value: '10', color: Colors.redAccent),
  ];

  String? _playerEmote;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _playCard(int index) {
    _soundManager.playCardFlip();
    setState(() {
      final card = _myHand.removeAt(index);
      _tableCards.add(card);
      _ourScore += 12;
      _currentTurn = 'أبو فهد (الشريك)';
    });

    if (_ourScore >= 152) {
      _showWinDialog();
    }
  }

  void _triggerEmote(String emote) {
    _soundManager.playButtonClick();
    setState(() {
      _playerEmote = emote;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _playerEmote = null);
    });
  }

  void _showWinDialog() {
    _soundManager.playWinFanfare();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: OrientalTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
          side: BorderSide(color: OrientalTheme.primaryGold, width: 2.w),
        ),
        title: Column(
          children: [
            Icon(Icons.emoji_events, color: OrientalTheme.primaryGold, size: 48.r),
            SizedBox(height: 6.h),
            Text(
              'فوز كاسح! 👑',
              style: GoogleFonts.cairo(
                color: OrientalTheme.primaryGold,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ],
        ),
        content: Text(
          'مبروك! لقد ربحت ${widget.betCoins * 2} ذهبية في هذه الجولة المباركة.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 14.sp),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: OrientalTheme.primaryGold,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'العودة للمجلس',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Felt Pattern
            Positioned.fill(
              child: CustomPaint(
                painter: ArabianPatternPainter(opacity: 0.04),
              ),
            ),

            // Oval Felt Table Surface (Landscape Horizontal Layout)
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 10.h),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Color(0xFF0F4733), Color(0xFF07241A)],
                      radius: 0.9,
                    ),
                    borderRadius: BorderRadius.circular(250.r),
                    border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.4), width: 3.5.w),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.6),
                        blurRadius: 18.r,
                        spreadRadius: 4.r,
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Top Bar - Back Button & Scoreboard & Room Name
            Positioned(
              top: 6.h,
              left: 12.w,
              right: 12.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: OrientalTheme.primaryGold, size: 18.r),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        widget.roomName,
                        style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 12.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Score Panel
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: OrientalTheme.bgDark.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: OrientalTheme.primaryGold, width: 1.w),
                    ),
                    child: Row(
                      children: [
                        Text('لنا: ', style: GoogleFonts.cairo(color: OrientalTheme.accentEmerald, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        Text('$_ourScore', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                        SizedBox(width: 10.w),
                        Text('|', style: TextStyle(color: OrientalTheme.primaryGold.withValues(alpha: 0.5))),
                        SizedBox(width: 10.w),
                        Text('لهم: ', style: GoogleFonts.cairo(color: OrientalTheme.accentRuby, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                        Text('$_theirScore', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      ],
                    ),
                  ),
                  // Current Bid Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: OrientalTheme.primaryGold,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      _currentBid,
                      style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11.sp),
                    ),
                  ),
                ],
              ),
            ),

            // Top Player (الشريك)
            Positioned(
              top: 8.h,
              left: 0,
              right: 0,
              child: Center(
                child: _buildPlayerAvatar(
                  name: 'أبو فهد (الشريك)',
                  avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                  cardsCount: 5,
                  isTurn: _currentTurn.contains('أبو فهد'),
                ),
              ),
            ),

            // Left Player (الخصم 1)
            Positioned(
              left: 45.w,
              top: 0.28.sh,
              child: _buildPlayerAvatar(
                name: 'سالم (الخصم)',
                avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
                cardsCount: 6,
                isTurn: _currentTurn.contains('سالم'),
              ),
            ),

            // Right Player (الخصم 2)
            Positioned(
              right: 45.w,
              top: 0.28.sh,
              child: _buildPlayerAvatar(
                name: 'طارق (الخصم)',
                avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
                cardsCount: 6,
                isTurn: _currentTurn.contains('طارق'),
              ),
            ),

            // Center Table Cards Stack
            Center(
              child: Container(
                width: 140.w,
                height: 110.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.15),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_tableCards.isEmpty)
                      Text(
                        'اقذف ورقتك هنا',
                        style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12.sp),
                      ),
                    ..._tableCards.asMap().entries.map((entry) {
                      int idx = entry.key;
                      PlayingCard card = entry.value;
                      double offset = (idx - (_tableCards.length - 1) / 2) * 16.w;
                      return Transform.translate(
                        offset: Offset(offset, idx * 3.h),
                        child: Transform.rotate(
                          angle: (idx % 2 == 0 ? 0.1 : -0.1),
                          child: _buildCardWidget(card, width: 48.w, height: 70.h),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Vertical Emote Action Bar (Left Side)
            Positioned(
              left: 8.w,
              bottom: 16.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: ['👑', '☕', '👏', '😂', '🔥'].map((emote) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: InkWell(
                      onTap: () => _triggerEmote(emote),
                      child: Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: OrientalTheme.bgCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.5), width: 1.w),
                        ),
                        child: Text(emote, style: TextStyle(fontSize: 14.sp)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Emote bubble preview if triggered
            if (_playerEmote != null)
              Positioned(
                bottom: 100.h,
                right: 70.w,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: OrientalTheme.primaryGold, width: 1.w),
                  ),
                  child: Text(_playerEmote!, style: TextStyle(fontSize: 24.sp)),
                ),
              ),

            // Bottom Player (أنت - السلطان) & Hand Cards
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cards Hand Carousel
                  SizedBox(
                    height: 90.h,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: _myHand.asMap().entries.map((entry) {
                        int index = entry.key;
                        PlayingCard card = entry.value;
                        double totalCards = _myHand.length.toDouble();
                        double centerOffset = index - (totalCards - 1) / 2;
                        double angle = centerOffset * 0.07;
                        double translateX = centerOffset * 32.w;
                        double translateY = (centerOffset.abs()) * 3.h;

                        return Transform.translate(
                          offset: Offset(translateX, translateY),
                          child: Transform.rotate(
                            angle: angle,
                            child: GestureDetector(
                              onTap: () => _playCard(index),
                              child: _buildCardWidget(card, width: 52.w, height: 80.h),
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildPlayerAvatar({
    required String name,
    required String avatar,
    required int cardsCount,
    required bool isTurn,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(2.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isTurn ? OrientalTheme.accentEmerald : OrientalTheme.primaryGold,
              width: isTurn ? 2.w : 1.w,
            ),
            boxShadow: isTurn
                ? [BoxShadow(color: OrientalTheme.accentEmerald.withValues(alpha: 0.6), blurRadius: 6.r)]
                : null,
          ),
          child: CircleAvatar(
            radius: 16.r,
            backgroundImage: NetworkImage(avatar),
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: OrientalTheme.bgDark.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            name,
            style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 9.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildCardWidget(PlayingCard card, {required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Colors.black12, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(2.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                '${card.value}\n${card.suit}',
                style: TextStyle(
                  color: card.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.sp,
                  height: 0.9,
                ),
              ),
            ),
            Text(
              card.suit,
              style: TextStyle(color: card.color, fontSize: 16.sp),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '${card.value}\n${card.suit}',
                style: TextStyle(
                  color: card.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 9.sp,
                  height: 0.9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
