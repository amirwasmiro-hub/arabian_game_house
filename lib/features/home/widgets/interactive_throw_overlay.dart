import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/audio/sound_manager.dart';

class FlyingItem {
  final String emoji;
  final Offset start;
  final Offset end;
  final String impactSound;

  FlyingItem({
    required this.emoji,
    required this.start,
    required this.end,
    this.impactSound = 'audio/click.mp3',
  });
}

class InteractiveThrowOverlay extends StatefulWidget {
  final Widget child;

  const InteractiveThrowOverlay({super.key, required this.child});

  static InteractiveThrowOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<InteractiveThrowOverlayState>();
  }

  @override
  State<InteractiveThrowOverlay> createState() => InteractiveThrowOverlayState();
}

class InteractiveThrowOverlayState extends State<InteractiveThrowOverlay>
    with TickerProviderStateMixin {
  final List<Widget> _activeFlyingWidgets = [];

  void throwItem({
    required String emoji,
    required Offset from,
    required Offset to,
  }) {
    SoundManager().playButtonClick();
    final key = UniqueKey();

    late Widget itemWidget;
    itemWidget = Positioned(
      key: key,
      left: 0,
      top: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutQuad,
        onEnd: () {
          SoundManager().playTilePlace();
          setState(() {
            _activeFlyingWidgets.removeWhere((w) => w.key == key);
          });
        },
        builder: (context, value, child) {
          final curX = from.dx + (to.dx - from.dx) * value;
          // Curved parabolic trajectory
          final curY = from.dy + (to.dy - from.dy) * value - (sin(value * pi) * 60.h);
          final scale = 1.0 + sin(value * pi) * 0.5;
          final rotation = value * 4 * pi;

          return Transform.translate(
            offset: Offset(curX, curY),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: 26.sp),
                ),
              ),
            ),
          );
        },
      ),
    );

    setState(() {
      _activeFlyingWidgets.add(itemWidget);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        ..._activeFlyingWidgets,
      ],
    );
  }
}

class InteractiveEmojiToolbar extends StatelessWidget {
  final Offset opponentPosition;
  final Offset myPosition;

  const InteractiveEmojiToolbar({
    super.key,
    required this.opponentPosition,
    required this.myPosition,
  });

  static final List<String> _emojis = ['🍅', '🩴', '🥚', '💐', '💣', '🍿'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.5),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _emojis.map((emoji) {
          return GestureDetector(
            onTap: () {
              final overlay = InteractiveThrowOverlay.of(context);
              if (overlay != null) {
                overlay.throwItem(
                  emoji: emoji,
                  from: myPosition,
                  to: opponentPosition,
                );
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white10,
              ),
              child: Text(
                emoji,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
