import 'package:flutter/material.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  List<RoomModel> _activeRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
      builder: (context) => RoomCreationModal(
        onRoomCreated: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return Scaffold(
        backgroundColor: OrientalTheme.bgDark,
        body: Center(child: CircularProgressIndicator(color: OrientalTheme.primaryGold, strokeWidth: 3.w)),
      );
    }

    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              // Top Bar Header across widescreen
              _buildHeaderBar(),
              SizedBox(height: 10.h),

              // Main Landscape Content Split into Left & Right Panels
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Panel - Featured Games (3 columns grid)
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ألعاب بيت السلاطين 👑',
                                style: GoogleFonts.cairo(
                                  color: OrientalTheme.primaryGold,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '6 ألعاب شعبية',
                                style: GoogleFonts.cairo(color: OrientalTheme.textMuted, fontSize: 11.sp),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Expanded(
                            child: GridView.builder(
                              itemCount: GameModel.gamesList.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10.w,
                                mainAxisSpacing: 10.h,
                                childAspectRatio: 1.3,
                              ),
                              itemBuilder: (context, index) {
                                final game = GameModel.gamesList[index];
                                return _buildGameCard(game);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 14.w),

                    // Right Panel - Daily Reward & Active Lobbies List
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DailyRewardWidget(),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'مجالس اللعب المباشر 🏛️',
                                style: GoogleFonts.cairo(
                                  color: OrientalTheme.primaryGold,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: _openCreateRoomModal,
                                borderRadius: BorderRadius.circular(8.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: OrientalTheme.primaryGold,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add, size: 14.r, color: Colors.black),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'إنشاء مجلس',
                                        style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Expanded(
                            child: ListView.separated(
                              itemCount: _activeRooms.length,
                              separatorBuilder: (context, index) => SizedBox(height: 6.h),
                              itemBuilder: (context, index) {
                                final room = _activeRooms[index];
                                return _buildRoomTile(room);
                              },
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHeaderBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: OrientalTheme.bgCard,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundImage: NetworkImage(_user!.avatarUrl),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Row(
              children: [
                Text(
                  _user!.name,
                  style: GoogleFonts.cairo(
                    color: OrientalTheme.textLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: OrientalTheme.primaryGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    _user!.title,
                    style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 10.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Coins Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: OrientalTheme.bgDark,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.5), width: 1.w),
            ),
            child: Row(
              children: [
                Text('🪙 ', style: TextStyle(fontSize: 11.sp)),
                Text(
                  '${_user!.coins}',
                  style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Gems Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: OrientalTheme.bgDark,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: OrientalTheme.accentEmerald.withValues(alpha: 0.5), width: 1.w),
            ),
            child: Row(
              children: [
                Text('💎 ', style: TextStyle(fontSize: 11.sp)),
                Text(
                  '${_user!.gems}',
                  style: GoogleFonts.cairo(color: OrientalTheme.accentEmerald, fontWeight: FontWeight.bold, fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(GameModel game) {
    return InkWell(
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
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: OrientalTheme.bgCard,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: game.primaryColor.withValues(alpha: 0.4), width: 1.2.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(game.icon, color: game.primaryColor, size: 22.r),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: game.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    game.badgeTag,
                    style: GoogleFonts.cairo(color: game.primaryColor, fontSize: 8.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.titleAr,
                  style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13.sp),
                ),
                Text(
                  '${game.onlinePlayers} متصل 🟢',
                  style: GoogleFonts.cairo(color: OrientalTheme.textMuted, fontSize: 9.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTile(RoomModel room) {
    return InkWell(
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
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: OrientalTheme.bgCard,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.2), width: 1.w),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14.r,
              backgroundImage: NetworkImage(room.hostAvatar),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomName,
                    style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontWeight: FontWeight.bold, fontSize: 11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'المنظم: ${room.hostName}',
                    style: GoogleFonts.cairo(color: OrientalTheme.textMuted, fontSize: 9.sp),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${room.betCoins} 🪙',
                  style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 10.sp),
                ),
                Text(
                  '${room.currentPlayers}/${room.maxPlayers} لاعبين',
                  style: GoogleFonts.cairo(color: OrientalTheme.accentEmerald, fontSize: 9.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
