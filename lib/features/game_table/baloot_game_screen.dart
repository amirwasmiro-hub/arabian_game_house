import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/oriental_theme.dart';
import '../../core/audio/sound_manager.dart';
import 'widgets/chat_emoji_dialog.dart';

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
    this.roomName = 'تحدي السلاطين',
    this.betCoins = 1000,
  });

  @override
  State<BalootGameScreen> createState() => _BalootGameScreenState();
}

class _BalootGameScreenState extends State<BalootGameScreen> with TickerProviderStateMixin {
  final SoundManager _soundManager = SoundManager();

  int _ourScore = 0;
  int _theirScore = 0;
  final String _trumpSuit = '♣';
  int _roundTimer = 7;

  final List<PlayingCard> _myHand = [
    PlayingCard(suit: '♦', value: '10', color: OrientalTheme.accentRuby),
    PlayingCard(suit: '♥', value: '9', color: OrientalTheme.accentRuby),
    PlayingCard(suit: '♥', value: '10', color: OrientalTheme.accentRuby),
    PlayingCard(suit: '♠', value: 'A', color: Colors.black87),
    PlayingCard(suit: '♣', value: 'K', color: Colors.black87),
  ];

  final List<PlayingCard> _centerPlayedCards = [
    PlayingCard(suit: '♠', value: 'Q', color: Colors.black87),
    PlayingCard(suit: '♥', value: 'K', color: OrientalTheme.accentRuby),
    PlayingCard(suit: '♦', value: 'Q', color: OrientalTheme.accentRuby),
  ];

