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
  bool _hapticsEnabled = true;

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
        body: Center(child: CircularProgressIndicator(color: OrientalTheme.accentCyan, strokeWidth: 2.5.w)),
      );
    }

    final int totalGames = _user!.wins + _user!.losses;

    return Scaffold(
      backgroundColor: OrientalTheme.bgDark,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_pin_rounded, color: OrientalTheme.accentCyan, size: 20.r),
                  SizedBox(width: 6.w),
                  Text(
                    'بطاقة المحترف الشخصية 🛡️',
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side: Gamer Profile HUD & Stats
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: OrientalTheme.bgCard,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: OrientalTheme.accentCyan.withValues(alpha: 0.35), width: 1.w),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.r),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [OrientalTheme.accentPurple, OrientalTheme.accentCyan],
                                    ),
                                    boxShadow: [
                                      BoxShadow(color: OrientalTheme.accentCyan.withValues(alpha: 0.4), blurRadius: 8.r),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 26.r,
                                    backgroundImage: NetworkImage(_user!.avatarUrl),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _user!.name,
                                        style: GoogleFonts.cairo(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w900),
                                      ),
                                      Text(
                                        '${_user!.title} • ${_user!.vipTier}',
                                        style: GoogleFonts.cairo(color: OrientalTheme.accentCyan, fontSize: 10.sp, fontWeight: FontWeight.w700),
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
                                    Text('المستوى ${_user!.level}', style: GoogleFonts.cairo(color: OrientalTheme.textMuted, fontSize: 9.sp)),
                                    Text('${(_user!.xpProgress * 100).toInt()}% XP', style: GoogleFonts.cairo(color: OrientalTheme.accentCyan, fontSize: 9.sp, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 3.h),
                                LinearProgressIndicator(
                                  value: _user!.xpProgress,
                                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                                  color: OrientalTheme.accentCyan,
                                  minHeight: 5.h,
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            // Detailed Stats Grid
                            Expanded(
                              child: GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8.w,
                                mainAxisSpacing: 8.h,
                                childAspectRatio: 2.2,
                                children: [
                                  _buildStatBox('المباريات', '$totalGames', OrientalTheme.accentPurple),
                                  _buildStatBox('الانتصارات', '${_user!.wins}', OrientalTheme.accentEmerald),
                                  _buildStatBox('نسبة الفوز', '${_user!.winRate.toStringAsFixed(0)}%', OrientalTheme.primaryGold),
                                  _buildStatBox('الترتيب', '#4 العالمي', OrientalTheme.accentCyan),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Right Side: Sound & Game Settings
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: OrientalTheme.bgCard,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.w),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إعدادات اللعبة والصوت ⚙️',
                              style: GoogleFonts.cairo(color: OrientalTheme.accentCyan, fontSize: 11.sp, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 8.h),
                            _buildSettingSwitch(
                              title: 'المؤثرات الصوتية والبطاقات',
                              value: _soundManager.isSoundEnabled,
                              onChanged: (val) {
                                setState(() => _soundManager.toggleSound(val));
                                _soundManager.playButtonClick();
                              },
                              icon: Icons.volume_up_rounded,
                            ),
                            _buildSettingSwitch(
                              title: 'الموسيقى والتأثيرات المحيطية',
                              value: _soundManager.isMusicEnabled,
                              onChanged: (val) {
                                setState(() => _soundManager.toggleMusic(val));
                                _soundManager.playButtonClick();
                              },
                              icon: Icons.music_note_rounded,
                            ),
                            _buildSettingSwitch(
                              title: 'اهتزاز اللمس والتفاعل (Haptics)',
                              value: _hapticsEnabled,
                              onChanged: (val) {
                                setState(() => _hapticsEnabled = val);
                                _soundManager.playButtonClick();
                              },
                              icon: Icons.vibration_rounded,
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

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.w),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12.sp)),
          Text(label, style: GoogleFonts.cairo(color: OrientalTheme.textMuted, fontSize: 8.sp)),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: OrientalTheme.accentCyan, size: 16.r),
              SizedBox(width: 8.w),
              Text(title, style: GoogleFonts.cairo(color: Colors.white, fontSize: 10.sp)),
            ],
          ),
          Switch(
            value: value,
            activeThumbColor: OrientalTheme.accentCyan,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
