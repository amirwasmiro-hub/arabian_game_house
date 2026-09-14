import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/theme/oriental_theme.dart';
import 'core/audio/sound_manager.dart';
import 'core/services/supabase_service.dart';
import 'core/providers/game_user_provider.dart';
import 'features/splash/screens/orodragon_splash_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/leaderboard/screens/leaderboard_screen.dart';
import 'features/store/screens/store_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/home/widgets/rive_flame_nav_bar.dart';

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
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameUserProvider(),
      child: const ArabianGameHouseApp(),
    ),
  );
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
          title: 'مقهى الألعاب',
          debugShowCheckedModeBanner: false,
          theme: OrientalTheme.themeData,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'SA')],
          locale: const Locale('ar', 'SA'),
          home: const AppEntryFlow(),
        );
      },
    );
  }
}

class AppEntryFlow extends StatefulWidget {
  const AppEntryFlow({super.key});

  @override
  State<AppEntryFlow> createState() => _AppEntryFlowState();
}

class _AppEntryFlowState extends State<AppEntryFlow> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return OrodragonSplashScreen(
        onFinish: () {
          setState(() {
            _showSplash = false;
          });
        },
      );
    }

    return const MainNavigationWrapper();
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (index == 5) {
      _showSettingsDialog();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF2E1205),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          ),
          title: const Text(
            'الإعدادات',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.volume_up, color: Color(0xFFFFD700)),
                title: const Text(
                  'المؤثرات الصوتية',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: StatefulBuilder(
                  builder: (context, setTileState) => Switch(
                    value: SoundManager().isSoundEnabled,
                    activeColor: const Color(0xFFFFD700),
                    activeTrackColor: const Color(0xFF8B6B14),
                    onChanged: (val) {
                      SoundManager().toggleSound(val);
                      setTileState(() {});
                    },
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.music_note, color: Color(0xFFFFD700)),
                title: const Text(
                  'الموسيقى الشرقية',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: StatefulBuilder(
                  builder: (context, setTileState) => Switch(
                    value: SoundManager().isMusicEnabled,
                    activeColor: const Color(0xFFFFD700),
                    activeTrackColor: const Color(0xFF8B6B14),
                    onChanged: (val) {
                      SoundManager().toggleMusic(val);
                      setTileState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'إغلاق',
                style: TextStyle(color: Color(0xFFFFD700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1D0E38),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.exit_to_app_rounded,
                color: Color(0xFFFFD700),
                size: 28,
              ),
              SizedBox(width: 10.w),
              Text(
                'تأكيد الخروج',
                style: GoogleFonts.cairo(
                  color: const Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          content: Text(
            'هل تريد الخروج من اللعبة؟',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 15.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: const Color(0xFFB0A2C3),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'خروج',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeScreen(
        onTabChanged: _onTabSelected,
        currentTab: _currentIndex,
      ),
      const StoreScreen(),
      const LeaderboardScreen(),
      const ProfileScreen(),
      const StoreScreen(),
    ];

    final effectiveIndex = _currentIndex < tabs.length ? _currentIndex : 0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return;
        }

        final shouldExit = await _showExitConfirmationDialog();
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: OrientalTheme.bgDark,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: effectiveIndex,
                  children: tabs,
                ),
              ),
              if (effectiveIndex != 0)
                RoyalRiveFlameNavBar(
                  selectedIndex: _currentIndex,
                  onTabSelected: _onTabSelected,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
