import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/audio/sound_manager.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SoundManager _soundManager = SoundManager();
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await SupabaseService().fetchUserProfile();
    if (mounted) setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الملف الشخصي للسلطان 🛡️',
                style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: Profile Card Header & Stats
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          gradient: OrientalTheme.emeraldGradient,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: OrientalTheme.primaryGold, width: 1.2.w),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28.r,
                                  backgroundImage: NetworkImage(_user!.avatarUrl),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _user!.name,
                                        style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 15.sp, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        '${_user!.title} • ${_user!.vipTier}',
                                        style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 11.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            // Level Progress
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('المستوى ${_user!.level}', style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 10.sp)),
                                    Text('${(_user!.xpProgress * 100).toInt()}%', style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 10.sp)),
                                  ],
                                ),
                                SizedBox(height: 3.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: LinearProgressIndicator(
                                    value: _user!.xpProgress,
                                    color: OrientalTheme.primaryGold,
                                    backgroundColor: Colors.black38,
                                    minHeight: 6.h,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            // Stats Grid
                            Row(
                              children: [
                                Expanded(child: _buildStatBox('الفوز', '${_user!.wins}', Icons.emoji_events, OrientalTheme.accentEmerald)),
                                SizedBox(width: 6.w),
                                Expanded(child: _buildStatBox('النسبة', '${_user!.winRate.toStringAsFixed(0)}%', Icons.pie_chart, OrientalTheme.primaryGold)),
                                SizedBox(width: 6.w),
                                Expanded(child: _buildStatBox('المجلس', 'السلاطين', Icons.meeting_room, OrientalTheme.accentAmber)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 14.w),

                    // Right Side: Audio & Settings Card
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: OrientalTheme.bgCard,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: OrientalTheme.primaryGold.withValues(alpha: 0.2), width: 1.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إعدادات الصوت والمجلس ⚙️',
                              style: GoogleFonts.cairo(color: OrientalTheme.primaryGold, fontSize: 13.sp, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 6.h),
                            SwitchListTile(
                              activeThumbColor: OrientalTheme.primaryGold,
                              title: Text('المؤثرات الصوتية', style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 11.sp)),
                              value: _soundManager.isSoundEnabled,
                              onChanged: (val) {
                                setState(() => _soundManager.toggleSound(val));
                              },
                            ),
                            SwitchListTile(
                              activeThumbColor: OrientalTheme.primaryGold,
                              title: Text('الموسيقى الشرقية', style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontSize: 11.sp)),
                              value: _soundManager.isMusicEnabled,
                              onChanged: (val) {
                                setState(() => _soundManager.toggleMusic(val));
                              },
                            ),
                          ],
                        ),
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

  Widget _buildStatBox(String title, String val, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: OrientalTheme.bgCard,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16.r),
          SizedBox(height: 2.h),
          Text(val, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp)),
          Text(title, style: GoogleFonts.cairo(color: OrientalTheme.textMuted, fontSize: 8.sp)),
        ],
      ),
    );
  }
}
