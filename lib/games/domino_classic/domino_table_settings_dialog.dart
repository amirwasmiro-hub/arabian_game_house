import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/sound_manager.dart';
import '../../../core/theme/oriental_theme.dart';
import 'domino_classic_engine.dart';

/// صندوق إعدادات طاولة الدومينو بالتراث العربي الأصيل والفخامة الشرقية
class DominoTableSettingsDialog extends StatefulWidget {
  final DominoClassicEngine engine;
  final bool isInitial;
  final bool isDialog;
  final VoidCallback onApply;
  final VoidCallback? onCancel;

  const DominoTableSettingsDialog({
    super.key,
    required this.engine,
    this.isInitial = false,
    this.isDialog = true,
    required this.onApply,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required DominoClassicEngine engine,
    bool isInitial = false,
    required VoidCallback onApply,
    VoidCallback? onCancel,
  }) {
    SoundManager().playButtonClick();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: !isInitial,
      barrierLabel: 'DominoTableSettingsDialog',
      barrierColor: Colors.black.withValues(alpha: 0.82),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) => DominoTableSettingsDialog(
        engine: engine,
        isInitial: isInitial,
        isDialog: true,
        onApply: onApply,
        onCancel: onCancel,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved =
            CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  @override
  State<DominoTableSettingsDialog> createState() =>
      _DominoTableSettingsDialogState();
}

class _DominoTableSettingsDialogState extends State<DominoTableSettingsDialog> {
  late DominoPlayMode _mode;
  late DominoDifficulty _difficulty;
  late int _targetScore;
  late bool _soundEnabled;
  late bool _musicEnabled;

  @override
  void initState() {
    super.initState();
    _mode = widget.engine.mode;
    _difficulty = widget.engine.difficulty;
    _targetScore = widget.engine.targetScore;
    _soundEnabled = SoundManager().isSoundEnabled;
    _musicEnabled = SoundManager().isMusicEnabled;
  }

  void _onSaveAndApply() {
    SoundManager().playTilePlace();
    widget.engine.mode = _mode;
    widget.engine.difficulty = _difficulty;
    widget.engine.targetScore = _targetScore;
    if (widget.isDialog) {
      Navigator.of(context).pop();
    }
    widget.onApply();
  }

