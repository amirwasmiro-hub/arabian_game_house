import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/game_model.dart';
import '../../../core/models/room_model.dart';
import '../widgets/daily_reward_widget.dart';
import '../widgets/room_creation_modal.dart';
import '../../game_table/baloot_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  UserModel? _user;
  List<RoomModel> _activeRooms = [];
  bool _isLoading = true;
  int _selectedGameIndex = 0;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _loadData();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await SupabaseService().fetchUserProfile();
    final rooms = await SupabaseService().fetchActiveRooms();
    if (mounted) {
      setState(() {
        _user = user;
        _activeRooms = rooms;
        _isLoading = false;
      });
    }
  }

  void _openCreateRoomModal() {
    SoundManager().playButtonClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomCreationModal(onRoomCreated: _loadData),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return Scaffold(
        backgroundColor: OrientalTheme.bgDark,
        body: Center(
          child: CircularProgressIndicator(
            color: OrientalTheme.primaryGold,
            strokeWidth: 2.w,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: Stack(
        children: [
          // ─── Animated Background Pattern ───────────────
          Positioned.fill(
            child: CustomPaint(painter: ArabianPatternPainter(opacity: 0.035)),
          ),

          // ─── Radial Top-Left Glow ───────────────────────
          Positioned(
            top: -60.h,
            left: -40.w,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) => Container(
                width: 280.w,
                height: 200.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      OrientalTheme.primaryGold.withValues(
                        alpha: 0.07 + _glowController.value * 0.06,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Main 3-Column Layout ──────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              child: Row(
                children: [
                  // ════ LEFT PANEL — Player Profile ════
                  _buildLeftPanel(),

                  SizedBox(width: 12.w),

                  // ════ CENTER PANEL — Featured Game ════
                  _buildCenterPanel(),

                  SizedBox(width: 12.w),

                  // ════ RIGHT PANEL — Live Rooms ════
                  _buildRightPanel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // LEFT PANEL
  // ───────────────────────────────────────────────
  Widget _buildLeftPanel() {
    return SizedBox(
      width: 185.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar & Name Card
          _buildProfileCard()
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.2),

          SizedBox(height: 8.h),

          // Currency Row
          Row(
            children: [
              Expanded(
                child: _buildCurrencyBadge(
                  '🪙',
                  '${_user!.coins}',
                  OrientalTheme.primaryGold,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildCurrencyBadge(
                  '💎',
                  '${_user!.gems}',
                  OrientalTheme.accentEmerald,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // XP Progress
          _buildXpBar().animate().fadeIn(delay: 200.ms),

          SizedBox(height: 10.h),

          // Win Stats Row
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  '${_user!.wins}',
                  'فوز',
                  OrientalTheme.accentEmerald,
                  Icons.emoji_events_rounded,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildMiniStat(
                  '${_user!.winRate.toStringAsFixed(0)}%',
                  'نسبة',
                  OrientalTheme.primaryGold,
                  Icons.pie_chart_rounded,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Daily Reward compact
          const DailyRewardWidget().animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [OrientalTheme.bgCard, OrientalTheme.bgElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: OrientalTheme.primaryGold.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          // Avatar with glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: OrientalTheme.primaryGold.withValues(
                      alpha: 0.25 + _glowController.value * 0.2,
                    ),
                    blurRadius: 10.r,
                    spreadRadius: 1.r,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22.r,
                backgroundImage: NetworkImage(_user!.avatarUrl),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _user!.name,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        OrientalTheme.goldDark,
                        OrientalTheme.primaryGold,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Text(
                    _user!.vipTier,
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBadge(String emoji, String amount, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 12.sp)),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              amount,
              style: GoogleFonts.cairo(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 10.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المستوى ${_user!.level}',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 9.sp),
            ),
            Text(
              '${(_user!.xpProgress * 100).toInt()}%',
              style: GoogleFonts.cairo(
                color: OrientalTheme.primaryGold,
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Stack(
          children: [
            Container(
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            FractionallySizedBox(
              widthFactor: _user!.xpProgress,
              child: Container(
                height: 5.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [OrientalTheme.goldDark, OrientalTheme.goldLight],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: OrientalTheme.primaryGold.withValues(alpha: 0.5),
                      blurRadius: 4.r,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.w),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 14.r),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.sp,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(color: Colors.white38, fontSize: 8.sp),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // CENTER PANEL — Featured Game Hero Card
  // ───────────────────────────────────────────────
  Widget _buildCenterPanel() {
    final games = GameModel.gamesList;
    final selectedGame = games[_selectedGameIndex];

    return Expanded(
      child: Column(
        children: [
          // Featured Hero Card
          Expanded(
            flex: 7,
            child: _buildHeroGameCard(selectedGame)
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.95, 0.95)),
          ),

          SizedBox(height: 8.h),

          // Horizontal Game Selector Tabs
          SizedBox(
            height: 46.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              separatorBuilder: (_, __) => SizedBox(width: 7.w),
              itemBuilder: (context, index) {
                final game = games[index];
                final isSelected = _selectedGameIndex == index;
                return GestureDetector(
                  onTap: () {
                    SoundManager().playButtonClick();
                    setState(() => _selectedGameIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? game.primaryColor.withValues(alpha: 0.2)
                          : OrientalTheme.bgCard,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? game.primaryColor : Colors.white12,
                        width: isSelected ? 1.5.w : 1.w,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: game.primaryColor.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 8.r,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          game.icon,
                          color: isSelected
                              ? game.primaryColor
                              : Colors.white38,
                          size: 13.r,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          game.titleAr,
                          style: GoogleFonts.cairo(
                            color: isSelected
                                ? game.primaryColor
                                : Colors.white54,
                            fontSize: 10.sp,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGameCard(GameModel game) {
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
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (_, __) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                OrientalTheme.bgCard,
                game.primaryColor.withValues(alpha: 0.12),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: game.primaryColor.withValues(
                alpha: 0.3 + _glowController.value * 0.3,
              ),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: game.primaryColor.withValues(
                  alpha: 0.1 + _glowController.value * 0.12,
                ),
                blurRadius: 20.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background decorative icon
              Positioned(
                right: -10.w,
                bottom: -10.h,
                child: Icon(
                  game.icon,
                  size: 130.r,
                  color: game.primaryColor.withValues(alpha: 0.06),
                ),
              ),

              // Islamic pattern overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: CustomPaint(
                    painter: ArabianPatternPainter(
                      color: game.primaryColor,
                      opacity: 0.03,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(18.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: game.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: game.primaryColor.withValues(alpha: 0.4),
                              width: 1.w,
                            ),
                          ),
                          child: Icon(
                            game.icon,
                            color: game.primaryColor,
                            size: 22.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.titleAr,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              game.titleEn.toUpperCase(),
                              style: GoogleFonts.cairo(
                                color: game.primaryColor.withValues(alpha: 0.7),
                                fontSize: 9.sp,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: game.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: game.primaryColor.withValues(alpha: 0.4),
                              width: 1.w,
                            ),
                          ),
                          child: Text(
                            game.badgeTag,
                            style: GoogleFonts.cairo(
                              color: game.primaryColor,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Text(
                      game.subtitle,
                      style: GoogleFonts.cairo(
                        color: Colors.white60,
                        fontSize: 10.sp,
                        height: 1.4,
                      ),
                      maxLines: 2,
                    ),

                    SizedBox(height: 12.h),

                    Row(
                      children: [
                        // Online players badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: OrientalTheme.accentEmerald.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: OrientalTheme.accentEmerald.withValues(
                                alpha: 0.3,
                              ),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6.r,
                                height: 6.r,
                                decoration: const BoxDecoration(
                                  color: OrientalTheme.accentEmerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                '${game.onlinePlayers} لاعب الآن',
                                style: GoogleFonts.cairo(
                                  color: OrientalTheme.accentEmerald,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Play Button
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                game.primaryColor,
                                game.primaryColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: [
                              BoxShadow(
                                color: game.primaryColor.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 8.r,
                                offset: Offset(0, 3.h),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.r),
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
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 7.h,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.black,
                                      size: 14.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'العب الآن',
                                      style: GoogleFonts.cairo(
                                        color: Colors.black,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────
  // RIGHT PANEL — Live Game Rooms
  // ───────────────────────────────────────────────
  Widget _buildRightPanel() {
    return SizedBox(
      width: 195.w,
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 3.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: OrientalTheme.primaryGold,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'مجالس مباشر',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _openCreateRoomModal,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        OrientalTheme.goldDark,
                        OrientalTheme.primaryGold,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.black, size: 11.r),
                      SizedBox(width: 2.w),
                      Text(
                        'جديد',
                        style: GoogleFonts.cairo(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          SizedBox(height: 7.h),

          // Rooms List
          Expanded(
            child: ListView.separated(
              itemCount: _activeRooms.length,
              separatorBuilder: (_, __) => SizedBox(height: 6.h),
              itemBuilder: (context, index) {
                return _buildRoomCard(_activeRooms[index])
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 150 + index * 80))
                    .slideX(begin: 0.1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    final bool isActive = room.status == 'جاري اللعب';
    final Color statusColor = isActive
        ? OrientalTheme.accentRuby
        : OrientalTheme.accentEmerald;

    return GestureDetector(
      onTap: () {
        SoundManager().playCardFlip();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BalootGameScreen(
              roomName: room.roomName,
              betCoins: room.betCoins,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(9.r),
        decoration: BoxDecoration(
          color: OrientalTheme.bgCard,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(
            color: isActive
                ? OrientalTheme.accentRuby.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.07),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status dot
                Container(
                  width: 6.r,
                  height: 6.r,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.6),
                        blurRadius: 4.r,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    room.roomName,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (room.isPrivate)
                  Icon(
                    Icons.lock_rounded,
                    color: OrientalTheme.primaryGold,
                    size: 10.r,
                  ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                CircleAvatar(
                  radius: 10.r,
                  backgroundImage: NetworkImage(room.hostAvatar),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Text(
                    room.hostName,
                    style: GoogleFonts.cairo(
                      color: Colors.white54,
                      fontSize: 8.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bet
                Row(
                  children: [
                    Text('🪙', style: TextStyle(fontSize: 9.sp)),
                    SizedBox(width: 2.w),
                    Text(
                      '${room.betCoins}',
                      style: GoogleFonts.cairo(
                        color: OrientalTheme.primaryGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
                // Players count chips
                _buildPlayerDots(room.currentPlayers, room.maxPlayers),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerDots(int current, int max) {
    return Row(
      children: List.generate(max, (i) {
        final filled = i < current;
        return Padding(
          padding: EdgeInsets.only(left: 3.w),
          child: Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              color: filled
                  ? OrientalTheme.accentEmerald
                  : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: OrientalTheme.accentEmerald.withValues(
                          alpha: 0.5,
                        ),
                        blurRadius: 3.r,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
