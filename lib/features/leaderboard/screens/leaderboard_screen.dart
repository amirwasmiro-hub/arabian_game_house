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
            ? Center(child: CircularProgressIndicator(color: OrientalTheme.primaryGold, strokeWidth: 3.w))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سلاطين البلوت والألعاب 👑',
                      style: GoogleFonts.cairo(
                        color: OrientalTheme.primaryGold,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: Row(
                        children: [
                          // Left Panel: Podium
                          if (_topSultans.length >= 3)
                            Expanded(
                              flex: 4,
                              child: _buildPodium(),
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
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: index == 3 ? OrientalTheme.primaryGold.withValues(alpha: 0.15) : OrientalTheme.bgCard,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: index == 3 ? OrientalTheme.primaryGold : Colors.transparent,
                                      width: 1.w,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '#${index + 1}',
                                        style: GoogleFonts.cairo(
                                          color: OrientalTheme.primaryGold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.sp,
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
                                                color: OrientalTheme.textLight,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                            Text(
                                              sultan.title,
                                              style: GoogleFonts.cairo(
                                                color: OrientalTheme.textMuted,
                                                fontSize: 10.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${sultan.coins} 🪙',
                                            style: GoogleFonts.cairo(
                                              color: OrientalTheme.primaryGold,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                          Text(
                                            'فوز: ${sultan.winRate.toStringAsFixed(0)}%',
                                            style: GoogleFonts.cairo(
                                              color: OrientalTheme.accentEmerald,
                                              fontSize: 9.sp,
                                            ),
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

  Widget _buildPodium() {
    final first = _topSultans[0];
    final second = _topSultans[1];
    final third = _topSultans[2];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 2nd Place
        _buildPodiumStep(second, rank: 2, height: 110.h, color: Colors.blueGrey.shade300),
        SizedBox(width: 8.w),
        // 1st Place
        _buildPodiumStep(first, rank: 1, height: 140.h, color: OrientalTheme.primaryGold),
        SizedBox(width: 8.w),
        // 3rd Place
        _buildPodiumStep(third, rank: 3, height: 90.h, color: Colors.amber.shade800),
      ],
    );
  }

  Widget _buildPodiumStep(UserModel user, {required int rank, required double height, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 24.r : 20.r,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            if (rank == 1)
              Positioned(
                top: -4.h,
                right: -4.w,
                child: Text('👑', style: TextStyle(fontSize: 14.sp)),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          user.name.split(' ')[0],
          style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 10.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        Container(
          width: 70.w,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            border: Border.all(color: color, width: 1.2.w),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#$rank',
                style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.bold, fontSize: 18.sp),
              ),
              Text(
                '${user.coins}',
                style: GoogleFonts.cairo(color: Colors.white, fontSize: 9.sp),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
