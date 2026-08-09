import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/game_model.dart';
import '../widgets/lounge_background_painter.dart';
import '../widgets/game_hero_illustration.dart';
import '../../game_table/baloot_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await SupabaseService().fetchUserProfile();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return Scaffold(
        backgroundColor: OrientalTheme.bgDark,
        body: Center(
          child: CircularProgressIndicator(
            color: OrientalTheme.primaryGold,
            strokeWidth: 2.5.w,
          ),
        ),
      );
    }

    final games = GameModel.gamesList.take(10).toList();
    final row1Games = games.sublist(0, 5);
    final row2Games = games.sublist(5, 10);

    return Scaffold(
      body: Stack(
        children: [
          // ════ 1. ROYAL LOUNGE DECK BACKGROUND ════
          const Positioned.fill(
            child: CustomPaint(
              painter: LoungeBackgroundPainter(),
            ),
          ),

          // ════ 2. MAIN UI LAYOUT ════
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Column(
                children: [
                  // ── Top Header Currency & Profile Bar ──
                  _buildTopHeaderBar(),

                  // ── Center 2x5 Grid of Gold Game Tiles (Flexible Expanded) ──
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildGameGridRow(row1Games),
                        SizedBox(height: 6.h),
                        _buildGameGridRow(row2Games),
                      ],
                    ),
                  ),

                  // ── Bottom Action & Play Now CTA Bar ──
                  _buildBottomControlBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // 1. TOP HEADER CURRENCY & PROFILE BAR
  // ─────────────────────────────────────────────────────
  Widget _buildTopHeaderBar() {
    return Row(
      children: [
        // UTC Time Tag (Top Left)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'UTC+0 20:32',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const Spacer(),

        // Gift Box / Offers Button ( عروض )
        _buildGiftOffersButton(),

        SizedBox(width: 8.w),

        // Coins Exchange Pill ( 650 🟡 استبدال )
        _buildCoinsPill('650', 'استبدال'),

        SizedBox(width: 8.w),

        // Tickets Pill ( 500K 🟢 + )
        _buildTicketsPill('500K'),

        SizedBox(width: 10.w),

        // Pharaoh / Royal Profile Avatar (Top Right)
        _buildRoyalAvatarFrame(),
      ],
    );
  }

  Widget _buildGiftOffersButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: OrientalTheme.primaryGold, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.card_giftcard_rounded, color: OrientalTheme.primaryGold, size: 14.r),
          SizedBox(width: 4.w),
          Text(
            'عروض',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 8.5.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsPill(String amount, String btnLabel) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: OrientalTheme.primaryGold, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Exchange Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              btnLabel,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Text(
            amount,
            style: GoogleFonts.cairo(
              color: OrientalTheme.primaryGold,
              fontSize: 9.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 4.w),
          Text('🪙', style: TextStyle(fontSize: 10.sp)),
        ],
      ),
    );
  }

  Widget _buildTicketsPill(String amount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: OrientalTheme.primaryGold, width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Plus Button
          Container(
            padding: EdgeInsets.all(2.r),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_rounded, color: Colors.white, size: 10.r),
          ),
          SizedBox(width: 6.w),
          Text(
            amount,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 9.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(width: 4.w),
          Text('💵', style: TextStyle(fontSize: 10.sp)),
        ],
      ),
    );
  }

  Widget _buildRoyalAvatarFrame() {
    return Container(
      padding: EdgeInsets.all(2.r),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: OrientalTheme.goldCardGradient,
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 6)],
      ),
      child: CircleAvatar(
        radius: 18.r,
        backgroundImage: NetworkImage(_user!.avatarUrl),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // 2. CENTER 2X5 GRID OF GOLD GAME TILES
  // ─────────────────────────────────────────────────────
  Widget _buildGameGridRow(List<GameModel> rowGames) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(rowGames.length, (index) {
        return _buildGoldGameTile(rowGames[index]);
      }),
    );
  }

  Widget _buildGoldGameTile(GameModel game) {
    return GestureDetector(
      onTap: () {
        SoundManager().playCardDeal();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BalootGameScreen(
              roomName: 'تحدي ${game.titleAr} 👑',
              betCoins: 5000,
            ),
          ),
        );
      },
      child: SizedBox(
        width: 140.w,
        child: Column(
          children: [
            // Gold Framed Card Container
            Container(
              height: 108.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: game.cardGradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: OrientalTheme.primaryGold,
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Stack(
                  children: [
                    // Background texture
                    const Positioned.fill(
                      child: CustomPaint(
                        painter: CasinoPatternPainter(
                          color: OrientalTheme.primaryGold,
                          opacity: 0.03,
                        ),
                      ),
                    ),

                    // 3D Game Graphic Illustration (Center)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 18.h),
                        child: GameTileIllustration(
                          gameId: game.id,
                          primaryColor: game.primaryColor,
                        ),
                      ),
                    ),

                    // English Title Ribbon (Bottom Center of Card)
                    Positioned(
                      bottom: 4.h,
                      left: 4.w,
                      right: 4.w,
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              OrientalTheme.goldLight,
                              OrientalTheme.primaryGold,
                              OrientalTheme.goldDark,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            game.titleEn,
                            style: GoogleFonts.cinzel(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),

                    // Play / Download Circular Badge (Bottom Right)
                    Positioned(
                      bottom: 3.r,
                      right: 3.r,
                      child: Container(
                        padding: EdgeInsets.all(3.r),
                        decoration: const BoxDecoration(
                          color: OrientalTheme.primaryGold,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4)],
                        ),
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          color: Colors.black,
                          size: 9.r,
                        ),
                      ),
                    ),

                    // 'New' Green Ribbon Tag (Top Left)
                    if (game.isNew)
                      Positioned(
                        top: 2.h,
                        left: 2.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: OrientalTheme.accentGreen,
                            borderRadius: BorderRadius.circular(4.r),
                            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                          ),
                          child: Text(
                            'New',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 7.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Arabic Title Below Card
            Text(
              game.titleAr,
              style: GoogleFonts.cairo(
                color: OrientalTheme.primaryGold,
                fontSize: 9.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  // 3. BOTTOM ACTION & PLAY NOW CTA BAR
  // ─────────────────────────────────────────────────────
  Widget _buildBottomControlBar() {
    return Row(
      children: [
        // Action Medallion Buttons (Bottom Left)
        _buildActionMedallion(Icons.home_rounded, 'الرئيسية'),
        SizedBox(width: 12.w),
        _buildActionMedallion(Icons.settings_rounded, 'إعدادات'),
        SizedBox(width: 12.w),
        _buildActionMedallion(Icons.email_rounded, 'البريد'),
        SizedBox(width: 12.w),
        _buildActionMedallion(Icons.event_available_rounded, 'المهمة'),

        const Spacer(),

        // Store Shopping Cart Oval Button ( المتجر 🛒 )
        _buildStoreButton(),

        SizedBox(width: 10.w),

        // Play Now Banner Button ( العبها الآن - عادية 🎮 )
        _buildPlayNowBanner(),
      ],
    );
  }

  Widget _buildActionMedallion(IconData icon, String label) {
    return GestureDetector(
      onTap: () => SoundManager().playButtonClick(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(7.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFF8D6E63), Color(0xFF4E342E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: OrientalTheme.primaryGold, width: 1.5.w),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6)],
            ),
            child: Icon(icon, color: OrientalTheme.primaryGold, size: 16.r),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: OrientalTheme.primaryGold,
              fontSize: 7.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreButton() {
    return GestureDetector(
      onTap: () => SoundManager().playButtonClick(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: OrientalTheme.storeBtnGradient,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: OrientalTheme.primaryGold, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6D00).withValues(alpha: 0.5),
              blurRadius: 8.r,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 16.r),
            SizedBox(width: 4.w),
            Text(
              'المتجر',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayNowBanner() {
    return GestureDetector(
      onTap: () {
        SoundManager().playCardDeal();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BalootGameScreen(
              roomName: 'تحدي السلاطين 👑',
              betCoins: 5000,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: OrientalTheme.playNowGradient,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            bottomLeft: Radius.circular(20.r),
            topRight: Radius.circular(6.r),
            bottomRight: Radius.circular(6.r),
          ),
          border: Border.all(color: Colors.white, width: 1.5.w),
          boxShadow: [
            BoxShadow(
              color: OrientalTheme.primaryGold.withValues(alpha: 0.5),
              blurRadius: 10.r,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.sports_esports_rounded, color: Colors.black, size: 20.r),
            SizedBox(width: 6.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'العبها الآن',
                  style: GoogleFonts.cairo(
                    color: Colors.black,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  'عادية',
                  style: GoogleFonts.cairo(
                    color: Colors.black87,
                    fontSize: 7.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
