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
            color: OrientalTheme.accentCyan,
            strokeWidth: 2.5.w,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: Stack(
        children: [
          // ─── Cyber Tech Grid Background ───────────────
          Positioned.fill(
            child: CustomPaint(
              painter: ArabianPatternPainter(
                color: OrientalTheme.accentCyan,
                opacity: 0.03,
              ),
            ),
          ),

          // ─── Ambient Neon Backdrop Glows ─────────────
          Positioned(
            top: -70.h,
            left: -50.w,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) => Container(
                width: 320.w,
                height: 220.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      OrientalTheme.accentPurple.withValues(
                        alpha: 0.12 + _glowController.value * 0.08,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60.h,
            right: -40.w,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) => Container(
                width: 300.w,
                height: 200.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      OrientalTheme.accentCyan.withValues(
                        alpha: 0.10 + _glowController.value * 0.06,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Main 3-Column Modern Gaming Layout ─────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              child: Row(
                children: [
                  // ════ LEFT PANEL — Gamer Card & Stats ════
                  _buildLeftPanel(),

                  SizedBox(width: 12.w),

                  // ════ CENTER PANEL — Logo & Hero Game Card ════
                  _buildCenterPanel(),

                  SizedBox(width: 12.w),

                  // ════ RIGHT PANEL — Live Battle Lobbies ════
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
  // LEFT PANEL — Gamer Card & Stats
  // ───────────────────────────────────────────────
  Widget _buildLeftPanel() {
    return SizedBox(
      width: 190.w,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gamer Profile Header
            _buildGamerProfileCard()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.2),

            SizedBox(height: 6.h),

            // Currency Pill Badges
            Row(
              children: [
                Expanded(
                  child: _buildCyberCurrencyBadge(
                    '🪙',
                    '${_user!.coins}',
                    OrientalTheme.primaryGold,
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: _buildCyberCurrencyBadge(
                    '💎',
                    '${_user!.gems}',
                    OrientalTheme.accentCyan,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // Level & XP Bar
            _buildCyberXpBar().animate().fadeIn(delay: 150.ms),

            SizedBox(height: 6.h),

            // Win Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildCyberStatCard(
                    '${_user!.wins}',
                    'انتصار',
                    OrientalTheme.accentEmerald,
                    Icons.emoji_events_rounded,
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: _buildCyberStatCard(
                    '${_user!.winRate.toStringAsFixed(0)}%',
                    'معدل الفوز',
                    OrientalTheme.accentPurple,
                    Icons.bolt_rounded,
                  ),
                ),
              ],
            ),

            SizedBox(height: 6.h),

            // Daily Reward Compact Card
            const DailyRewardWidget().animate().fadeIn(delay: 250.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildGamerProfileCard() {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: OrientalTheme.bgCard,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: OrientalTheme.accentCyan.withValues(alpha: 0.3),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cyber Avatar Frame
          AnimatedBuilder(
            animation: _glowController,
            builder: (_, _) => Container(
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: const [
                    OrientalTheme.accentCyan,
                    OrientalTheme.accentPurple,
                    OrientalTheme.primaryGold,
                    OrientalTheme.accentCyan,
                  ],
                  transform: GradientRotation(_glowController.value * 6.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: OrientalTheme.accentCyan.withValues(
                      alpha: 0.3 + _glowController.value * 0.2,
                    ),
                    blurRadius: 8.r,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 20.r,
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
                    color: OrientalTheme.textLight,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        OrientalTheme.accentPurple,
                        OrientalTheme.accentCyan,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    _user!.vipTier,
                    style: GoogleFonts.cairo(
                      color: Colors.black,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
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

  Widget _buildCyberCurrencyBadge(
    String emoji,
    String amount,
    Color accentColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 11.sp)),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              amount,
              style: GoogleFonts.cairo(
                color: accentColor,
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

  Widget _buildCyberXpBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المستوى ${_user!.level}',
              style: GoogleFonts.cairo(
                color: OrientalTheme.textMuted,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(_user!.xpProgress * 100).toInt()}%',
              style: GoogleFonts.cairo(
                color: OrientalTheme.accentCyan,
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
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
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            FractionallySizedBox(
              widthFactor: _user!.xpProgress,
              child: Container(
                height: 5.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      OrientalTheme.accentPurple,
                      OrientalTheme.accentCyan,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: OrientalTheme.accentCyan.withValues(alpha: 0.6),
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

  Widget _buildCyberStatCard(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 14.r),
          SizedBox(height: 2.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11.sp,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: OrientalTheme.textMuted,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────
  // TOP CENTER LOGO & CENTER PANEL
  // ───────────────────────────────────────────────
  Widget _buildTopCenterLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bolt_rounded, color: OrientalTheme.accentCyan, size: 16.r),
        SizedBox(width: 5.w),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              OrientalTheme.accentCyan,
              OrientalTheme.primaryGold,
              OrientalTheme.accentPurple,
            ],
          ).createShader(bounds),
          child: Text(
            'بيت الألعاب العربية',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(width: 5.w),
        Icon(Icons.bolt_rounded, color: OrientalTheme.accentCyan, size: 16.r),
      ],
    );
  }

  Widget _buildCenterPanel() {
    final games = GameModel.gamesList;
    final selectedGame = games[_selectedGameIndex];

    return Expanded(
      child: Column(
        children: [
          // Top Center Logo
          _buildTopCenterLogo()
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.2),

          SizedBox(height: 6.h),

          // Modern Hero Game Card
          Expanded(
            flex: 7,
            child: _buildHeroGameCard(selectedGame)
                .animate()
                .fadeIn(duration: 450.ms)
                .scale(begin: const Offset(0.96, 0.96)),
          ),

          SizedBox(height: 8.h),

          // Horizontal Cyber Game Selector Tabs
          SizedBox(
            height: 44.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              separatorBuilder: (_, _) => SizedBox(width: 7.w),
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
                          ? OrientalTheme.accentCyan.withValues(alpha: 0.15)
                          : OrientalTheme.bgCard,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? OrientalTheme.accentCyan
                            : Colors.white.withValues(alpha: 0.08),
                        width: isSelected ? 1.5.w : 1.w,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: OrientalTheme.accentCyan.withValues(
                                  alpha: 0.3,
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
                              ? OrientalTheme.accentCyan
                              : Colors.white38,
                          size: 13.r,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          game.titleAr,
                          style: GoogleFonts.cairo(
                            color: isSelected
                                ? OrientalTheme.textLight
                                : Colors.white54,
                            fontSize: 10.sp,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
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
        builder: (_, _) => Container(
          decoration: BoxDecoration(
            color: game.cardGradientColors[0],
            image: DecorationImage(
              image: AssetImage(game.cardImagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                game.cardGradientColors[0].withValues(alpha: 0.55),
                BlendMode.multiply,
              ),
            ),
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: game.primaryColor.withValues(
                alpha: 0.4 + _glowController.value * 0.4,
              ),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: game.primaryColor.withValues(
                  alpha: 0.2 + _glowController.value * 0.2,
                ),
                blurRadius: 20.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Subtle dark gradient overlay at bottom for text legibility
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          game.cardGradientColors[0].withValues(alpha: 0.7),
                        ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // Subtle Hex Grid Pattern Overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22.r),
                  child: CustomPaint(
                    painter: ArabianPatternPainter(
                      color: game.primaryColor,
                      opacity: 0.04,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: game.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: game.primaryColor.withValues(alpha: 0.5),
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: game.primaryColor.withValues(alpha: 0.4),
                                blurRadius: 10.r,
                              ),
                            ],
                          ),
                          child: Icon(
                            game.icon,
                            color: game.primaryColor,
                            size: 20.r,
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
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              game.titleEn.toUpperCase(),
                              style: GoogleFonts.cairo(
                                color: game.primaryColor.withValues(alpha: 0.8),
                                fontSize: 8.sp,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: game.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: game.primaryColor.withValues(alpha: 0.5),
                              width: 1.w,
                            ),
                          ),
                          child: Text(
                            game.badgeTag,
                            style: GoogleFonts.cairo(
                              color: OrientalTheme.accentCyan,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Text(
                      game.subtitle,
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 10.sp,
                        height: 1.3,
                      ),
                      maxLines: 2,
                    ),

                    SizedBox(height: 10.h),

                    Row(
                      children: [
                        // Live Online Players Indicator
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
                                alpha: 0.35,
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
                                '${game.onlinePlayers} متصل الآن',
                                style: GoogleFonts.cairo(
                                  color: OrientalTheme.accentEmerald,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
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
  // RIGHT PANEL — Live Battle Lobbies
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
                      gradient: const LinearGradient(
                        colors: [
                          OrientalTheme.accentCyan,
                          OrientalTheme.accentPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'غرف التحدي المباشر',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
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
                        OrientalTheme.accentCyan,
                        OrientalTheme.accentPurple,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add, color: Colors.black, size: 11.r),
                      SizedBox(width: 2.w),
                      Text(
                        'غرفة',
                        style: GoogleFonts.cairo(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
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
              separatorBuilder: (_, _) => SizedBox(height: 6.h),
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
                ? OrientalTheme.accentRuby.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.w,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
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
                      color: OrientalTheme.textMuted,
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
                Row(
                  children: [
                    Text('🪙', style: TextStyle(fontSize: 9.sp)),
                    SizedBox(width: 2.w),
                    Text(
                      '${room.betCoins}',
                      style: GoogleFonts.cairo(
                        color: OrientalTheme.primaryGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
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
                  ? OrientalTheme.accentCyan
                  : Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: OrientalTheme.accentCyan.withValues(alpha: 0.5),
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