  String? _userActiveBubble;

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
      _centerPlayedCards.add(card);
      _ourScore += 4;
    });
  }

  void _showChatEmojiModal() {
    _soundManager.playButtonClick();
    showDialog(
      context: context,
      builder: (context) => ChatEmojiDialog(
        onSelectEmoji: (emoji) {
          setState(() {
            _userActiveBubble = emoji;
          });
          _clearBubble();
        },
        onSelectMessage: (msg) {
          setState(() {
            _userActiveBubble = msg;
          });
          _clearBubble();
        },
      ),
    );
  }

  void _clearBubble() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _userActiveBubble = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0C08),
      body: Stack(
        children: [
          // ════ 1. ORIENTAL MAJLIS CARPET & WOODEN ROOM BACKGROUND ════
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Color(0xFF5A1E0E), // Warm lantern glow
                    Color(0xFF2C0A04),
                    Color(0xFF0F0402),
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Majlis Red Carpet Frame
                  Container(
                    width: 700.w,
                    height: 320.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF801010),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: OrientalTheme.primaryGold,
                        width: 4.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 25.r,
                        ),
                      ],
                    ),
                  ),

                  // Center Wooden Table
                  Container(
                    width: 320.w,
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8D5B4C),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFF5D3A2E),
                        width: 4.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 15.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ════ 2. 4 PLAYER SEATS ════
          // Top Seat: Partner (sama haririr)
          Positioned(
            top: 10.h,
            left: 0,
            right: 0,
            child: Center(
              child: _buildPlayerSeat(
                name: 'sama haririr',
                level: '46',
                avatarColor: const Color(0xFF0288D1),
              ),
            ),
          ),

          // Bottom Seat: User (أمير بدوي)
          Positioned(
            bottom: 60.h,
            left: 0,
            right: 0,
            child: Center(
              child: _buildPlayerSeat(
                name: 'أمير بدوي',
                level: '1',
                avatarColor: const Color(0xFF2E7D32),
                bubbleText: _userActiveBubble,
              ),
            ),
          ),

          // Left Seat: Opponent 1 (Lama.88)
          Positioned(
            left: 120.w,
            top: 120.h,
            child: _buildPlayerSeat(
              name: 'Lama.88',
              level: '49',
              avatarColor: const Color(0xFFC2185B),
            ),
          ),

          // Right Seat: Opponent 2 (Lana.22)
          Positioned(
            right: 120.w,
            top: 120.h,
            child: _buildPlayerSeat(
              name: 'Lana.22',
              level: '61',
              avatarColor: const Color(0xFFE65100),
            ),
          ),

          // ════ 3. CENTER PLAYED CARDS ON WOODEN TABLE ════
          Center(
            child: SizedBox(
              width: 280.w,
              height: 120.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _centerPlayedCards.map((card) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: _buildSingleCardWidget(card, isTable: true),
                  );
                }).toList(),
              ),
            ),
          ),

          // ════ 4. PLAYER HAND CARDS AT BOTTOM ════
          Positioned(
            bottom: 4.h,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 70.h,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _myHand.length,
                  itemBuilder: (context, index) {
                    final card = _myHand[index];
                    return GestureDetector(
                      onTap: () => _playCard(index),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: _buildSingleCardWidget(card),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ════ 5. LEFT TRICK PILE STACK ════
          Positioned(
            left: 16.w,
            bottom: 100.h,
            child: Column(
              children: [
                Stack(
                  children: [
                    _buildMiniCard('J', '♥', OrientalTheme.accentRuby),
                    Positioned(left: 6.w, top: 6.h, child: _buildMiniCard('9', '♦', OrientalTheme.accentRuby)),
                    Positioned(left: 12.w, top: 12.h, child: _buildMiniCard('8', '♠', Colors.black)),
                    Positioned(left: 18.w, top: 18.h, child: _buildMiniCard('7', '♣', Colors.black)),
                  ],
                ),
              ],
            ),
          ),

          // ════ 6. RIGHT TOP BAR & SCORE HUD ════
          Positioned(
            top: 10.h,
            right: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Settings Icon
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.settings_rounded, color: OrientalTheme.primaryGold, size: 20.r),
                  ),
                ),
                SizedBox(height: 10.h),

                // Match Status HUD (Trump suit, Timer, Score)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('الطريب', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 8.sp)),
                          SizedBox(width: 4.w),
                          Text(_trumpSuit, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      // Round Timer Circle
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: OrientalTheme.accentOrange, width: 2.w),
                        ),
                        child: Center(
                          child: Text(
                            '$_roundTimer',
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$_ourScore | $_theirScore',
                        style: GoogleFonts.montserrat(
                          color: OrientalTheme.primaryGold,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ════ 7. RIGHT BOTTOM CHAT & EMOJI TOOLBAR ════
          Positioned(
            bottom: 20.h,
            right: 16.w,
            child: Column(
              children: [
                // Text Chat Icon
                _buildActionButton(
                  icon: Icons.subtitles_rounded,
                  onTap: _showChatEmojiModal,
                ),
                SizedBox(height: 8.h),

                // Emoji Icon
                _buildActionButton(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  onTap: _showChatEmojiModal,
                ),
                SizedBox(height: 8.h),

                // Spectate / Video Icon
                _buildActionButton(
                  icon: Icons.videocam_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSeat({
    required String name,
    required String level,
    required Color avatarColor,
    String? bubbleText,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (bubbleText != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            margin: EdgeInsets.only(bottom: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 6.r,
                ),
              ],
            ),
            child: Text(
              bubbleText,
              style: GoogleFonts.cairo(
                color: Colors.black,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor,
                border: Border.all(color: OrientalTheme.primaryGold, width: 2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8.r,
                  ),
                ],
              ),
              child: Icon(Icons.person_rounded, color: Colors.white, size: 26.r),
            ),
            Container(
              padding: EdgeInsets.all(2.r),
              decoration: const BoxDecoration(
                color: OrientalTheme.accentOrange,
                shape: BoxShape.circle,
              ),
              child: Text(
                level,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 7.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            name,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleCardWidget(PlayingCard card, {bool isTable = false}) {
    return Container(
      width: isTable ? 38.w : 44.w,
      height: isTable ? 55.h : 65.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.black12, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.all(2.r),
            child: Row(
              children: [
                Text(
                  card.value,
                  style: GoogleFonts.montserrat(
                    color: card.color,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  card.suit,
                  style: TextStyle(color: card.color, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          Icon(
            _getSuitIcon(card.suit),
            color: card.color,
            size: isTable ? 18.r : 22.r,
          ),
          const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildMiniCard(String val, String suit, Color color) {
    return Container(
      width: 24.w,
      height: 35.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.black26),
      ),
      child: Center(
        child: Text(
          '$val$suit',
          style: TextStyle(color: color, fontSize: 8.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  IconData _getSuitIcon(String suit) {
    switch (suit) {
      case '♠': return Icons.nature_rounded;
      case '♥': return Icons.favorite_rounded;
      case '♦': return Icons.star_rounded;
      case '♣': return Icons.filter_vintage_rounded;
      default: return Icons.style_rounded;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: OrientalTheme.primaryGold, size: 18.r),
      ),
    );
  }
}
