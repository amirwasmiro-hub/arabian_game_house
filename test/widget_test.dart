import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arabian_game_house/features/splash/screens/orodragon_splash_screen.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    bool finished = false;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(932, 430),
        builder: (context, child) => MaterialApp(
          home: OrodragonSplashScreen(
            onFinish: () => finished = true,
          ),
        ),
      ),
    );
    expect(find.byType(OrodragonSplashScreen), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    expect(finished, isTrue);
  });
}
