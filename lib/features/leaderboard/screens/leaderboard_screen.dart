import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/user_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<UserModel> _topSultans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final list = await SupabaseService().fetchLeaderboard();
    if (mounted) {
      setState(() {
        _topSultans = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: OrientalTheme.primaryGold,
                  strokeWidth: 2.5.w,
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            color: OrientalTheme.primaryGold, size: 20.r),
                        SizedBox(width: 6.w),
                        Text(
                          'قائمة صدارة السلاطين 🏆',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Row(
                            children: [
                              if (_topSultans.length >= 3)
                                Expanded(
                                  flex: 4,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.bottomCenter,
                                      child: SizedBox(
                                        width: 220.w,
                                        child: _buildPodium(),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(width: 14.w),
                              Expanded(
                                flex: 6,
                                child: _buildRankingsList(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPodium() {
    final first = _topSultans[0];
    final second = _topSultans[1];
    final third = _topSultans[2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _buildPodiumStep(
            second,
            '٢',
            const Color(0xFFC0C0C0),
            75.h,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildPodiumStep(
            first,
            '١',
            OrientalTheme.primaryGold,
            100.h,
            isFirst: true,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _buildPodiumStep(
            third,
            '٣',
            const Color(0xFFCD7F32),
            60.h,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumStep(
    UserModel user,
    String rank,
    Color primaryColor,
    double height, {
    bool isFirst = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst)
          Icon(
            Icons.workspace_premium_rounded,
            color: OrientalTheme.primaryGold,
            size: 22.r,
          ),
        CircleAvatar(
          radius: isFirst ? 20.r : 16.r,
          backgroundImage: NetworkImage(user.avatarUrl),
        ),
        SizedBox(height: 4.h),
        Text(
          user.name,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 8.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.4),
              width: 1.w,
            ),
          ),
          child: Center(
            child: Text(
              rank,
              style: GoogleFonts.cairo(
                color: primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: isFirst ? 24.sp : 18.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankingsList() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: _topSultans.length,
      separatorBuilder: (context, index) => SizedBox(height: 6.h),
      itemBuilder: (context, index) {
        final sultan = _topSultans[index];
        final isMe = index == 3;
        final isTop3 = index < 3;

        Color rankColor;
        if (index == 0) {
          rankColor = OrientalTheme.primaryGold;
        } else if (index == 1) {
          rankColor = const Color(0xFFC0C0C0);
        } else if (index == 2) {
          rankColor = const Color(0xFFCD7F32);
        } else {
          rankColor = OrientalTheme.textMuted;
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isMe
                ? OrientalTheme.primaryGold.withValues(alpha: 0.12)
                : OrientalTheme.bgCard,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isMe
                  ? OrientalTheme.primaryGold
                  : isTop3
                      ? rankColor.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.08),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              Text(
                '#${index + 1}',
                style: GoogleFonts.cairo(
                  color: rankColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(width: 10.w),
              CircleAvatar(
                radius: 14.r,
                backgroundImage: NetworkImage(sultan.avatarUrl),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sultan.name,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                    Text(
                      sultan.vipTier,
                      style: GoogleFonts.cairo(
                        color: OrientalTheme.textMuted,
                        fontSize: 8.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text('🪙 ', style: TextStyle(fontSize: 10.sp)),
                  Text(
                    '${sultan.coins}',
                    style: GoogleFonts.cairo(
                      color: OrientalTheme.primaryGold,
                      fontWeight: FontWeight.w800,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
