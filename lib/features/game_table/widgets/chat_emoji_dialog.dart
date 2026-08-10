import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/audio/sound_manager.dart';

class ChatEmojiDialog extends StatefulWidget {
  final Function(String emoji) onSelectEmoji;
  final Function(String message) onSelectMessage;

  const ChatEmojiDialog({
    super.key,
    required this.onSelectEmoji,
    required this.onSelectMessage,
  });

  @override
  State<ChatEmojiDialog> createState() => _ChatEmojiDialogState();
}

class _ChatEmojiDialogState extends State<ChatEmojiDialog> {
  bool _isChatOff = false;

  final List<String> _emojis = [
    '😉', '👍', '😎', '😂', '⭐', '🍸', '💡', '🤑',
    '😱', '🤦‍♂️', '😢', '😭', '😍', '😵', '😴', '💤',
  ];

  final List<Map<String, String>> _quickChats = [
    {'ar': 'مرحباً', 'en': 'Hi'},
    {'ar': 'حظاً سعيداً!', 'en': 'Good Luck!'},
    {'ar': 'شكراً', 'en': 'Thanks'},
    {'ar': 'محظوظ', 'en': 'Lucky'},
    {'ar': 'غير محظوظ', 'en': 'Unlucky'},
    {'ar': 'لعبة جيدة!', 'en': 'Good Game!'},
    {'ar': 'لعب رائع!', 'en': 'Well Played!'},
    {'ar': 'عفواً...', 'en': 'Oops...'},
    {'ar': 'يجب أن أذهب...', 'en': 'Gotta Go...'},
    {'ar': 'وداعاً', 'en': 'Bye'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        width: 540.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF600814),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: OrientalTheme.primaryGold,
            width: 3.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 20.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top 2 Rows: Emojis Grid ──
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 6.h,
                  crossAxisSpacing: 6.w,
                  childAspectRatio: 1.0,
                ),
                itemCount: _emojis.length,
                itemBuilder: (context, index) {
                  final emoji = _emojis[index];
                  return GestureDetector(
                    onTap: () {
                      SoundManager().playButtonClick();
                      widget.onSelectEmoji(emoji);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: OrientalTheme.primaryGold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 22.sp),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 10.h),

              const Divider(color: OrientalTheme.cardBorderGold, thickness: 1),
              SizedBox(height: 8.h),

              // ── Bottom Section: Quick Chat Bubble Pills ──
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                alignment: WrapAlignment.center,
                children: [
                  ..._quickChats.map((chat) {
                    return GestureDetector(
                      onTap: () {
                        SoundManager().playButtonClick();
                        widget.onSelectMessage(chat['ar']!);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB71C1C),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: OrientalTheme.primaryGold.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${chat['ar']}  (${chat['en']})',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }),

                  // Custom Write Text Button
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB71C1C),
                      shape: BoxShape.circle,
                      border: Border.all(color: OrientalTheme.primaryGold),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: OrientalTheme.primaryGold,
                      size: 16.r,
                    ),
                  ),

                  // Chat OFF Toggle Button
                  GestureDetector(
                    onTap: () {
                      SoundManager().playButtonClick();
                      setState(() {
                        _isChatOff = !_isChatOff;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _isChatOff ? Colors.black54 : const Color(0xFF880E4F),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: OrientalTheme.primaryGold,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isChatOff ? Icons.do_not_disturb_on_rounded : Icons.mark_chat_read_rounded,
                            color: OrientalTheme.primaryGold,
                            size: 14.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _isChatOff ? 'Chat OFF' : 'Chat ON',
                            style: GoogleFonts.montserrat(
                              color: OrientalTheme.primaryGold,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
