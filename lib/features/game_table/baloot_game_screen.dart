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
    PlayingCard(suit: '♥', value: 'J', color: OrientalTheme.accentRuby),
    PlayingCard(suit: '♦', value: 'Q', color: OrientalTheme.accentRuby),
    PlayingCard(suit: '♣', value: '10', color: Colors.white),
    PlayingCard(suit: '♦', value: '9', color: OrientalTheme.accentRuby),
    PlayingCard(suit: '♠', value: '7', color: Colors.white),
  ];

  final List<PlayingCard> _tableCards = [
    PlayingCard(suit: '♥', value: 'A', color: OrientalTheme.accentRuby),
    PlayingCard(suit: '♥', value: '10', color: OrientalTheme.accentRuby),
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
          side: BorderSide(color: OrientalTheme.accentCyan, width: 2.w),
        ),
        title: Column(
          children: [
            Icon(Icons.emoji_events, color: OrientalTheme.primaryGold, size: 48.r),
            SizedBox(height: 6.h),
            Text(
              'انتصار كاسح! 👑',
              style: GoogleFonts.cairo(
                color: OrientalTheme.accentCyan,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ],
        ),
        content: Text(
          'مبروك! لقد ربحت ${widget.betCoins * 2} ذهبية في هذه المباراة الجبارة.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 14.sp),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: OrientalTheme.accentCyan,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                'العودة للرئيسية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13.sp),
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
            // Cyber Grid Background
            Positioned.fill(
              child: CustomPaint(
                painter: ArabianPatternPainter(color: OrientalTheme.accentCyan, opacity: 0.03),
              ),
            ),

            // Modern Cyber Oval Table Surface
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 10.h),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Color(0xFF142238), Color(0xFF0A111E)],
                      radius: 0.95,
                    ),
                    borderRadius: BorderRadius.circular(250.r),
                    border: Border.all(color: OrientalTheme.accentCyan.withValues(alpha: 0.4), width: 3.w),
                    boxShadow: [
                      BoxShadow(
                        color: OrientalTheme.accentCyan.withValues(alpha: 0.15),
                        blurRadius: 20.r,
                        spreadRadius: 2.r,
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Top Bar - Navigation & Scores HUD
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
                        icon: Icon(Icons.arrow_back_ios_new, color: OrientalTheme.accentCyan, size: 18.r),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        widget.roomName,
                        style: GoogleFonts.cairo(color: OrientalTheme.accentCyan, fontSize: 12.sp, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  // Modern Scoreboard HUD
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: OrientalTheme.bgCard.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: OrientalTheme.accentCyan.withValues(alpha: 0.5), width: 1.w),
                      boxShadow: [
                        BoxShadow(color: OrientalTheme.accentCyan.withValues(alpha: 0.15), blurRadius: 8.r)
                      ],
                    ),
                    child: Row(
                      children: [
                        Text('فريقنا: ', style: GoogleFonts.cairo(color: OrientalTheme.accentEmerald, fontWeight: FontWeight.w800, fontSize: 11.sp)),
                        Text('$_ourScore', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.sp)),
                        SizedBox(width: 12.w),
                        Container(width: 1.w, height: 12.h, color: Colors.white24),
                        SizedBox(width: 12.w),
                        Text('الخصم: ', style: GoogleFonts.cairo(color: OrientalTheme.accentRuby, fontWeight: FontWeight.w800, fontSize: 11.sp)),
                        Text('$_theirScore', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.sp)),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: OrientalTheme.primaryGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.4), width: 1.w),
                          ),
                          child: Text(_currentBid, style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),

                  // Emotes Trigger Bar
                  Row(
                    children: [
                      _buildEmoteButton('🔥'),
                      _buildEmoteButton('👑'),
                      _buildEmoteButton('👏'),
                    ],
                  ),
                ],
              ),
            ),

            // PLAYERS PODS AROUND THE TABLE
            // 1. Top Player (Partner)
            Positioned(
              top: 45.h,
              left: 0,
              right: 0,
              child: Center(
                child: _buildPlayerPod(
                  name: 'أبو فهد (الشريك)',
                  avatarUrl: 'https://i.pravatar.cc/150?img=33',
                  isTurn: _currentTurn.contains('الشريك'),
                  cardsCount: 5,
                ),
              ),
            ),

            // 2. Left Player (Opponent 1)
            Positioned(
              left: 45.w,
              top: 100.h,
              child: _buildPlayerPod(
                name: 'خالد (خصم)',
                avatarUrl: 'https://i.pravatar.cc/150?img=12',
                isTurn: _currentTurn.contains('خالد'),
                cardsCount: 6,
              ),
            ),

            // 3. Right Player (Opponent 2)
            Positioned(
              right: 45.w,
              top: 100.h,
              child: _buildPlayerPod(
                name: 'بدر (خصم)',
                avatarUrl: 'https://i.pravatar.cc/150?img=68',
                isTurn: _currentTurn.contains('بدر'),
                cardsCount: 6,
              ),
            ),

            // CENTER TABLE — PLAYED CARDS
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: 220.w,
                  height: 120.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_tableCards.isEmpty)
                        Text(
                          'في انتظار الورقة الأولى...',
                          style: GoogleFonts.cairo(color: Colors.white24, fontSize: 11.sp),
                        ),
                      for (int i = 0; i < _tableCards.length; i++)
                        Positioned(
                          left: 70.w + (i * 25.w),
                          child: Transform.rotate(
                            angle: (i % 2 == 0 ? 0.08 : -0.08),
                            child: _buildCardWidget(_tableCards[i], isSmall: true),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Emote Floating Bubble (If triggered)
            if (_playerEmote != null)
              Positioned(
                bottom: 110.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: OrientalTheme.accentPurple,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(color: OrientalTheme.accentPurple.withValues(alpha: 0.5), blurRadius: 10.r),
                      ],
                    ),
                    child: Text(_playerEmote!, style: TextStyle(fontSize: 22.sp)),
                  ),
                ),
              ),

            // BOTTOM HAND CARDS (USER)
            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Turn Indicator Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: OrientalTheme.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: OrientalTheme.accentCyan.withValues(alpha: 0.4), width: 1.w),
                    ),
                    child: Text(
                      'دور اللعب: $_currentTurn',
                      style: GoogleFonts.cairo(color: OrientalTheme.accentCyan, fontSize: 9.sp, fontWeight: FontWeight.w700),
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Cards Hand List
                  SizedBox(
                    height: 95.h,
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: _myHand.length,
                        itemBuilder: (context, index) {
                          final card = _myHand[index];
                          return GestureDetector(
                            onTap: () => _playCard(index),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              child: _buildCardWidget(card),
                            ),
                          );
                        },
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

  Widget _buildEmoteButton(String emote) {
    return IconButton(
      icon: Text(emote, style: TextStyle(fontSize: 16.sp)),
      onPressed: () => _triggerEmote(emote),
    );
  }

  Widget _buildPlayerPod({
    required String name,
    required String avatarUrl,
    required bool isTurn,
    required int cardsCount,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(2.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isTurn ? OrientalTheme.accentCyan : Colors.white24,
              width: isTurn ? 2.5.w : 1.w,
            ),
            boxShadow: isTurn
                ? [BoxShadow(color: OrientalTheme.accentCyan.withValues(alpha: 0.5), blurRadius: 10.r)]
                : null,
          ),
          child: CircleAvatar(
            radius: 16.r,
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: OrientalTheme.bgCard,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Colors.white12, width: 1.w),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: GoogleFonts.cairo(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
              SizedBox(width: 3.w),
              Icon(Icons.style, color: OrientalTheme.primaryGold, size: 8.r),
              Text(' $cardsCount', style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 8.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardWidget(PlayingCard card, {bool isSmall = false}) {
    final double width = isSmall ? 40.w : 52.w;
    final double height = isSmall ? 60.h : 80.h;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2638),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: OrientalTheme.accentCyan.withValues(alpha: 0.4),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6.r,
            offset: Offset(0, 3.h),
          )
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                card.value,
                style: GoogleFonts.cairo(
                  color: card.color,
                  fontWeight: FontWeight.w900,
                  fontSize: isSmall ? 10.sp : 12.sp,
                  height: 1.0,
                ),
              ),
            ),
            Text(
              card.suit,
              style: TextStyle(
                color: card.color,
                fontSize: isSmall ? 14.sp : 18.sp,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                card.value,
                style: GoogleFonts.cairo(
                  color: card.color,
                  fontWeight: FontWeight.w900,
                  fontSize: isSmall ? 10.sp : 12.sp,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
