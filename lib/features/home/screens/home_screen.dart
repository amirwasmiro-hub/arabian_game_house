import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/sound_manager.dart';
import '../../game_table/backgammon_31_game_screen.dart';
import '../../game_table/backgammon_classic_game_screen.dart';
import '../../game_table/chess_game_screen.dart';
import '../../game_table/domino_american_game_screen.dart';
import '../../game_table/domino_classic_game_screen.dart';
import '../../game_table/estimation_game_screen.dart';
import '../../game_table/ludo_game_screen.dart';
import '../../game_table/tarneeb_game_screen.dart';
import '../../game_table/uno_game_screen.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../store/screens/store_screen.dart';
import '../widgets/compact_top_header.dart';
import '../widgets/domino_game_card.dart';
import '../widgets/royal_bottom_nav_bar.dart';

class GameTileData {
  final String titleEn;
  final String titleAr;
  final IconData icon;
  final String? assetPath;
  final Color cardBgColor;
  final Color cardBorderColor;
  final bool isNew;
  final Widget targetScreen;

  const GameTileData({
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    this.assetPath,
    required this.cardBgColor,
    required this.cardBorderColor,
    this.isNew = false,
    required this.targetScreen,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _selectedGameTitle = 'بيت الألعاب العربية';
  int _selectedBottomNavTab = 0;

  final List<GameTileData> _allGames = const [
    GameTileData(
      titleEn: 'ESTIMATION',
      titleAr: 'استميشن',
      icon: Icons.style_rounded,
      assetPath: 'assets/images/estimation.png',
      cardBgColor: Color(0xFF1B5E20),
      cardBorderColor: Color(0xFFFFD700),
      targetScreen: EstimationGameScreen(),
    ),
    GameTileData(
      titleEn: 'TARNEEB',
      titleAr: 'تارنيب',
      icon: Icons.filter_vintage_rounded,
      assetPath: 'assets/images/tarneeb.png',
      cardBgColor: Color(0xFF5D1010),
      cardBorderColor: Color(0xFFFFD700),
      targetScreen: TarneebGameScreen(),
    ),
    GameTileData(
      titleEn: 'DOMINO AMERICAN',
      titleAr: 'دومينو أمريكاني',
      icon: Icons.grid_view_rounded,
      assetPath: 'assets/images/domino_american.png',
      cardBgColor: Color(0xFF0D47A1),
      cardBorderColor: Color(0xFFFFD700),
      isNew: true,
      targetScreen: DominoAmericanGameScreen(),
    ),
    GameTileData(
      titleEn: 'DOMINO CLASSIC',
      titleAr: 'دومينو عادية',
      icon: Icons.grid_on_rounded,
      assetPath: 'assets/images/domino_classic.png',
      cardBgColor: Color(0xFF3E2723),
      cardBorderColor: Color(0xFFFFD700),
      targetScreen: DominoClassicGameScreen(),
    ),
    GameTileData(
      titleEn: 'BACKGAMMON 31',
      titleAr: 'طاولة 31',
      icon: Icons.casino_rounded,
      assetPath: 'assets/images/backgammon_31.png',
      cardBgColor: Color(0xFF4A1024),
      cardBorderColor: Color(0xFFFFD700),
      isNew: true,
      targetScreen: Backgammon31GameScreen(),
    ),
    GameTileData(
      titleEn: 'BACKGAMMON CLASSIC',
      titleAr: 'طاولة عادية',
      icon: Icons.casino_outlined,
      assetPath: 'assets/images/backgammon_classic.png',
      cardBgColor: Color(0xFF5D1010),
      cardBorderColor: Color(0xFFFFD700),
      targetScreen: BackgammonClassicGameScreen(),
    ),
    GameTileData(
      titleEn: 'LUDO',
      titleAr: 'لودو',
      icon: Icons.stars_rounded,
      assetPath: 'assets/images/ludo.png',
      cardBgColor: Color(0xFF880E4F),
      cardBorderColor: Color(0xFFFFD700),
      targetScreen: LudoGameScreen(),
    ),
    GameTileData(
      titleEn: 'CHESS',
      titleAr: 'شطرنج',
      icon: Icons.extension_rounded,
      assetPath: 'assets/images/chess.png',
      cardBgColor: Color(0xFF3E2723),
      cardBorderColor: Color(0xFFFFD700),
      targetScreen: ChessGameScreen(),
    ),
    GameTileData(
      titleEn: 'UNO',
      titleAr: 'أونو',
      icon: Icons.layers_rounded,
      assetPath: 'assets/images/uno.png',
      cardBgColor: Color(0xFFE65100),
      cardBorderColor: Color(0xFFFFD700),
      isNew: true,
      targetScreen: UnoGameScreen(),
    ),
  ];

  void _onGameSelected(GameTileData game) {
    SoundManager().playButtonClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => game.targetScreen),
    );
  }

  void _onBottomTabSelected(int index) {
    SoundManager().playButtonClick();
    setState(() {
      _selectedBottomNavTab = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StoreScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      case 4:
        _showSettingsDialog();
        break;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF2E1205),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          ),
          title: Text(
            'الإعدادات',
            style: GoogleFonts.cairo(
              color: const Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.volume_up, color: Color(0xFFFFD700)),
                title: Text(
                  'المؤثرات الصوتية',
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                trailing: Switch(
                  value: SoundManager().isSoundEnabled,
                  activeThumbColor: const Color(0xFFFFD700),
                  onChanged: (val) {
                    setState(() {
                      SoundManager().toggleSound(val);
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Color(0xFFFFD700)),
                title: Text(
                  'الموسيقى',
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                trailing: Switch(
                  value: SoundManager().isMusicEnabled,
                  activeThumbColor: const Color(0xFFFFD700),
                  onChanged: (val) {
                    setState(() {
                      SoundManager().toggleMusic(val);
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'إغلاق',
                style: GoogleFonts.cairo(color: const Color(0xFFFFD700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/arabian_cafe_bg.png',
                fit: BoxFit.fill,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A0933), Color(0xFF421554)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 2.h),

                  CompactTopHeader(
                    onProfileTap: () => _onBottomTabSelected(3),
                    onAddCoinsTap: () => _onBottomTabSelected(1),
                    onAddTicketsTap: () => _onBottomTabSelected(1),
                    onOffersTap: () => _onBottomTabSelected(1),
                  ),

                  SizedBox(height: 1.h),

                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          width: 1.2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFFD700,
                            ).withValues(alpha: 0.25),
                            blurRadius: 12.r,
                          ),
                        ],
                      ),
                      child: Text(
                        _selectedGameTitle,
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFD700),
                          letterSpacing: 1.w,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFD700),
                              blurRadius: 10.r,
                            ),
                            Shadow(
                              color: Colors.black,
                              blurRadius: 4.r,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _allGames
                                .map(
                                  (game) => DominoGameCard(
                                    titleAr: game.titleAr,
                                    titleEn: game.titleEn,
                                    icon: game.icon,
                                    assetPath: game.assetPath,
                                    cardBgColor: game.cardBgColor,
                                    cardBorderColor: game.cardBorderColor,
                                    isNew: game.isNew,
                                    onTap: () => _onGameSelected(game),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  RoyalBottomNavBar(
                    selectedIndex: _selectedBottomNavTab,
                    onTabSelected: _onBottomTabSelected,
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
