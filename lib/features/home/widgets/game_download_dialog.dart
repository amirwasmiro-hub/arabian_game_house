import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/game_user_provider.dart';
import '../../../core/audio/sound_manager.dart';

class GameDownloadDialog extends StatefulWidget {
  final String gameId;
  final String titleAr;
  final String titleEn;
  final IconData icon;
  final String? assetPath;
  final VoidCallback onComplete;

  const GameDownloadDialog({
    super.key,
    required this.gameId,
    required this.titleAr,
    required this.titleEn,
    required this.icon,
    this.assetPath,
    required this.onComplete,
  });

  static Future<void> show(
    BuildContext context, {
    required String gameId,
    required String titleAr,
    required String titleEn,
    required IconData icon,
    String? assetPath,
    required VoidCallback onComplete,
  }) async {
    final provider = Provider.of<GameUserProvider>(context, listen: false);
    if (provider.isGameDownloaded(gameId)) {
      onComplete();
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GameDownloadDialog(
        gameId: gameId,
        titleAr: titleAr,
        titleEn: titleEn,
        icon: icon,
        assetPath: assetPath,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<GameDownloadDialog> createState() => _GameDownloadDialogState();
}

class _GameDownloadDialogState extends State<GameDownloadDialog> {
  double _progress = 0.0;
  String _statusText = 'يتم الآن تنزيل حزمة الموارد...';
  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    _startSimulatedDownload();
  }

  void _startSimulatedDownload() {
    _downloadTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.03;
        if (_progress > 0.35 && _progress < 0.75) {
          _statusText = 'جاري تنزيل أصوات وطاولات ${widget.titleAr}...';
        } else if (_progress >= 0.75 && _progress < 1.0) {
          _statusText = 'جاري التحقق من أصول اللعبة وفك الضغط...';
        } else if (_progress >= 1.0) {
          _progress = 1.0;
          _statusText = 'اكتمل التنزيل بنجاح!';
          _downloadTimer?.cancel();
          _onFinished();
        }
      });
    });
  }

  void _onFinished() async {
    SoundManager().playWinFanfare();
    final provider = Provider.of<GameUserProvider>(context, listen: false);
    provider.markGameAsDownloaded(widget.gameId);
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.of(context).pop();
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _downloadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_progress * 100).toInt();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
        child: Container(
          width: 380.w,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E1205), Color(0xFF140803)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFFFD700),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                blurRadius: 20.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon & Game Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5.w),
                      color: const Color(0xFF421554),
                    ),
                    child: Icon(widget.icon, color: const Color(0xFFFFD700), size: 20.r),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.titleAr,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                      Text(
                        widget.titleEn,
                        style: GoogleFonts.montserrat(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 14.h),

              // Status Text & Percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _statusText,
                      style: GoogleFonts.cairo(
                        fontSize: 9.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              // Glowing Progress Bar
              Container(
                height: 12.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    width: 0.8.w,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9.r),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: _progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF9100),
                                Color(0xFFFFD700),
                                Color(0xFF00E676),
                              ],
                            ),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // CDN / Asset Bundle Note
              Text(
                '⚡ نظام التنزيل الديناميكي لتوفير مساحة هاتفك',
                style: GoogleFonts.cairo(
                  fontSize: 7.5.sp,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
