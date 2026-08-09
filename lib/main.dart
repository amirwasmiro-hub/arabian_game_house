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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      designSize: const Size(932, 430),
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
          supportedLocales: const [Locale('ar', 'SA')],
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

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_filled, label: 'الرئيسية'),
    _NavItem(icon: Icons.emoji_events, label: 'السلاطين'),
    _NavItem(icon: Icons.shopping_bag, label: 'المتجر'),
    _NavItem(icon: Icons.person, label: 'الملف'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0C0A),
          border: Border(
            top: BorderSide(
              color: OrientalTheme.primaryGold.withValues(alpha: 0.3),
              width: 1.w,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            _navItems.length,
            (index) => _buildNavItem(index),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _currentIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () {
        SoundManager().playButtonClick();
        setState(() => _currentIndex = index);
      },
      child: SizedBox(
        width: 80.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 2.5.h,
              width: isSelected ? 36.w : 0,
              decoration: BoxDecoration(
                color: isSelected
                    ? OrientalTheme.primaryGold
                    : Colors.transparent,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Icon(
              item.icon,
              color: isSelected
                  ? OrientalTheme.primaryGold
                  : OrientalTheme.textMuted,
              size: isSelected ? 19.r : 17.r,
            ),
            SizedBox(height: 2.h),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isSelected
                    ? OrientalTheme.primaryGold
                    : OrientalTheme.textMuted,
                fontSize: isSelected ? 9.sp : 8.sp,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}
