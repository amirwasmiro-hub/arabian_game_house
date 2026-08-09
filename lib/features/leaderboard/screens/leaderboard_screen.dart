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
            ? Center(child: CircularProgressIndicator(color: OrientalTheme.accentCyan, strokeWidth: 2.5.w))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emoji_events_rounded, color: OrientalTheme.primaryGold, size: 20.r),
                        SizedBox(width: 6.w),
                        Text(
                          'قائمة صدارة المحترفين 🏆',
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
                      child: Row(
                        children: [
                          // Left Panel: Cyber Podium
                          if (_topSultans.length >= 3)
                            Expanded(
                              flex: 4,
                              child: _buildCyberPodium(),
                            ),
                          SizedBox(width: 14.w),
                          // Right Panel: Rankings List
                          Expanded(
                            flex: 6,
                            child: ListView.separated(
                              itemCount: _topSultans.length,
                              separatorBuilder: (context, index) => SizedBox(height: 6.h),
                              itemBuilder: (context, index) {
                                final sultan = _topSultans[index];
                                final isMe = index == 3;
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: isMe ? OrientalTheme.accentCyan.withValues(alpha: 0.15) : OrientalTheme.bgCard,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isMe ? OrientalTheme.accentCyan : Colors.white.withValues(alpha: 0.08),
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '#${index + 1}',
                                        style: GoogleFonts.cairo(
                                          color: index < 3 ? OrientalTheme.primaryGold : OrientalTheme.accentCyan,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 12.sp,
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
                                              style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp),
                                            ),
                                            Text(
                                              sultan.vipTier,
                                              style: GoogleFonts.cairo(color: OrientalTheme.textMuted, fontSize: 8.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text('🪙 ', style: TextStyle(fontSize: 10.sp)),
                                          Text(
                                            '${sultan.coins}',
                                            style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontWeight: FontWeight.w800, fontSize: 10.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
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

  Widget _buildCyberPodium() {
    final first = _topSultans[0];
    final second = _topSultans[1];
    final third = _topSultans[2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumStep(second, '2', OrientalTheme.accentCyan, 90.h),
        SizedBox(width: 8.w),
        _buildPodiumStep(first, '1', OrientalTheme.primaryGold, 120.h, isFirst: true),
        SizedBox(width: 8.w),
        _buildPodiumStep(third, '3', OrientalTheme.accentPurple, 75.h),
      ],
    );
  }

  Widget _buildPodiumStep(UserModel user, String rank, Color accentColor, double height, {bool isFirst = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isFirst) Icon(Icons.workspace_premium_rounded, color: OrientalTheme.primaryGold, size: 24.r),
          CircleAvatar(
            radius: isFirst ? 22.r : 17.r,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          SizedBox(height: 4.h),
          Text(
            user.name,
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor.withValues(alpha: 0.3), accentColor.withValues(alpha: 0.08)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.w),
            ),
            child: Center(
              child: Text(
                rank,
                style: GoogleFonts.cairo(color: accentColor, fontWeight: FontWeight.w900, fontSize: 22.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
