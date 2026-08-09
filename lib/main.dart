import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/oriental_theme.dart';
import 'core/audio/sound_manager.dart';
import 'core/services/supabase_service.dart';
import 'features/home/screens/home_screen.dart';
import 'features/leaderboard/screens/leaderboard_screen.dart';
import 'features/store/screens/store_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/game_table/baloot_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock Entire Application to Landscape Mode Globally
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await SoundManager().init();
  await SupabaseService().initialize(
    url: 'https://xyzcompany.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );
  runApp(const ArabianGameHouseApp());
}

class ArabianGameHouseApp extends StatelessWidget {
  const ArabianGameHouseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(932, 430), // Standard Landscape Screen Dimensions (widescreen)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'بيت الألعاب العربية',
          debugShowCheckedModeBanner: false,
          theme: OrientalTheme.themeData,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'SA'),
          ],
          locale: const Locale('ar', 'SA'),
          home: const MainNavigationWrapper(),
        );
      },
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(),
    LeaderboardScreen(),
    StoreScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: OrientalTheme.primaryGold,
        foregroundColor: Colors.black,
        icon: Icon(Icons.style, size: 20.r),
        label: Text(
          'لعب سريع 🃏',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
        ),
        onPressed: () {
          SoundManager().playCardFlip();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BalootGameScreen(
                roomName: 'طاولة البلوت السريعة ⚡',
                betCoins: 5000,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        height: 56.h,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: OrientalTheme.primaryGold, width: 1.w),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: OrientalTheme.bgDark,
          selectedItemColor: OrientalTheme.primaryGold,
          unselectedItemColor: OrientalTheme.textMuted,
          selectedFontSize: 11.sp,
          unselectedFontSize: 10.sp,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            SoundManager().playButtonClick();
            setState(() => _currentIndex = index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled, size: 20.r),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events, size: 20.r),
              label: 'السلاطين',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag, size: 20.r),
              label: 'المتجر',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 20.r),
              label: 'الملف الشخصي',
            ),
          ],
        ),
      ),
    );
  }
}
