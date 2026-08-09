import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/oriental_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/audio/sound_manager.dart';

class RoomCreationModal extends StatefulWidget {
  final VoidCallback onRoomCreated;
  const RoomCreationModal({super.key, required this.onRoomCreated});

  @override
  State<RoomCreationModal> createState() => _RoomCreationModalState();
}

class _RoomCreationModalState extends State<RoomCreationModal> {
  final TextEditingController _nameController = TextEditingController(text: 'مجلس السلاطين 👑');
  String _selectedGame = 'baloot';
  String _selectedGameTitle = 'البلوت';
  int _betCoins = 5000;
  final bool _isPrivate = false;

  final List<int> _stakes = [1000, 2500, 5000, 10000, 25000, 50000];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: OrientalTheme.bgCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border(top: BorderSide(color: OrientalTheme.primaryGold, width: 2.w)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: OrientalTheme.primaryGold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'إنشاء مجلس جديد 🏛️',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: OrientalTheme.primaryGold,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          // Room Name Input
          Text('اسم المجلس', style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontWeight: FontWeight.bold, fontSize: 12.sp)),
          SizedBox(height: 4.h),
          TextField(
            controller: _nameController,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 13.sp),
            decoration: InputDecoration(
              filled: true,
              fillColor: OrientalTheme.bgDark,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: OrientalTheme.primaryGold),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: OrientalTheme.primaryGold.withValues(alpha: 0.3)),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Select Game
          Text('اختر اللعبة', style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontWeight: FontWeight.bold, fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Row(
            children: [
              _buildGameChip('baloot', 'البلوت 🃏'),
              SizedBox(width: 8.w),
              _buildGameChip('jackaroo', 'الجاكارو 🎲'),
              SizedBox(width: 8.w),
              _buildGameChip('tarneeb', 'التارنيب 🎴'),
            ],
          ),
          SizedBox(height: 10.h),

          // Stake Coins
          Text('مقدار الرهان (ذهب)', style: GoogleFonts.cairo(color: OrientalTheme.textLight, fontWeight: FontWeight.bold, fontSize: 12.sp)),
          SizedBox(height: 4.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _stakes.map((stake) {
                bool isSel = _betCoins == stake;
                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: ChoiceChip(
                    label: Text('$stake 🪙', style: GoogleFonts.cairo(color: isSel ? Colors.black : OrientalTheme.primaryGold, fontSize: 11.sp)),
                    selected: isSel,
                    selectedColor: OrientalTheme.primaryGold,
                    backgroundColor: OrientalTheme.bgDark,
                    onSelected: (_) {
                      SoundManager().playButtonClick();
                      setState(() => _betCoins = stake);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16.h),

          // Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: OrientalTheme.primaryGold,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () async {
              SoundManager().playCoinsCollect();
              final navigator = Navigator.of(context);
              await SupabaseService().createRoom(
                roomName: _nameController.text,
                gameId: _selectedGame,
                gameTitle: _selectedGameTitle,
                betCoins: _betCoins,
                maxPlayers: 4,
                isPrivate: _isPrivate,
              );
              if (mounted) {
                navigator.pop();
                widget.onRoomCreated();
              }
            },
            child: Text(
              'افتح المجلس الآن 🔑',
              style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameChip(String id, String label) {
    bool isSel = _selectedGame == id;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.cairo(color: isSel ? Colors.black : OrientalTheme.textLight, fontSize: 11.sp)),
      selected: isSel,
      selectedColor: OrientalTheme.primaryGold,
      backgroundColor: OrientalTheme.bgDark,
      onSelected: (_) {
        SoundManager().playButtonClick();
        setState(() {
          _selectedGame = id;
          _selectedGameTitle = label.split(' ')[0];
        });
      },
    );
  }
}