  void _onDismiss() {
    SoundManager().playButtonClick();
    if (widget.isDialog) {
      Navigator.of(context).pop();
    }
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 410.w,
            constraints: BoxConstraints(maxHeight: 380.h),
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2B1406), // خشب العود والأبنوس الفاخر
                  Color(0xFF1E0C04),
                  Color(0xFF120602),
                ],
              ),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 1.8.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                  blurRadius: 30.r,
                  spreadRadius: 2.r,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.9),
                  blurRadius: 18.r,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Stack(
                  children: [
                    // الزخرفة التراثية الإسلامية الخفيفة في الخلفية
                    const Positioned.fill(
                      child: CustomPaint(
                        painter: CasinoPatternPainter(
                          color: Color(0xFFFFD700),
                          opacity: 0.035,
                        ),
                      ),
                    ),

                    // الزوايا التراثية المنقوشة
                    Positioned(
                      top: 6.h,
                      right: 8.w,
                      child: _buildCornerFiligree(isTop: true, isRight: true),
                    ),
                    Positioned(
                      top: 6.h,
                      left: 8.w,
                      child: _buildCornerFiligree(isTop: true, isRight: false),
                    ),
                    Positioned(
                      bottom: 6.h,
                      right: 8.w,
                      child: _buildCornerFiligree(isTop: false, isRight: true),
                    ),
                    Positioned(
                      bottom: 6.h,
                      left: 8.w,
                      child: _buildCornerFiligree(isTop: false, isRight: false),
                    ),

                    // المحتوى الداخلي المنظم
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 1. الترويسة التراثية
                          _buildHeritageHeader(),

                          SizedBox(height: 8.h),

                          // 2. المحتوى القابل للتمرير
                          Flexible(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // طور اللعب
                                  _buildSectionCard(
                                    icon: Icons.groups_rounded,
                                    title: 'نوع اللعب',
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildHeritageOptionPlaque(
                                            title: 'فردي (1 ضد 1)',
                                            subtitle: 'تحدي فردى👤',
                                            isSelected: _mode ==
                                                DominoPlayMode.oneVsOne,
                                            onTap: () {
                                              SoundManager().playButtonClick();
                                              setState(() => _mode =
                                                  DominoPlayMode.oneVsOne);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: _buildHeritageOptionPlaque(
                                            title: 'شراكة (2 ضد 2)',
                                            subtitle:
                                                'أربعة منافسين وتحالف الأذكياء 👥',
                                            isSelected: _mode ==
                                                DominoPlayMode.partnership4P,
                                            onTap: () {
                                              SoundManager().playButtonClick();
                                              setState(() => _mode =
                                                  DominoPlayMode.partnership4P);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  // مستوى الذكاء الاصطناعي
                                  _buildSectionCard(
                                    icon: Icons.psychology_rounded,
                                    title: 'مستوى الذكاء ',
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildHeritageOptionPlaque(
                                            title: 'عادي 🟢',
                                            subtitle: 'جلسة تسلية وهدوء',
                                            isSelected: _difficulty ==
                                                DominoDifficulty.casual,
                                            onTap: () {
                                              SoundManager().playButtonClick();
                                              setState(() => _difficulty =
                                                  DominoDifficulty.casual);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: _buildHeritageOptionPlaque(
                                            title: 'محترف 🟡',
                                            subtitle: 'حريف قهاوي',
                                            isSelected: _difficulty ==
                                                DominoDifficulty.pro,
                                            onTap: () {
                                              SoundManager().playButtonClick();
                                              setState(() => _difficulty =
                                                  DominoDifficulty.pro);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: _buildHeritageOptionPlaque(
                                            title: 'داهية القهاوي 🔴',
                                            subtitle: 'تحدي كبار المعلمين',
                                            isSelected: _difficulty ==
                                                DominoDifficulty.grandmaster,
                                            onTap: () {
                                              SoundManager().playButtonClick();
                                              setState(() => _difficulty =
                                                  DominoDifficulty.grandmaster);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  // هدف الماتش ونقاط الحسم
                                  _buildSectionCard(
                                    icon: Icons.military_tech_rounded,
                                    title: 'النقاط',
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildHeritageOptionPlaque(
                                            title: '101 نقطة 🏆',
                                            isSelected: _targetScore == 101,
                                            onTap: () {
                                              SoundManager().playButtonClick();
                                              setState(
                                                  () => _targetScore = 101);
                                            },
                                            subtitle: '',
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: _buildHeritageOptionPlaque(
                                            title: '50 نقطة ⚡',
                                            subtitle: 'شوط خاطف وحماسي',
                                            isSelected: _targetScore == 50,
                                            onTap: () {
                                              SoundManager().playButtonClick();
                                              setState(() => _targetScore = 50);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: _buildHeritageOptionPlaque(
                                            title: 'جولة واحدة 🎯',
                                            subtitle: 'ضربة قاضية حاسمة',
                                            isSelected: _targetScore == 0,
                                            onTap: () {
                                              SoundManager().playButtonClick();
                                              setState(() => _targetScore = 0);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  // أصوات وأنغام المقهى الشرقي
                                  _buildSectionCard(
                                    icon: Icons.music_note_rounded,
                                    title: 'أجواء ونغمات المقهى',
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildAudioToggleCard(
                                            icon: Icons.volume_up_rounded,
                                            label: 'طقطقة الحطب والزهر',
                                            sublabel:
                                                'المؤثرات الصوتية الواقعية',
                                            isEnabled: _soundEnabled,
                                            onChanged: (val) {
                                              SoundManager().toggleSound(val);
                                              setState(
                                                  () => _soundEnabled = val);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: _buildAudioToggleCard(
                                            icon: Icons.album_rounded,
                                            label: 'أنغام العود والقانون',
                                            sublabel:
                                                'الموسيقى الشرقية الأصيلة',
                                            isEnabled: _musicEnabled,
                                            onChanged: (val) {
                                              SoundManager().toggleMusic(val);
                                              setState(
                                                  () => _musicEnabled = val);
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

                          SizedBox(height: 10.h),

                          // 3. أزرار التحكم السلاطينية بالأسفل
                          _buildHeritageActionButtons(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// الترويسة التراثية المنقوشة بماء الذهب
  Widget _buildHeritageHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOrnamentalWings(isLeft: true),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF522808),
                    Color(0xFF381B05),
                    Color(0xFF522808),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: const Color(0xFFFFD700),
                  width: 1.2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🀄',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'إعدادات مجلس الدومينو',
                    style: GoogleFonts.cairo(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFD700),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.9),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '👑',
                    style: TextStyle(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildOrnamentalWings(isLeft: false),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'تخصيص قوانين الجلسة وأجواء الماتش العربي الأصيل',
          style: GoogleFonts.cairo(
            fontSize: 7.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFD7C2A3),
          ),
        ),
      ],
    );
  }

  /// أجنحة زخرفية عربية
  Widget _buildOrnamentalWings({required bool isLeft}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 1.2.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLeft
                  ? [Colors.transparent, const Color(0xFFFFD700)]
                  : [const Color(0xFFFFD700), Colors.transparent],
            ),
          ),
        ),
        Icon(
          Icons.star_rounded,
          color: const Color(0xFFFFD700),
          size: 10.r,
        ),
        Container(
          width: 8.w,
          height: 1.2.h,
          color: const Color(0xFFFFD700),
        ),
      ],
    );
  }

  /// بطاقة القسم التراثية
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1B0B04).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFF8B6324).withValues(alpha: 0.45),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFD700), size: 12.r),
              SizedBox(width: 5.w),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 8.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFFE082),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          child,
        ],
      ),
    );
  }

  /// بلاطة الاختيار التراثية المنقوشة (Plaque)
  Widget _buildHeritageOptionPlaque({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF1A8),
                    Color(0xFFFFD700),
                    Color(0xFFCCA010),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF261206),
                    Color(0xFF190B03),
                  ],
                ),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFF9C4)
                : const Color(0xFF6E491A).withValues(alpha: 0.6),
            width: isSelected ? 1.4.w : 0.8.w,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.55),
                    blurRadius: 10.r,
                    spreadRadius: 1.r,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 4.r,
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle_rounded,
                    size: 9.r,
                    color: const Color(0xFF2A1201),
                  ),
                  SizedBox(width: 3.w),
                ],
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? const Color(0xFF261002)
                          : const Color(0xFFFFECB3),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 6.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF4A2508)
                    : const Color(0xFFB5A18C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// كارت تبديل الصوت التراثي
  Widget _buildAudioToggleCard({
    required IconData icon,
    required String label,
    required String sublabel,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFF241106),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isEnabled
              ? const Color(0xFFFFD700).withValues(alpha: 0.6)
              : const Color(0xFF5E3C16).withValues(alpha: 0.4),
          width: 0.9.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isEnabled
                  ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                  : Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isEnabled ? const Color(0xFFFFD700) : Colors.white38,
              size: 12.r,
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    fontSize: 7.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? Colors.white : Colors.white60,
                  ),
                ),
                Text(
                  sublabel,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    fontSize: 5.5.sp,
                    color: const Color(0xFFB5A18C),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.72,
            child: Switch(
              value: isEnabled,
              activeThumbColor: const Color(0xFFFFD700),
              activeTrackColor: const Color(0xFF9E7714),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.black38,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// أزرار التحكم السلاطينية السفلية
  Widget _buildHeritageActionButtons() {
    return Row(
      children: [
        // زر الإغلاق / الإلغاء
        Expanded(
          flex: 4,
          child: GestureDetector(
            onTap: _onDismiss,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF1E0E05),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFFB0A2C3).withValues(alpha: 0.5),
                  width: 0.8.w,
                ),
              ),
              child: Text(
                widget.isInitial ? 'خروج من الطاولة' : 'إلغاء التعديل',
                style: GoogleFonts.cairo(
                  fontSize: 7.5.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD5C7B8),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 8.w),

        // زر التأكيد الذهبي الملوكي
        Expanded(
          flex: 6,
          child: GestureDetector(
            onTap: _onSaveAndApply,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5.5.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF176),
                    Color(0xFFFFD700),
                    Color(0xFFD69A08),
                  ],
                ),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFFFFF9C4),
                  width: 1.2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.65),
                    blurRadius: 14.r,
                    spreadRadius: 1.r,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 6.r,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.casino_rounded,
                    color: const Color(0xFF261002),
                    size: 11.r,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      widget.isInitial
                          ? 'بدء الماتش 🎲'
                          : 'تطبيق و بدء جولة جديدة 🎲',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 7.8.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF220C01),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// رسم الزوايا التراثية المنقوشة
  Widget _buildCornerFiligree({required bool isTop, required bool isRight}) {
    return Opacity(
      opacity: 0.65,
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 9.r,
        color: const Color(0xFFFFD700),
      ),
    );
  }
}
